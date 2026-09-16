/// Ödev durumu sabitleri.
class HomeworkStatus {
  HomeworkStatus._();

  static const pending = 'pending';
  static const done = 'done';
  static const notDone = 'not_done';
  static const partial = 'partial';
  static const notUnderstood = 'not_understood';

  static const all = [pending, done, notDone, partial, notUnderstood];

  static const defaultDueDays = 7;

  static bool isAlert(String status) =>
      status == notDone || status == partial || status == notUnderstood;

  static bool isOverdue(String status, DateTime? dueAt) {
    if (status != pending || dueAt == null) return false;
    final endOfDue = DateTime(dueAt.year, dueAt.month, dueAt.day, 23, 59, 59);
    return DateTime.now().isAfter(endOfDue);
  }

  static bool needsAttention(
    String status,
    DateTime? dueAt, {
    bool attentionCleared = false,
  }) {
    // Anlamadı + gerekenler yapıldı → takip listesinde gösterme
    if (attentionCleared && status == notUnderstood) return false;
    return isAlert(status) || isOverdue(status, dueAt);
  }

  static DateTime defaultDueDate(DateTime assignedAt) {
    final base = DateTime(
      assignedAt.year,
      assignedAt.month,
      assignedAt.day,
    ).add(const Duration(days: defaultDueDays));
    return DateTime(base.year, base.month, base.day, 23, 59, 59);
  }
}
