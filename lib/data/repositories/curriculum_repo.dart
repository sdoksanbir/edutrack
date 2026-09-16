import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/local/curriculum_seed.dart';
import 'package:uuid/uuid.dart';

/// Ders → Ünite → Konu → Kazanım müfredat yönetimi.
class CurriculumRepository {
  CurriculumRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  // ── Ders ──────────────────────────────────────────────
  Stream<List<CurriculumSubject>> watchSubjects() {
    return (_db.select(_db.curriculumSubjects)
          ..orderBy([
            (t) => OrderingTerm.asc(t.folder),
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<List<CurriculumSubject>> getSubjects() {
    return (_db.select(_db.curriculumSubjects)
          ..orderBy([
            (t) => OrderingTerm.asc(t.folder),
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
  }

  /// Boş klasör alanını MATEMATİK yapar (çoklu branş klasörlerini bozmaz).
  Future<void> ensureEmptyFoldersDefault() async {
    await _db.customStatement(
      "UPDATE curriculum_subjects SET folder = 'MATEMATİK' "
      "WHERE folder IS NULL OR TRIM(folder) = ''",
    );
  }

  @Deprecated('Use ensureEmptyFoldersDefault')
  Future<void> ensureSubjectsUnderMatematikFolder() =>
      ensureEmptyFoldersDefault();

  Future<String> addSubject(String name, {String folder = 'MATEMATİK'}) async {
    final id = _uuid.v4();
    await _db.into(_db.curriculumSubjects).insert(
          CurriculumSubjectsCompanion.insert(
            id: id,
            name: name.trim(),
            folder: Value(folder.trim().isEmpty ? 'MATEMATİK' : folder.trim()),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> renameSubject(String id, String name) async {
    await (_db.update(_db.curriculumSubjects)..where((t) => t.id.equals(id)))
        .write(CurriculumSubjectsCompanion(name: Value(name.trim())));
  }

  Future<void> deleteSubject(String id) async {
    final units = await getUnits(id);
    for (final u in units) {
      await deleteUnit(u.id);
    }
    await (_db.delete(_db.curriculumSubjects)..where((t) => t.id.equals(id)))
        .go();
  }

  // ── Ünite ─────────────────────────────────────────────
  Stream<List<CurriculumUnit>> watchUnits(String subjectId) {
    return (_db.select(_db.curriculumUnits)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<List<CurriculumUnit>> getUnits(String subjectId) {
    return (_db.select(_db.curriculumUnits)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
  }

  Future<String> addUnit({required String subjectId, required String name}) async {
    final id = _uuid.v4();
    await _db.into(_db.curriculumUnits).insert(
          CurriculumUnitsCompanion.insert(
            id: id,
            subjectId: subjectId,
            name: name.trim(),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> renameUnit(String id, String name) async {
    await (_db.update(_db.curriculumUnits)..where((t) => t.id.equals(id)))
        .write(CurriculumUnitsCompanion(name: Value(name.trim())));
  }

  Future<void> deleteUnit(String id) async {
    final topics = await getTopics(id);
    for (final t in topics) {
      await deleteTopic(t.id);
    }
    await (_db.delete(_db.curriculumUnits)..where((t) => t.id.equals(id))).go();
  }

  // ── Konu ──────────────────────────────────────────────
  Stream<List<CurriculumTopic>> watchTopics(String unitId) {
    return (_db.select(_db.curriculumTopics)
          ..where((t) => t.unitId.equals(unitId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<List<CurriculumTopic>> getTopics(String unitId) {
    return (_db.select(_db.curriculumTopics)
          ..where((t) => t.unitId.equals(unitId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
  }

  Future<String> addTopic({required String unitId, required String name}) async {
    final id = _uuid.v4();
    await _db.into(_db.curriculumTopics).insert(
          CurriculumTopicsCompanion.insert(
            id: id,
            unitId: unitId,
            name: name.trim(),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> renameTopic(String id, String name) async {
    await (_db.update(_db.curriculumTopics)..where((t) => t.id.equals(id)))
        .write(CurriculumTopicsCompanion(name: Value(name.trim())));
  }

  Future<void> deleteTopic(String id) async {
    await (_db.delete(_db.curriculumOutcomes)..where((t) => t.topicId.equals(id)))
        .go();
    await (_db.delete(_db.curriculumTopics)..where((t) => t.id.equals(id))).go();
  }

  // ── Kazanım ───────────────────────────────────────────
  Stream<List<CurriculumOutcome>> watchOutcomes(String topicId) {
    return (_db.select(_db.curriculumOutcomes)
          ..where((t) => t.topicId.equals(topicId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch();
  }

  Future<List<CurriculumOutcome>> getOutcomes(String topicId) {
    return (_db.select(_db.curriculumOutcomes)
          ..where((t) => t.topicId.equals(topicId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .get();
  }

  Future<String> addOutcome({
    required String topicId,
    required String name,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.curriculumOutcomes).insert(
          CurriculumOutcomesCompanion.insert(
            id: id,
            topicId: topicId,
            name: name.trim(),
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  Future<void> renameOutcome(String id, String name) async {
    await (_db.update(_db.curriculumOutcomes)..where((t) => t.id.equals(id)))
        .write(CurriculumOutcomesCompanion(name: Value(name.trim())));
  }

  Future<void> deleteOutcome(String id) async {
    await (_db.delete(_db.curriculumOutcomes)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Varsayılan müfredatı (tüm branşlar) eksikse tamamlar.
  Future<void> ensureDefaultCurriculum() async {
    await ensureEmptyFoldersDefault();
    await seedDefaultCurriculum(_db);
  }
}
