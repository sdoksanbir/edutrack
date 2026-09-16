import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/services/cloud_sync_service.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';
import 'package:uuid/uuid.dart';

class StudentsRepository {
  final AppDatabase _db;
  final CloudSyncService? _cloud;
  final _uuid = const Uuid();

  StudentsRepository(this._db, [this._cloud]);

  Future<void> _syncUpsertById(String id) async {
    final cloud = _cloud;
    if (cloud == null || !cloud.canSync) return;
    final s = await getStudentById(id);
    if (s != null) await cloud.upsertStudent(s);
  }

  Stream<List<Student>> watchAllStudents({bool includeInactive = true}) {
    final query = _db.select(_db.students);
    if (!includeInactive) {
      query.where((s) => s.isActive.equals(true));
    }
    return query.watch().map(_sortStudentsTurkish);
  }

  Future<List<Student>> getAllStudents() async {
    final list = await (_db.select(_db.students)).get();
    return _sortStudentsTurkish(list);
  }

  List<Student> _sortStudentsTurkish(List<Student> list) {
    final sorted = [...list];
    sorted.sort((a, b) => compareTurkish(a.fullName, b.fullName));
    return sorted;
  }

  Future<Student?> getStudentById(String id) async {
    return await (_db.select(_db.students)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<Student?> watchStudentById(String id) {
    return (_db.select(_db.students)..where((s) => s.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<String> insertStudent({
    required String fullName,
    String? phone,
    required int hourlyRate,
    String? notes,
    String? guardianFullName,
    String? guardianPhone,
    String? bookResource,
    String? bookResourcePractice,
    String? gradeLevel,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final formattedName = formatPersonFullName(fullName);
    final formattedPhone = formatTurkishPhone(phone);
    final formattedGuardian =
        guardianFullName == null || guardianFullName.trim().isEmpty
            ? null
            : formatPersonFullName(guardianFullName);
    final formattedGuardianPhone = formatTurkishPhone(guardianPhone);
    final formattedBook = bookResource == null || bookResource.trim().isEmpty
        ? null
        : bookResource.trim();
    final formattedPractice =
        bookResourcePractice == null || bookResourcePractice.trim().isEmpty
            ? null
            : bookResourcePractice.trim();
    final grade = gradeLevel == null || gradeLevel.trim().isEmpty
        ? null
        : gradeLevel.trim();

    await _db.into(_db.students).insert(
          StudentsCompanion.insert(
            id: id,
            fullName: formattedName,
            phone: Value(formattedPhone),
            hourlyRate: hourlyRate,
            notes: Value(notes),
            guardianFullName: Value(formattedGuardian),
            guardianPhone: Value(formattedGuardianPhone),
            bookResource: Value(formattedBook),
            bookResourcePractice: Value(formattedPractice),
            gradeLevel: Value(grade),
            createdAt: now,
          ),
        );

    await _syncUpsertById(id);
    return id;
  }

  Future<void> updateStudent({
    required String id,
    String? fullName,
    String? phone,
    int? hourlyRate,
    String? notes,
    String? guardianFullName,
    String? guardianPhone,
    String? bookResource,
    String? bookResourcePractice,
    String? gradeLevel,
    bool clearGradeLevel = false,
  }) async {
    final companion = StudentsCompanion(
      fullName: fullName != null
          ? Value(formatPersonFullName(fullName))
          : const Value.absent(),
      phone: phone != null
          ? Value(formatTurkishPhone(phone))
          : const Value.absent(),
      hourlyRate: hourlyRate != null ? Value(hourlyRate) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      guardianFullName: guardianFullName != null
          ? Value(
              guardianFullName.trim().isEmpty
                  ? null
                  : formatPersonFullName(guardianFullName),
            )
          : const Value.absent(),
      guardianPhone: guardianPhone != null
          ? Value(formatTurkishPhone(guardianPhone))
          : const Value.absent(),
      bookResource: bookResource != null
          ? Value(bookResource.trim().isEmpty ? null : bookResource.trim())
          : const Value.absent(),
      bookResourcePractice: bookResourcePractice != null
          ? Value(
              bookResourcePractice.trim().isEmpty
                  ? null
                  : bookResourcePractice.trim(),
            )
          : const Value.absent(),
      gradeLevel: clearGradeLevel
          ? const Value(null)
          : gradeLevel != null
              ? Value(gradeLevel.trim().isEmpty ? null : gradeLevel.trim())
              : const Value.absent(),
    );

    await (_db.update(_db.students)..where((s) => s.id.equals(id)))
        .write(companion);
    await _syncUpsertById(id);
  }

  Future<void> deleteStudent(String id) async {
    await (_db.delete(_db.students)..where((s) => s.id.equals(id))).go();
    await _cloud?.deleteStudentRemote(id);
  }

  Future<void> setStudentActive({
    required String id,
    required bool isActive,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.students)..where((s) => s.id.equals(id)))
          .write(StudentsCompanion(isActive: Value(isActive)));

      if (!isActive) {
        final today = DateTime.now();
        final todayStr = _formatDate(today);

        await (_db.delete(_db.sessionOccurrences)
              ..where((o) =>
                  o.studentId.equals(id) &
                  o.status.equals('planned') &
                  o.date.isBiggerThanValue(todayStr)))
            .go();

        final todayOccurrences = await (_db.select(_db.sessionOccurrences)
              ..where((o) =>
                  o.studentId.equals(id) &
                  o.status.equals('planned') &
                  o.date.equals(todayStr)))
            .get();

        final now = TimeOfDay.now();
        final nowMinutes = now.hour * 60 + now.minute;

        for (final occ in todayOccurrences) {
          final timeParts = occ.startTime.split(':');
          final occHour = int.parse(timeParts[0]);
          final occMin = int.parse(timeParts[1]);
          final occMinutes = occHour * 60 + occMin;

          if (occMinutes > nowMinutes) {
            await (_db.delete(_db.sessionOccurrences)
                  ..where((o) => o.id.equals(occ.id)))
                .go();
          }
        }
      }
    });
    await _syncUpsertById(id);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
