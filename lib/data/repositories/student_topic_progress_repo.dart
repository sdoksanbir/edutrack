import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

class StudentTopicProgressRepository {
  StudentTopicProgressRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  Stream<Set<String>> watchLabels(String studentId) {
    return (_db.select(_db.studentTopicProgress)
          ..where((t) => t.studentId.equals(studentId)))
        .watch()
        .map((rows) => rows.map((r) => r.label).toSet());
  }

  Future<void> addLabel(String studentId, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    final existing = await (_db.select(_db.studentTopicProgress)
          ..where(
            (t) => t.studentId.equals(studentId) & t.label.equals(trimmed),
          ))
        .getSingleOrNull();
    if (existing != null) return;
    await _db.into(_db.studentTopicProgress).insert(
          StudentTopicProgressCompanion.insert(
            id: _uuid.v4(),
            studentId: studentId,
            label: trimmed,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> removeLabel(String studentId, String label) async {
    await (_db.delete(_db.studentTopicProgress)
          ..where(
            (t) => t.studentId.equals(studentId) & t.label.equals(label),
          ))
        .go();
  }

  Future<void> removeLabels(String studentId, Iterable<String> labels) async {
    for (final label in labels) {
      await removeLabel(studentId, label);
    }
  }

  Future<void> addLabels(String studentId, Iterable<String> labels) async {
    for (final label in labels) {
      await addLabel(studentId, label);
    }
  }

  /// Ders kayıtlarındaki anlatılan konuları progress tablosuna bir kez aktarır.
  Future<void> importFromDoneLessons(String studentId) async {
    final lessons = await (_db.select(_db.lessons)
          ..where(
            (l) => l.studentId.equals(studentId) & l.status.equals('done'),
          ))
        .get();
    for (final lesson in lessons) {
      final raw = lesson.topic?.trim();
      if (raw == null || raw.isEmpty) continue;
      for (final part in raw.split(RegExp(r'[\n·]'))) {
        final t = part.trim();
        if (t.isNotEmpty) await addLabel(studentId, t);
      }
    }
  }

  /// Konunun tamamını işaretle / kaldır.
  Future<void> toggleWholeTopic({
    required String studentId,
    required String topicName,
    required List<String> outcomeLabels,
    required bool currentlyComplete,
  }) async {
    if (currentlyComplete) {
      await removeLabel(studentId, topicName);
      await removeLabels(studentId, outcomeLabels);
    } else {
      await removeLabels(studentId, outcomeLabels);
      await addLabel(studentId, topicName);
    }
  }

  /// Tek kazanım işaretle / kaldır (konu tam ise diğerlerine parçala).
  Future<void> toggleOutcome({
    required String studentId,
    required String topicName,
    required String outcomeLabel,
    required List<String> allOutcomeLabels,
    required Set<String> current,
  }) async {
    final topicComplete = current.contains(topicName);
    final outcomeOn =
        topicComplete || current.contains(outcomeLabel);

    if (outcomeOn) {
      if (topicComplete) {
        await removeLabel(studentId, topicName);
        final keep = allOutcomeLabels.where((l) => l != outcomeLabel);
        await addLabels(studentId, keep);
      } else {
        await removeLabel(studentId, outcomeLabel);
      }
    } else {
      await addLabel(studentId, outcomeLabel);
      final next = {...current, outcomeLabel}..remove(topicName);
      if (allOutcomeLabels.every(next.contains)) {
        await removeLabels(studentId, allOutcomeLabels);
        await addLabel(studentId, topicName);
      }
    }
  }
}
