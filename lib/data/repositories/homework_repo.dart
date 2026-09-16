import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/shared/models/homework_assignment.dart';
import 'package:ozel_ders_takip/shared/models/homework_status.dart';
import 'package:uuid/uuid.dart';

class StudentHomeworkSummary {
  final String studentId;
  final int totalCount;
  final int alertCount;

  const StudentHomeworkSummary({
    required this.studentId,
    required this.totalCount,
    required this.alertCount,
  });
}

class LessonHomeworkGroup {
  final String lessonId;
  final DateTime assignedAt;
  final List<HomeworkItem> items;

  const LessonHomeworkGroup({
    required this.lessonId,
    required this.assignedAt,
    required this.items,
  });

  int get itemCount => items.length;

  int get alertCount =>
      items.where((i) => HomeworkStatus.needsAttention(i.status, i.dueAt)).length;

  DateTime? get earliestDue {
    DateTime? earliest;
    for (final item in items) {
      final due = item.dueAt;
      if (due == null) continue;
      if (earliest == null || due.isBefore(earliest)) {
        earliest = due;
      }
    }
    return earliest;
  }
}

class HomeworkRepository {
  static const migrationKey = 'homework_items_migrated_v1';

  final AppDatabase _db;
  final _uuid = const Uuid();
  Future<void>? _migrationInFlight;

  HomeworkRepository(this._db);

  Stream<List<HomeworkItem>> watchByStudent(String studentId) {
    return (_db.select(_db.homeworkItems)
          ..where((h) => h.studentId.equals(studentId))
          ..orderBy([
            (h) => OrderingTerm(
                  expression: h.assignedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<List<LessonHomeworkGroup>> watchLessonGroupsByStudent(String studentId) {
    return watchByStudent(studentId).map(groupHomeworkByLesson);
  }

  Stream<List<HomeworkItem>> watchByLesson(String lessonId) {
    return (_db.select(_db.homeworkItems)
          ..where((h) => h.lessonId.equals(lessonId))
          ..orderBy([
            (h) => OrderingTerm(expression: h.topic),
          ]))
        .watch();
  }

  /// Tek stream: özet + uyarı sayısı türetmek için.
  Stream<List<HomeworkItem>> watchAllItems() {
    return (_db.select(_db.homeworkItems)
          ..orderBy([
            (h) => OrderingTerm(
                  expression: h.assignedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Stream<int> watchTotalAlertCount() {
    return watchAllItems()
        .map((items) => items
            .where((item) =>
                HomeworkStatus.needsAttention(item.status, item.dueAt))
            .length)
        .distinct();
  }

  Stream<Map<String, StudentHomeworkSummary>> watchStudentSummaries() {
    return watchAllItems().map((items) {
      final map = <String, StudentHomeworkSummary>{};
      for (final item in items) {
        final current = map[item.studentId];
        final alert = HomeworkStatus.needsAttention(item.status, item.dueAt);
        if (current == null) {
          map[item.studentId] = StudentHomeworkSummary(
            studentId: item.studentId,
            totalCount: 1,
            alertCount: alert ? 1 : 0,
          );
        } else {
          map[item.studentId] = StudentHomeworkSummary(
            studentId: item.studentId,
            totalCount: current.totalCount + 1,
            alertCount: current.alertCount + (alert ? 1 : 0),
          );
        }
      }
      return map;
    });
  }

  List<LessonHomeworkGroup> groupHomeworkByLesson(List<HomeworkItem> items) {
    final map = <String, List<HomeworkItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.lessonId, () => []).add(item);
    }

    final groups = map.entries.map((entry) {
      final list = List<HomeworkItem>.from(entry.value)
        ..sort((a, b) => a.topic.compareTo(b.topic));
      return LessonHomeworkGroup(
        lessonId: entry.key,
        assignedAt: list.first.assignedAt,
        items: list,
      );
    }).toList();

    groups.sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
    return groups;
  }

  Future<void> updateStatus({
    required String itemId,
    required String status,
    String? statusNote,
  }) async {
    await (_db.update(_db.homeworkItems)..where((h) => h.id.equals(itemId)))
        .write(
      HomeworkItemsCompanion(
        status: Value(status),
        statusNote:
            statusNote != null ? Value(statusNote) : const Value.absent(),
        statusChangedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateDueDate({
    required String itemId,
    required DateTime dueAt,
  }) async {
    final normalized = DateTime(dueAt.year, dueAt.month, dueAt.day, 23, 59, 59);
    await (_db.update(_db.homeworkItems)..where((h) => h.id.equals(itemId)))
        .write(
      HomeworkItemsCompanion(dueAt: Value(normalized)),
    );
  }

  Future<void> updateLessonDueDate({
    required String lessonId,
    required DateTime dueAt,
  }) async {
    final normalized = DateTime(dueAt.year, dueAt.month, dueAt.day, 23, 59, 59);
    await (_db.update(_db.homeworkItems)
          ..where((h) => h.lessonId.equals(lessonId)))
        .write(
      HomeworkItemsCompanion(dueAt: Value(normalized)),
    );
  }

  /// Eski derslerden ödevleri yalnızca bir kez aktarır (ANR engeli).
  Future<void> ensureMigratedOnce() {
    return _migrationInFlight ??= _runMigrationOnce();
  }

  Future<void> _runMigrationOnce() async {
    try {
      final flag = await (_db.select(_db.appSettings)
            ..where((s) => s.key.equals(migrationKey)))
          .getSingleOrNull();
      if (flag?.value == '1') return;

      final existingItems = await (_db.select(_db.homeworkItems)..limit(1)).get();
      if (existingItems.isEmpty) {
        await _backfillFromLessons();
      }

      await _db.into(_db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(key: migrationKey, value: '1'),
          );
    } finally {
      _migrationInFlight = null;
    }
  }

  Future<void> _backfillFromLessons() async {
    final lessons = await _db.select(_db.lessons).get();
    final now = DateTime.now();
    final companions = <HomeworkItemsCompanion>[];

    for (final lesson in lessons) {
      final hasHomework =
          (lesson.homeworkResource?.trim().isNotEmpty ?? false) ||
              (lesson.homework?.trim().isNotEmpty ?? false);
      if (!hasHomework) continue;

      final drafts = expandHomeworkItems(
        homeworkResource: lesson.homeworkResource,
        homework: lesson.homework,
      );
      final defaultDue = HomeworkStatus.defaultDueDate(lesson.startDateTime);
      for (final draft in drafts) {
        companions.add(
          HomeworkItemsCompanion.insert(
            id: _uuid.v4(),
            lessonId: lesson.id,
            studentId: lesson.studentId,
            assignedAt: lesson.startDateTime,
            resource: Value(draft.resource),
            topic: draft.topic,
            detail: Value(draft.detail),
            status: const Value(HomeworkStatus.pending),
            dueAt: Value(defaultDue),
            createdAt: now,
          ),
        );
      }
    }

    if (companions.isEmpty) return;

    // Tek transaction + batch: UI thread'i binlerce kez uyandırmaz.
    await _db.batch((batch) {
      batch.insertAll(_db.homeworkItems, companions);
    });
  }

  /// Ders kaydı değişince ödevleri günceller.
  /// Değişiklik yoksa yazma yapmaz (stream fırtınasını önler).
  Future<void> syncFromLesson({
    required String lessonId,
    required String studentId,
    required DateTime assignedAt,
    String? homework,
    String? homeworkResource,
  }) async {
    final drafts = expandHomeworkItems(
      homeworkResource: homeworkResource,
      homework: homework,
    );

    final existing = await (_db.select(_db.homeworkItems)
          ..where((h) => h.lessonId.equals(lessonId)))
        .get();

    if (drafts.isEmpty) {
      if (existing.isEmpty) return;
      await (_db.delete(_db.homeworkItems)
            ..where((h) => h.lessonId.equals(lessonId)))
          .go();
      return;
    }

    final existingByKey = {
      for (final item in existing)
        homeworkItemKey(item.resource, item.topic): item,
    };
    final draftKeys = <String>{};
    final defaultDue = HomeworkStatus.defaultDueDate(assignedAt);
    final now = DateTime.now();

    final toInsert = <HomeworkItemsCompanion>[];
    final toUpdate = <({String id, HomeworkItemsCompanion data})>[];
    final keepIds = <String>{};

    for (final draft in drafts) {
      final key = homeworkItemKey(draft.resource, draft.topic);
      draftKeys.add(key);
      final prev = existingByKey[key];
      if (prev == null) {
        toInsert.add(
          HomeworkItemsCompanion.insert(
            id: _uuid.v4(),
            lessonId: lessonId,
            studentId: studentId,
            assignedAt: assignedAt,
            resource: Value(draft.resource),
            topic: draft.topic,
            detail: Value(draft.detail),
            status: const Value(HomeworkStatus.pending),
            dueAt: Value(defaultDue),
            createdAt: now,
          ),
        );
        continue;
      }

      keepIds.add(prev.id);
      final detailChanged = (prev.detail ?? '') != (draft.detail ?? '');
      final assignedChanged = prev.assignedAt != assignedAt;
      final studentChanged = prev.studentId != studentId;
      if (detailChanged || assignedChanged || studentChanged) {
        toUpdate.add((
          id: prev.id,
          data: HomeworkItemsCompanion(
            assignedAt: assignedChanged ? Value(assignedAt) : const Value.absent(),
            studentId: studentChanged ? Value(studentId) : const Value.absent(),
            detail: detailChanged ? Value(draft.detail) : const Value.absent(),
            resource: Value(draft.resource),
            topic: Value(draft.topic),
          ),
        ));
      }
    }

    final toDeleteIds = existing
        .where((e) => !keepIds.contains(e.id))
        .map((e) => e.id)
        .toList();

    if (toInsert.isEmpty && toUpdate.isEmpty && toDeleteIds.isEmpty) {
      return; // hiçbir DB yazması yok
    }

    await _db.transaction(() async {
      if (toDeleteIds.isNotEmpty) {
        await (_db.delete(_db.homeworkItems)
              ..where((h) => h.id.isIn(toDeleteIds)))
            .go();
      }
      for (final u in toUpdate) {
        await (_db.update(_db.homeworkItems)..where((h) => h.id.equals(u.id)))
            .write(u.data);
      }
      if (toInsert.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.homeworkItems, toInsert);
        });
      }
    });
  }
}
