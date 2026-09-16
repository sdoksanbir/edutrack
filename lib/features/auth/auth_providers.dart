import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth oturumu; Supabase kapalıysa hep null (yerel mod).
final authSessionProvider = StreamProvider<Session?>((ref) {
  if (!AppSupabase.isReady) {
    return Stream.value(null);
  }
  return _sessionStream(AppSupabase.client);
});

Stream<Session?> _sessionStream(SupabaseClient client) async* {
  yield client.auth.currentSession;
  yield* client.auth.onAuthStateChange.map((event) => event.session);
}

final currentUserProvider = Provider<User?>((ref) {
  final fromStream = ref.watch(authSessionProvider).asData?.value?.user;
  if (fromStream != null) return fromStream;
  if (!AppSupabase.isReady) return null;
  return AppSupabase.client.auth.currentUser;
});

class AuthService {
  AuthService._();

  /// Recovery link oturumu açtıysa yeni şifre ekranında kalmak için.
  static bool pendingPasswordRecovery = false;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return AppSupabase.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) {
    return AppSupabase.client.auth.signUp(
      email: email.trim(),
      password: password,
      data: fullName == null || fullName.trim().isEmpty
          ? null
          : {'full_name': fullName.trim()},
    );
  }

  /// E-posta ile şifre sıfırlama linki gönderir (internet gerekir).
  static Future<void> requestPasswordReset(String email) {
    return AppSupabase.client.auth.resetPasswordForEmail(email.trim());
  }

  static Future<UserResponse> updatePassword(String newPassword) {
    return AppSupabase.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Oturum açıkken mevcut şifreyi doğrulayıp yeniler.
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = AppSupabase.client.auth.currentUser?.email;
    if (email == null || email.isEmpty) {
      throw AuthException('Oturum yok veya e-posta bulunamadı.');
    }
    await AppSupabase.client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await AppSupabase.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  static Future<void> signOut() async {
    pendingPasswordRecovery = false;
    await AppSupabase.client.auth.signOut();
  }

  static String mapError(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      final code = (error.code ?? '').toLowerCase();
      if (msg.contains('invalid login') ||
          msg.contains('invalid_credentials') ||
          code.contains('invalid')) {
        return 'E-posta veya şifre hatalı.\n'
            '• Alan: kullanıcı adı değil, tam e-posta (ör. ali@mail.com)\n'
            '• Dashboard → Authentication → Users’da şifreyi sıfırlayın\n'
            '• Kullanıcı oluştururken “Auto Confirm User” işaretli olsun';
      }
      if (msg.contains('email not confirmed') ||
          code.contains('email_not_confirmed')) {
        return 'E-posta onaylanmamış.\n'
            'Authentication → Users → kullanıcıyı aç → Confirm / onayla\n'
            'veya Providers → Email → Confirm email’i kapatıp kullanıcıyı yeniden oluştur.';
      }
      if (msg.contains('rate limit') || code.contains('over_email_send_rate')) {
        return 'Çok fazla deneme. Birkaç dakika sonra tekrar deneyin.';
      }
      if (msg.contains('user not found') || code.contains('user_not_found')) {
        return 'Bu e-posta ile kayıtlı hesap bulunamadı.';
      }
      return error.message;
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı (tam e-posta ile deneyin).';
    }
    if (raw.contains('email not confirmed')) {
      return 'E-posta henüz doğrulanmamış. Supabase’de kullanıcıyı onaylayın.';
    }
    if (raw.contains('user already registered')) {
      return 'Bu e-posta zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'Ağ hatası. İnternet bağlantınızı kontrol edin.';
    }
    debugPrint('Auth error: $error');
    return 'Giriş başarısız: $error';
  }
}

/// go_router'ın auth değişiminde yenilenmesi için.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
