import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/lessons_repo.dart';
import 'package:ozel_ders_takip/data/repositories/payments_repo.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';

// Re-export UnpaidLesson for convenience
export 'package:ozel_ders_takip/data/repositories/payments_repo.dart' show UnpaidLesson;

/// Global ödeme özeti provider'ı (stream)
final globalPaymentSummaryProvider = StreamProvider<PaymentSummary>((ref) {
  final repo = ref.watch(lessonsRepoProvider);
  return repo.watchGlobalPaymentSummary();
});

/// Tüm öğrenciler için ödeme özeti listesi provider'ı (stream)
final studentPaymentSummariesProvider = StreamProvider<List<StudentPaymentSummary>>((ref) {
  final repo = ref.watch(lessonsRepoProvider);
  return repo.watchStudentPaymentSummaries();
});

/// İptal edilen dersler provider'ı (stream)
final cancelledLessonsProvider = StreamProvider<List<CancelledLessonInfo>>((ref) {
  final repo = ref.watch(scheduleRepoProvider);
  return repo.watchCancelledLessons();
});

/// Ertelenen dersler provider'ı (stream)
final postponedLessonsProvider = StreamProvider<List<PostponedLessonInfo>>((ref) {
  final repo = ref.watch(scheduleRepoProvider);
  return repo.watchPostponedLessons();
});

/// "Yapıldı" olan ve ödeme alınmamış dersler provider'ı (stream)
/// Ödemeler ekranında seçim için kullanılır
final doneUnpaidOccurrencesProvider = StreamProvider<List<SessionOccurrenceWithStudent>>((ref) {
  final repo = ref.watch(scheduleRepoProvider);
  return repo.watchDoneUnpaidOccurrences();
});

/// Öğrenci ödeme özeti provider'ı (stream)
final studentPaymentSummaryProvider =
    StreamProvider.family<StudentPaymentSummary, String>((ref, studentId) {
  final repo = ref.watch(lessonsRepoProvider);
  return repo.watchStudentPayments(studentId);
});

/// Öğrenci ödeme listesi provider'ı (stream)
final studentPaymentsProvider =
    StreamProvider.family<List<StudentPayment>, String>((ref, studentId) {
  final repo = ref.watch(paymentsRepoProvider);
  return repo.watchStudentPayments(studentId);
});

/// Öğrenci ödenmemiş dersleri provider'ı (stream)
final studentUnpaidLessonsProvider =
    StreamProvider.family<List<UnpaidLesson>, StudentUnpaidLessonsParams>(
  (ref, params) {
    final repo = ref.watch(paymentsRepoProvider);
    return repo.watchStudentUnpaidLessons(
      params.studentId,
      includePaid: params.includePaid,
    );
  },
);

/// Provider parametreleri
class StudentUnpaidLessonsParams {
  final String studentId;
  final bool includePaid;

  StudentUnpaidLessonsParams({
    required this.studentId,
    required this.includePaid,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentUnpaidLessonsParams &&
        other.studentId == studentId &&
        other.includePaid == includePaid;
  }

  @override
  int get hashCode => Object.hash(studentId, includePaid);
}
