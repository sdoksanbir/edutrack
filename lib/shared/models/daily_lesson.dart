import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';

/// Takvim ekranında görünen günlük ders modeli
class DailyLesson {
  final String studentId;
  final String studentName;
  final DateTime startDateTime;
  final int durationMin;
  final String? templateId; // Varsa template ID
  final String? occurrenceId; // Varsa occurrence ID

  DailyLesson({
    required this.studentId,
    required this.studentName,
    required this.startDateTime,
    required this.durationMin,
    this.templateId,
    this.occurrenceId,
  });

  /// EffectiveScheduleItem'dan oluştur
  factory DailyLesson.fromEffectiveScheduleItem(
    EffectiveScheduleItem item,
    DateTime selectedDate,
  ) {
    // startTime'ı parse et ve selectedDate ile birleştir
    final timeParts = item.startTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
      minute,
    );

    return DailyLesson(
      studentId: item.studentId,
      studentName: item.studentName,
      startDateTime: startDateTime,
      durationMin: item.durationMin,
      templateId: item.templateId,
      occurrenceId: item.occurrenceId,
    );
  }
}
