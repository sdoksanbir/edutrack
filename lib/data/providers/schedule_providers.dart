import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';

/// Seçili tarih provider'ı (normalize edilmiş - saat 00:00)
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Günlük ders listesi provider'ı (stream)
final dailyScheduleProvider = StreamProvider.family<List<EffectiveScheduleItem>, DateTime>(
  (ref, date) {
    final repo = ref.watch(scheduleRepoProvider);
    // Tarihi normalize et (saat 00:00)
    final normalized = DateTime(date.year, date.month, date.day);
    return repo.watchEffectiveScheduleForDate(normalized);
  },
);
