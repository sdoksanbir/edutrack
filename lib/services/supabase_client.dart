import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase bağlantısı (bulut senkron / Auth / Storage).
///
/// Öncelik: `--dart-define=SUPABASE_URL` / `SUPABASE_ANON_KEY`.
/// Tanımlı değilse aşağıdaki varsayılanlar kullanılır (anon key + RLS).
class AppSupabase {
  AppSupabase._();

  static bool _initialized = false;

  /// Proje URL / anon key (release APK için varsayılan gömülü).
  static const String defaultUrl =
      'https://qixzimjcidvbcacgxglp.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpeHppbWpjaWR2YmNhY2d4Z2xwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk1ODExMDgsImV4cCI6MjEwNTE1NzEwOH0.iwYsp0FEuoU1AOtiOgWIGHjya92Q5fkXFUdwSvLZ8ko';

  static bool get isReady => _initialized;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase henüz hazır değil. isReady kontrolü yapın.',
      );
    }
    return Supabase.instance.client;
  }

  /// Key’ler varsa initialize eder.
  static Future<bool> init() async {
    const urlFromEnv = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const keyFromEnv =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    final url = urlFromEnv.isNotEmpty ? urlFromEnv : defaultUrl;
    final anonKey = keyFromEnv.isNotEmpty ? keyFromEnv : defaultAnonKey;

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint('Supabase: URL/key yok — yerel Drift modu.');
      _initialized = false;
      return false;
    }

    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
    debugPrint('Supabase: bağlantı hazır ($url).');
    return true;
  }
}
