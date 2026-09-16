import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:uuid/uuid.dart';

class StudentsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  StudentsRepository(this._db);

  /// Tüm öğrencileri stream olarak döndürür (pasif öğrenciler dahil)
  Stream<List<Student>> watchAllStudents({bool includeInactive = true}) {
    final query = _db.select(_db.students);
    if (!includeInactive) {
      query..where((s) => s.isActive.equals(true));
    }
    return (query..orderBy([(s) => OrderingTerm(expression: s.fullName)]))
        .watch();
  }

  /// Tüm öğrencileri liste olarak döndürür
  Future<List<Student>> getAllStudents() async {
    return await (_db.select(_db.students)
          ..orderBy([(s) => OrderingTerm(expression: s.fullName)]))
        .get();
  }

  /// ID'ye göre öğrenci getirir
  Future<Student?> getStudentById(String id) async {
    return await (_db.select(_db.students)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// ID'ye göre öğrenciyi stream olarak döndürür
  Stream<Student?> watchStudentById(String id) {
    return (_db.select(_db.students)
          ..where((s) => s.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Yeni öğrenci ekler
  Future<String> insertStudent({
    required String fullName,
    String? phone,
    required int hourlyRate,
    String? notes,
    String? guardianFullName,
    String? guardianPhone,
    String? bookResource,
    String? bookResourcePractice,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final formattedName = formatPersonFullName(fullName);
    final formattedGuardian = guardianFullName == null || guardianFullName.trim().isEmpty
        ? null
        : formatPersonFullName(guardianFullName);
    final formattedBook = bookResource == null || bookResource.trim().isEmpty
        ? null
        : bookResource.trim();
    final formattedPractice =
        bookResourcePractice == null || bookResourcePractice.trim().isEmpty
            ? null
            : bookResourcePractice.trim();

    await _db.into(_db.students).insert(
          StudentsCompanion.insert(
            id: id,
            fullName: formattedName,
            phone: Value(phone),
            hourlyRate: hourlyRate,
            notes: Value(notes),
            guardianFullName: Value(formattedGuardian),
            guardianPhone: Value(guardianPhone),
            bookResource: Value(formattedBook),
            bookResourcePractice: Value(formattedPractice),
            createdAt: now,
          ),
        );

    return id;
  }

  /// Öğrenci günceller
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
  }) async {
    final companion = StudentsCompanion(
      fullName: fullName != null
          ? Value(formatPersonFullName(fullName))
          : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
      hourlyRate: hourlyRate != null ? Value(hourlyRate) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      guardianFullName: guardianFullName != null
          ? Value(
              guardianFullName.trim().isEmpty
                  ? null
                  : formatPersonFullName(guardianFullName),
            )
          : const Value.absent(),
      guardianPhone: guardianPhone != null ? Value(guardianPhone) : const Value.absent(),
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
    );

    await (_db.update(_db.students)..where((s) => s.id.equals(id)))
        .write(companion);
  }

  /// Öğrenci siler
  Future<void> deleteStudent(String id) async {
    await (_db.delete(_db.students)..where((s) => s.id.equals(id))).go();
  }

  /// Öğrenciyi aktif/pasif yapar ve ilerideki dersleri kaldırır
  Future<void> setStudentActive({
    required String id,
    required bool isActive,
  }) async {
    await _db.transaction(() async {
      // Öğrenci durumunu güncelle
      await (_db.update(_db.students)..where((s) => s.id.equals(id)))
          .write(StudentsCompanion(isActive: Value(isActive)));

      // Eğer pasif yapılıyorsa, ilerideki tüm planned occurrence'ları sil
      if (!isActive) {
        final today = DateTime.now();
        final todayStr = _formatDate(today);
        
        // Bugünden sonraki planned occurrence'ları sil
        await (_db.delete(_db.sessionOccurrences)
              ..where((o) => 
                  o.studentId.equals(id) &
                  o.status.equals('planned') &
                  o.date.isBiggerThanValue(todayStr)))
            .go();
        
        // Ayrıca bugünkü planned occurrence'ları da sil (gelecek saatlerde olanlar)
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
          
          // Eğer ders henüz başlamadıysa sil
          if (occMinutes > nowMinutes) {
            await (_db.delete(_db.sessionOccurrences)
                  ..where((o) => o.id.equals(occ.id)))
                .go();
          }
        }
      }
    });
  }

  /// Tarih formatı: 'YYYY-MM-DD'
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
