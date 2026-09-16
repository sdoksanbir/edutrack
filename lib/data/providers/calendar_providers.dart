import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';

/// Takvim için gün bazında dersleri getiren provider
///
/// Kurallar:
/// - TEK VERİ KAYNAĞI: SessionOccurrences (watchLessonsByDateRange içinde)
/// - Parametre: DateTimeRange (ayın ilk günü ve son günü)
/// - Stream açılmadan önce aralık ensure edilir (2 dk önbellekli prune/upsert)
/// - Drift watchQuery ile SessionOccurrences değişikliklerini otomatik yakalar.
final calendarLessonsProvider =
    StreamProvider.family<Map<DateTime, List<Lesson>>, DateTimeRange>(
  (ref, dateRange) {
    final lessonsRepo = ref.watch(lessonsRepoProvider);
    final scheduleRepo = ref.watch(scheduleRepoProvider);

    return Stream.fromFuture(() async {
      await scheduleRepo.ensureOccurrencesForRange(
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
