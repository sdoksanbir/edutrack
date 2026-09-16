import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/auth/auth_providers.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';
import 'package:ozel_ders_takip/shared/constants/curriculum_folders.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/models/teacher_profile.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';

final teacherProfileProvider =
    FutureProvider.autoDispose<TeacherProfile>((ref) async {
  return ref.watch(appSettingsRepoProvider).getTeacherProfile();
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  String? _photoPath;
  final Set<String> _branches = {};
  final Set<String> _visible = {};
  bool _loading = true;
  bool _saving = false;
  bool _changingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get _canChangePassword =>
      AppSupabase.isReady &&
      AppSupabase.client.auth.currentSession != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cloud = ref.read(cloudSyncServiceProvider);
    TeacherProfile? profile;
    if (cloud.canSync) {
      try {
        profile = await cloud.pullProfile();
      } catch (e) {
        debugPrint('Profil buluttan çekilemedi: $e');
      }
    }
    profile ??= await ref.read(appSettingsRepoProvider).getTeacherProfile();
    if (!mounted) return;
    setState(() {
      _nameCtrl.text = formatPersonFullName(profile!.fullName);
      final p = profile.phone;
      _phoneCtrl.text =
          (p == null || p.isEmpty) ? '' : formatTurkishPhoneDisplay(p);
      _photoPath = profile.hasPhoto ? profile.photoPath : null;
      _branches
        ..clear()
        ..addAll(profile.branches);
      _visible
        ..clear()
        ..addAll(profile.visibleFolders);
      _loading = false;
    });
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    try {
      final path = await ref
          .read(appSettingsRepoProvider)
          .pickAndSaveTeacherPhoto(fromCamera: fromCamera);
      if (path != null && mounted) {
        setState(() => _photoPath = path);
        ref.invalidate(teacherProfileProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf alınamadı: $e')),
      );
    }
  }

  Future<void> _showPhotoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeriden seç'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(fromCamera: true);
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.danger),
                title: const Text('Fotoğrafı kaldır'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref.read(appSettingsRepoProvider).saveTeacherProfile(
                        fullName: formatPersonFullName(_nameCtrl.text),
                        phone: _phoneCtrl.text,
                        branches: _branches.toList(),
                        visibleFolders: _visible.toList(),
                        clearPhoto: true,
                      );
                  if (mounted) setState(() => _photoPath = null);
                  ref.invalidate(teacherProfileProvider);
                  final cloud = ref.read(cloudSyncServiceProvider);
                  if (cloud.canSync) {
                    try {
                      final p = await ref
                          .read(appSettingsRepoProvider)
                          .getTeacherProfile();
                      await cloud.pushProfile(p);
                    } catch (e) {
                      debugPrint('Profil foto bulut güncellemesi: $e');
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final name = formatPersonFullName(_nameCtrl.text);
      _nameCtrl.text = name;
      final phone = formatTurkishPhone(_phoneCtrl.text);
      final branches = CurriculumFolders.all
          .where((f) => _branches.contains(f))
          .toList();
      final visible = CurriculumFolders.all
          .where((f) => _visible.contains(f))
          .toList();

      await ref.read(appSettingsRepoProvider).saveTeacherProfile(
            fullName: name,
            phone: phone,
            branches: branches,
            visibleFolders: visible,
            photoPath: _photoPath,
          );
      ref.invalidate(teacherProfileProvider);

      String message = 'Profil kaydedildi';
      final cloud = ref.read(cloudSyncServiceProvider);
      if (cloud.canSync) {
        try {
          await cloud.pushProfile(
            TeacherProfile(
              fullName: name,
              phone: phone,
              photoPath: _photoPath,
              branches: branches,
              visibleFolders: visible,
            ),
          );
          message = 'Profil kaydedildi ve buluta yedeklendi';
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Yerel kaydedildi; bulut hatası: $e')),
            );
          }
          if (mounted) Navigator.of(context).maybePop();
          return;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPassCtrl.text;
    final next = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (current.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mevcut şifreyi girin')),
      );
      return;
    }
    if (next.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifre en az 6 karakter olmalı')),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifreler eşleşmiyor')),
      );
      return;
    }

    setState(() => _changingPassword = true);
    try {
      await AuthService.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      if (!mounted) return;
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmPassCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre güncellendi')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.mapError(e))),
      );
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Widget _folderExpansion({
    required String title,
    required String subtitle,
    required Set<String> selected,
    required void Function(String folder, bool enabled) onToggle,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          children: CurriculumFolders.all
              .map(
                (folder) => CheckboxListTile(
                  value: selected.contains(folder),
                  title: Text(folder),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (v) => onToggle(folder, v == true),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(currentUserProvider)?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsTr.profile),
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(StringsTr.save),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primarySoft,
                        backgroundImage: _photoPath != null
                            ? FileImage(File(_photoPath!))
                            : null,
                        child: _photoPath == null
                            ? const Icon(
                                Icons.person,
                                size: 52,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _showPhotoSheet,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Telefondan profil fotoğrafı ekleyin',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
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
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [TurkishPhoneInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: '0 (5xx) xxx xx xx',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 12),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      email,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                ],
                if (_canChangePassword) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Şifre değiştir',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentPassCtrl,
                    obscureText: _obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Mevcut şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureCurrent = !_obscureCurrent,
                        ),
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPassCtrl,
                    obscureText: _obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Yeni şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPassCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Yeni şifre (tekrar)',
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
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _changingPassword ? null : _changePassword,
                    child: _changingPassword
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Şifreyi güncelle'),
                  ),
                ],
                const SizedBox(height: 28),
                _folderExpansion(
                  title: 'Branşlarım',
                  subtitle:
                      'Kapalı · Seçilen branşlar profilde görünür (${_branches.length})',
                  selected: _branches,
                  onToggle: (folder, enabled) {
                    setState(() {
                      if (enabled) {
                        _branches.add(folder);
                        _visible.add(folder);
                      } else {
                        _branches.remove(folder);
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                _folderExpansion(
                  title: 'Görünecek dersler',
                  subtitle:
                      'Kapalı · Parametreler listesi (${_visible.isEmpty ? 'hepsi' : _visible.length})',
                  selected: _visible,
                  onToggle: (folder, enabled) {
                    setState(() {
                      if (enabled) {
                        _visible.add(folder);
                      } else {
                        _visible.remove(folder);
                        _branches.remove(folder);
                      }
                    });
                  },
                ),
                if (_canChangePassword) ...[
                  const SizedBox(height: 28),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await AuthService.signOut();
                      if (!context.mounted) return;
                      context.go(AppRouter.login);
                    },
                    icon: const Icon(Icons.logout, color: AppColors.danger),
                    label: Text(
                      StringsTr.logout,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
