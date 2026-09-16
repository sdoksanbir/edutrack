import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase bağlantısı (bulut senkron / Auth / Storage için altyapı).
///
/// Anahtarlar `--dart-define` ile verilir; yoksa uygulama yerel Drift ile
/// çalışmaya devam eder (`isReady == false`).
///
/// Örnek:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJ...
/// ```
class AppSupabase {
  AppSupabase._();

  static bool _initialized = false;

  /// Supabase başarıyla initialize edildi mi?
  static bool get isReady => _initialized;

  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase henüz hazır değil. SUPABASE_URL / SUPABASE_ANON_KEY '
        'tanımlayın veya isReady kontrolü yapın.',
      );
    }
    return Supabase.instance.client;
  }

  /// Key’ler varsa initialize eder; yoksa sessizce atlar (yerel mod).
  static Future<bool> init() async {
    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const anonKey =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint(
        'Supabase: SUPABASE_URL / SUPABASE_ANON_KEY yok — yerel Drift modu.',
      );
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
    debugPrint('Supabase: bağlantı hazır.');
    return true;
  }
}
