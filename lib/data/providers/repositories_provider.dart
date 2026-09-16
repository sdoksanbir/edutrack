import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/providers/database_provider.dart';
import 'package:ozel_ders_takip/data/repositories/students_repo.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';
import 'package:ozel_ders_takip/data/repositories/lessons_repo.dart';
import 'package:ozel_ders_takip/data/repositories/attachments_repo.dart';
import 'package:ozel_ders_takip/data/repositories/app_settings_repo.dart';
import 'package:ozel_ders_takip/data/repositories/payments_repo.dart';
import 'package:ozel_ders_takip/data/repositories/curriculum_repo.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:ozel_ders_takip/data/repositories/todos_repo.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';

final studentsRepoProvider = Provider<StudentsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StudentsRepository(db);
});

final scheduleRepoProvider = Provider<ScheduleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ScheduleRepository(db);
});

final lessonsRepoProvider = Provider<LessonsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LessonsRepository(db);
});

final attachmentsRepoProvider = Provider<AttachmentsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AttachmentsRepository(db);
});

final appSettingsRepoProvider = Provider<AppSettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return AppSettingsRepository(db);
});

final paymentsRepoProvider = Provider<PaymentsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PaymentsRepository(db);
});

final curriculumRepoProvider = Provider<CurriculumRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CurriculumRepository(db);
});

final homeworkRepoProvider = Provider<HomeworkRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HomeworkRepository(db);
});

final todosRepoProvider = Provider<TodosRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TodosRepository(db);
});


final homeworkStudentSummariesProvider =
    StreamProvider<Map<String, StudentHomeworkSummary>>((ref) {
  return ref.watch(homeworkRepoProvider).watchStudentSummaries();
});

/// Aynı stream'den türetilir — ikinci bir DB watch açılmaz.
final homeworkAlertCountProvider = Provider<int>((ref) {
  final summaries = ref.watch(homeworkStudentSummariesProvider).asData?.value;
  if (summaries == null) return 0;
  var total = 0;
  for (final summary in summaries.values) {
    total = total + summary.alertCount;
  }
  return total;
});

/// Dersler için stream provider parametreleri
class LessonsStreamParams {
  final DateTime? from;
  final DateTime? to;
  final String? studentId;

  LessonsStreamParams({
    this.from,
    this.to,
    this.studentId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LessonsStreamParams) return false;
    
    // DateTime karşılaştırması - sadece tarih kısmını karşılaştır
    bool fromEqual = (from == null && other.from == null) ||
        (from != null && other.from != null && 
         from!.year == other.from!.year &&
         from!.month == other.from!.month &&
         from!.day == other.from!.day);
    
    bool toEqual = (to == null && other.to == null) ||
        (to != null && other.to != null && 
         to!.year == other.to!.year &&
         to!.month == other.to!.month &&
         to!.day == other.to!.day);
    
    return fromEqual && toEqual && studentId == other.studentId;
  }

  @override
  int get hashCode {
    int fromHash = from != null 
        ? Object.hash(from!.year, from!.month, from!.day)
        : 0;
    int toHash = to != null 
        ? Object.hash(to!.year, to!.month, to!.day)
        : 0;
    return Object.hash(fromHash, toHash, studentId);
  }
}

/// Dersler için stream provider (filtreleme ile)
final lessonsStreamProvider = StreamProvider.family<List<Lesson>, LessonsStreamParams>(
  (ref, params) {
    final repo = ref.watch(lessonsRepoProvider);
    return repo.watchLessons(
      from: params.from,
      to: params.to,
      studentId: params.studentId,
    );
  },
);
