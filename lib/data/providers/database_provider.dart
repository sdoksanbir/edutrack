import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/features/auth/auth_providers.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';

/// Oturumdaki kullanıcıya özel SQLite; sadece user id değişince yeniden açılır
/// (token refresh DB’yi kapatmaz).
final databaseProvider = Provider<AppDatabase>((ref) {
  final userId = ref.watch(
    authSessionProvider.select((async) => async.asData?.value?.user.id),
  );
  final effectiveUserId = !AppSupabase.isReady
      ? null
      : (userId ?? AppSupabase.client.auth.currentUser?.id);
  final db = AppDatabase(userId: effectiveUserId);
  ref.onDispose(() {
    db.close();
  });
  return db;
});
