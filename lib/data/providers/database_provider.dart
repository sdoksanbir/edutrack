import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/features/auth/auth_providers.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';

/// Oturumdaki kullanıcıya özel SQLite; hesap değişince dosya değişir.
final databaseProvider = Provider<AppDatabase>((ref) {
  ref.watch(authSessionProvider);
  final userId = AppSupabase.isReady
      ? AppSupabase.client.auth.currentUser?.id
      : null;
  final db = AppDatabase(userId: userId);
  ref.onDispose(() {
    db.close();
  });
  return db;
});
