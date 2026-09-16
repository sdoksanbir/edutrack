import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/auth/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Hesap değişince buluttan profil + öğrencileri o kullanıcının yerel DB’sine çeker.
final cloudSessionBootstrapProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<Session?>>(authSessionProvider, (prev, next) {
    final session = next.asData?.value;
    if (session == null) return;
    final prevId = prev?.asData?.value?.user.id;
    final nextId = session.user.id;
    if (prevId == nextId) return;

    Future<void>(() async {
      await Future<void>.delayed(Duration.zero);
      final cloud = ref.read(cloudSyncServiceProvider);
      if (!cloud.canSync) return;
      try {
        await cloud.pullAllData();
      } catch (e) {
        debugPrint('Oturum bootstrap sync: $e');
        try {
          await cloud.pullProfile();
          await cloud.pullAllStudents();
        } catch (e2) {
          debugPrint('Oturum bootstrap fallback: $e2');
        }
      }
    });
  });
});
