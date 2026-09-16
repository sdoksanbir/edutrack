import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';

/// Takvim için gün bazında dersleri getiren provider
///
/// Kurallar:
/// - TEK VERİ KAYNAĞI: SessionOccurrences (watchLessonsByDateRange içinde)
/// - Parametre: DateTimeRange (ayın ilk günü ve son günü)
/// - Stream açılmadan önce aralık dışı planned temizlenir ve geçerli
///   pencerede eksikler üretilir (yeşil flaş olmasın).
/// - Drift watchQuery ile SessionOccurrences değişikliklerini otomatik yakalar.
final calendarLessonsProvider =
    StreamProvider.family<Map<DateTime, List<Lesson>>, DateTimeRange>(
  (ref, dateRange) {
    final lessonsRepo = ref.watch(lessonsRepoProvider);
    final scheduleRepo = ref.watch(scheduleRepoProvider);

    return Stream.fromFuture(() async {
      // Önce eski fazla kayıtları düş (bitiş tarihi sonrası yeşiller)
      await scheduleRepo.prunePlannedOutsideActiveTemplateWindows();
      await scheduleRepo.upsertOccurrencesForRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
    }()).asyncExpand(
      (_) => lessonsRepo.watchLessonsByDateRange(
        startDate: dateRange.start,
        endDate: dateRange.end,
      ),
    );
  },
);
