import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/features/auth/auth_providers.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthUiMode { login, register, forgot, setNewPassword }

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  _AuthUiMode _mode = _AuthUiMode.login;
  bool _busy = false;
  String? _error;
  String? _info;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    if (AuthService.pendingPasswordRecovery) {
      _mode = _AuthUiMode.setNewPassword;
    }
    if (AppSupabase.isReady) {
      _authSub = AppSupabase.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          AuthService.pendingPasswordRecovery = true;
          if (mounted) {
            setState(() {
              _mode = _AuthUiMode.setNewPassword;
              _error = null;
              _info = 'Yeni şifrenizi belirleyin.';
            });
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!AppSupabase.isReady) {
      setState(() => _error = 'Supabase yapılandırılmamış (dart-define eksik).');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    try {
      switch (_mode) {
        case _AuthUiMode.register:
          final res = await AuthService.signUp(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            fullName: formatPersonFullName(_nameCtrl.text),
          );
          if (res.session == null && mounted) {
            setState(() {
              _info =
                  'Kayıt alındı. E-posta onayı açıksa gelen kutunu kontrol edin; '
                  'veya Dashboard’dan kullanıcıyı onaylayıp giriş yapın.';
              _mode = _AuthUiMode.login;
            });
          }
        case _AuthUiMode.login:
          final res = await AuthService.signIn(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
          );
          if (res.session == null && mounted) {
            setState(() {
              _error =
                  'Giriş tamamlanamadı (oturum yok). E-posta onayı gerekebilir: '
                  'Authentication → Users → Confirm user.';
            });
          }
        case _AuthUiMode.forgot:
          // Geçici: mail linki yerine yönetici Dashboard’dan şifre koyar.
          if (mounted) {
            setState(() {
              _info =
                  'Hesap notu: ${_emailCtrl.text.trim()}\n\n'
                  'Yöneticiye bu e-postayı iletin; Supabase → Users’dan '
                  'yeni şifre koyulsun. Sonra giriş ekranından o şifreyle girin.';
              _mode = _AuthUiMode.login;
            });
          }
        case _AuthUiMode.setNewPassword:
          await AuthService.updatePassword(_passwordCtrl.text);
          AuthService.pendingPasswordRecovery = false;
          if (mounted) {
            setState(() {
              _info = 'Şifreniz güncellendi. Giriş yapabilirsiniz.';
              _mode = _AuthUiMode.login;
              _passwordCtrl.clear();
              _confirmCtrl.clear();
            });
            await AuthService.signOut();
          }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = AuthService.mapError(e));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _switchMode(_AuthUiMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _info = null;
    });
  }

  String get _subtitle {
    switch (_mode) {
      case _AuthUiMode.register:
        return 'Yeni öğretmen hesabı oluştur';
      case _AuthUiMode.forgot:
        return 'Şifre sıfırlama (geçici)';
      case _AuthUiMode.setNewPassword:
        return 'Hesabınız için yeni bir şifre belirleyin';
      case _AuthUiMode.login:
        return 'Bulut hesabınla giriş yap\n(E-posta + şifre; kullanıcı adı değil)';
    }
  }

  String get _primaryLabel {
    switch (_mode) {
      case _AuthUiMode.register:
        return StringsTr.register;
      case _AuthUiMode.forgot:
        return 'Anladım — Girişe dön';
      case _AuthUiMode.setNewPassword:
        return StringsTr.saveNewPassword;
      case _AuthUiMode.login:
        return StringsTr.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPassword = _mode == _AuthUiMode.login ||
        _mode == _AuthUiMode.register ||
        _mode == _AuthUiMode.setNewPassword;
    final showEmail = _mode != _AuthUiMode.setNewPassword;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'EduTrack',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    if (!AppSupabase.isReady) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Supabase key yok. Uygulamayı --dart-define=SUPABASE_URL '
                          've SUPABASE_ANON_KEY ile çalıştırın.',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (_mode == _AuthUiMode.forgot) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Text(
                          'Geçici çözüm (e-posta linki henüz mobil için ayarlı değil):\n\n'
                          '1) Yönetici: Supabase → Authentication → Users\n'
                          '2) Kullanıcıyı aç → Reset password / yeni şifre koy\n'
                          '3) Yeni şifreyi öğretmene ilet\n'
                          '4) Öğretmen bu ekrandan yeni şifreyle giriş yapsın\n\n'
                          'İnternet varken giriş her zaman Supabase’deki güncel şifreyledir.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta (hatırlatma)',
                          prefixIcon: Icon(Icons.email_outlined),
                          helperText:
                              'Yöneticiye hangi hesabın sıfırlanacağını söylemek için',
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty || !t.contains('@')) {
                            return 'Geçerli bir e-posta girin';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      if (_mode == _AuthUiMode.register) ...[
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          inputFormatters: [PersonFullNameInputFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Ad Soyad',
                            hintText: 'Örn. Ayşe YILMAZ',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (showEmail) ...[
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: StringsTr.email,
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty || !t.contains('@')) {
                              return 'Geçerli bir e-posta girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (showPassword) ...[
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          autofillHints: _mode == _AuthUiMode.setNewPassword
                              ? const [AutofillHints.newPassword]
                              : const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: _mode == _AuthUiMode.setNewPassword
                                ? StringsTr.newPassword
                                : StringsTr.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'Şifre en az 6 karakter olmalı';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (_mode != _AuthUiMode.setNewPassword) _submit();
                          },
                        ),
                      ],
                      if (_mode == _AuthUiMode.setNewPassword) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: StringsTr.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v != _passwordCtrl.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ],
                    ],
                    if (_info != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _info!,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_primaryLabel),
                    ),
                    if (_mode == _AuthUiMode.login) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _switchMode(_AuthUiMode.forgot),
                        child: const Text(StringsTr.forgotPassword),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () {
                              if (_mode == _AuthUiMode.login) {
                                _switchMode(_AuthUiMode.register);
                              } else {
                                _switchMode(_AuthUiMode.login);
                              }
                            },
                      child: Text(
                        _mode == _AuthUiMode.register
                            ? 'Zaten hesabım var — Giriş yap'
                            : _mode == _AuthUiMode.forgot ||
                                    _mode == _AuthUiMode.setNewPassword
                                ? 'Giriş ekranına dön'
                                : 'Hesabım yok — Kayıt ol',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
