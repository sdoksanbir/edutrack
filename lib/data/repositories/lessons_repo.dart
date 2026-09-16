import 'dart:async';
import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:uuid/uuid.dart';

/// Ödeme özeti (global)
class PaymentSummary {
  final int totalExpected; // Toplam beklenen ücret
  final int totalPaid; // Toplam ödenen miktar
  final int totalDue; // Kalan borç (negatif olabilir = alacaklı)

  PaymentSummary({
    required this.totalExpected,
    required this.totalPaid,
    required this.totalDue,
  });
}

/// Öğrenci bazlı ödeme özeti
class StudentPaymentSummary {
  final String studentId;
  final String studentName;
  final int totalExpected;
  final int totalPaid;
  final int totalDue; // Kalan borç (negatif olabilir = alacaklı)
  final DateTime? lastLessonDate; // Son ders tarihi
  final DateTime? lastPaymentDate; // Son ödeme tarihi

  StudentPaymentSummary({
    required this.studentId,
    required this.studentName,
    required this.totalExpected,
    required this.totalPaid,
    required this.totalDue,
    this.lastLessonDate,
    this.lastPaymentDate,
  });
}

class LessonsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();
  final ScheduleRepository _scheduleRepo;
  final HomeworkRepository _homeworkRepo;

  LessonsRepository(this._db, [HomeworkRepository? homeworkRepo])
      : _scheduleRepo = ScheduleRepository(_db),
        _homeworkRepo = homeworkRepo ?? HomeworkRepository(_db);

  /// Schedule'dan ders kaydı oluşturur
  Future<String> createLessonFromSchedule({
    required String studentId,
    required DateTime startDateTime,
    required int durationMin,
    required int hourlyRate,
    String? topic,
    String? homework,
    String? homeworkResource,
    int? feePaidAmount,
    String? note,
  }) async {
    // feeExpected = round(hourlyRate * durationMin / 60)
    final feeExpected = ((hourlyRate * durationMin) / 60).round();

    return insertLesson(
      studentId: studentId,
      startDateTime: startDateTime,
      durationMin: durationMin,
      topic: topic,
      homework: homework,
      homeworkResource: homeworkResource,
      feeExpected: feeExpected,
      feePaidAmount: feePaidAmount ?? 0,
      note: note,
    );
  }

  /// Ders ekler
  Future<String> insertLesson({
    required String studentId,
    required DateTime startDateTime,
    required int durationMin,
    String? topic,
    String? homework,
    String? homeworkResource,
    required int feeExpected,
    int feePaidAmount = 0,
    String? note,
    String? lessonNotes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            studentId: studentId,
            occurrenceId: const Value.absent(),
            startDateTime: startDateTime,
            durationMin: durationMin,
            topic: Value(topic),
            homework: Value(homework),
            homeworkResource: homeworkResource != null
                ? Value(homeworkResource)
                : const Value.absent(),
            feeExpected: feeExpected,
            feePaidAmount: feePaidAmount,
            note: Value(note),
            lessonNotes: lessonNotes != null ? Value(lessonNotes) : const Value.absent(),
            createdAt: now,
          ),
        );

    await _homeworkRepo.syncFromLesson(
      lessonId: id,
      studentId: studentId,
      assignedAt: startDateTime,
      homework: homework,
      homeworkResource: homeworkResource,
    );

    return id;
  }

  /// Dersleri stream olarak izler (filtreleme ile)
  Stream<List<Lesson>> watchLessons({
    DateTime? from,
    DateTime? to,
    String? studentId,
  }) {
    var query = _db.select(_db.lessons);

    // Filtreleme
    if (from != null) {
      query = query..where((l) => l.startDateTime.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query = query..where((l) => l.startDateTime.isSmallerOrEqualValue(to));
    }
    if (studentId != null) {
      query = query..where((l) => l.studentId.equals(studentId));
    }

    // Sıralama
    query = query
      ..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.desc)]);

    return query.watch();
  }

  /// Tüm dersleri getirir (debug için)
  Future<List<Lesson>> getAllLessons() async {
    return await (_db.select(_db.lessons)
          ..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.desc)]))
        .get();
  }

  /// Öğrenciye ait dersleri getirir
  Future<List<Lesson>> getLessonsByStudent(String studentId) async {
    return await (_db.select(_db.lessons)
          ..where((l) => l.studentId.equals(studentId))
          ..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.desc)]))
        .get();
  }

  /// Öğrenciye ait dersleri stream olarak izler. [status] ile filtre: 'done' | 'not_done' | 'missed' | 'postponed'
  Stream<List<Lesson>> watchLessonsByStudent(String studentId, {String? status}) {
    var query = _db.select(_db.lessons);
    if (status == null) {
      query = query..where((l) => l.studentId.equals(studentId));
    } else if (status == 'not_done' || status == 'missed') {
      query = query..where((l) => l.studentId.equals(studentId) & (l.status.equals('not_done') | l.status.equals('missed')));
    } else {
      query = query..where((l) => l.studentId.equals(studentId) & l.status.equals(status));
    }
    query = query..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.desc)]);
    return query.watch();
  }

  /// SessionOccurrences'daki status='missed' kayıtlarını Lesson formatında döndürür (Dersler > Yapılmayan sekmesi için).
  Stream<List<Lesson>> watchMissedOccurrencesAsLessons(String studentId) {
    final query = _db.select(_db.sessionOccurrences)
      ..where((o) => o.studentId.equals(studentId) & o.status.equals('missed'))
      ..orderBy([
        (o) => OrderingTerm(expression: o.date, mode: OrderingMode.desc),
        (o) => OrderingTerm(expression: o.startTime, mode: OrderingMode.desc),
      ]);
    return query.watch().map((occurrences) {
      return occurrences.map((o) => _sessionOccurrenceToLesson(o)).toList();
    });
  }

  /// Yapılmayan sekmesi: Lessons tablosu + SessionOccurrences (missed) birleşik stream.
  Stream<List<Lesson>> watchLessonsByStudentIncludingMissedOccurrences(String studentId) {
    final fromLessons = watchLessonsByStudent(studentId, status: 'missed');
    final fromOccurrences = watchMissedOccurrencesAsLessons(studentId);
    final controller = StreamController<List<Lesson>>.broadcast(sync: true);
    List<Lesson> lessons = [];
    List<Lesson> occLessons = [];
    void emit() {
      final merged = <Lesson>[...lessons, ...occLessons];
      merged.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      controller.add(merged);
    }
    StreamSubscription? sub1, sub2;
    sub1 = fromLessons.listen((list) {
      lessons = list;
      emit();
    });
    sub2 = fromOccurrences.listen((list) {
      occLessons = list;
      emit();
    });
    controller.onCancel = () {
      sub1?.cancel();
      sub2?.cancel();
    };
    return controller.stream;
  }

  Lesson _sessionOccurrenceToLesson(SessionOccurrence o) {
    final dateParts = o.date.split('-');
    final timeParts = o.startTime.split(':');
    final startDateTime = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    String? statusReasonSource;
    if (o.notDoneReasonType == 'teacher_cancelled') {
      statusReasonSource = 'TEACHER';
    } else if (o.notDoneReasonType == 'student_cancelled') {
      statusReasonSource = 'STUDENT';
    }
    final parsed = CancelledLessonInfo.parseReasonNote(o.notDoneReasonNote);
    return Lesson(
      id: 'occ_${o.id}',
      studentId: o.studentId,
      occurrenceId: o.id,
      startDateTime: startDateTime,
      durationMin: o.durationMin,
      topic: null,
      homework: null,
      feeExpected: 0,
      feePaidAmount: 0,
      note: parsed.note,
      lessonNotes: null,
      status: 'missed',
      statusReason: parsed.reason,
      statusReasonSource: statusReasonSource,
      statusChangedAt: null,
      createdAt: o.createdAt,
    );
  }

  /// ID'ye göre ders getirir
  Future<Lesson?> getLessonById(String lessonId) async {
    return await (_db.select(_db.lessons)
          ..where((l) => l.id.equals(lessonId)))
        .getSingleOrNull();
  }

  /// Occurrence'a bağlı ders kaydını getirir
  Future<Lesson?> getLessonByOccurrenceId(String occurrenceId) async {
    return await (_db.select(_db.lessons)
          ..where((l) => l.occurrenceId.equals(occurrenceId)))
        .getSingleOrNull();
  }

  /// Belirli bir ders için LessonPayments'tan toplam ödenen miktarı hesaplar
  Future<int> getLessonPaidAmount(String lessonId) async {
    final rows = await (_db.selectOnly(_db.lessonPayments)
          ..addColumns([_db.lessonPayments.appliedAmount.sum()])
          ..where(_db.lessonPayments.lessonId.equals(lessonId)))
        .get();
    return rows.isEmpty
        ? 0
        : rows.first.read(_db.lessonPayments.appliedAmount.sum()) ?? 0;
  }

  /// Birden fazla ders için ödenen miktarları toplu olarak hesaplar
  /// Returns: Map<lessonId, paidAmount>
  Future<Map<String, int>> getLessonsPaidAmounts(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return {};
    
    final rows = await (_db.selectOnly(_db.lessonPayments)
          ..addColumns([
            _db.lessonPayments.lessonId,
            _db.lessonPayments.appliedAmount.sum(),
          ])
          ..where(_db.lessonPayments.lessonId.isIn(lessonIds))
          ..groupBy([_db.lessonPayments.lessonId]))
        .get();
    
    final result = <String, int>{};
    for (final row in rows) {
      final lessonId = row.read(_db.lessonPayments.lessonId)!;
      final paid = row.read(_db.lessonPayments.appliedAmount.sum()) ?? 0;
      result[lessonId] = paid;
    }
    
    // Ödeme kaydı olmayan dersler için 0 ekle
    for (final lessonId in lessonIds) {
      result.putIfAbsent(lessonId, () => 0);
    }
    
    return result;
  }

  /// Global ödeme özeti (tüm dersler için) - Stream
  /// TEK VERİ KAYNAĞI: SessionOccurrences (status='done')
  /// - totalExpected: Tüm done occurrence'ların ücret toplamı (student.hourlyRate * durationMin / 60)
  /// - totalPaid: paymentId IS NOT NULL olan done occurrence'ların ücret toplamı
  /// - totalDue: paymentId IS NULL olan done occurrence'ların ücret toplamı (ALACAK)
  Stream<PaymentSummary> watchGlobalPaymentSummary() {
    // SessionOccurrences'dan done occurrence'ları al
    final occurrencesQuery = _db.select(_db.sessionOccurrences)
      ..where((o) => o.status.equals('done'));

    return occurrencesQuery.watch().asyncMap((occurrences) async {
      if (occurrences.isEmpty) {
        return PaymentSummary(
          totalExpected: 0,
          totalPaid: 0,
          totalDue: 0,
        );
      }

      // Öğrenci ID'lerini topla
      final studentIds = occurrences.map((o) => o.studentId).toSet().toList();
      
      // Tüm öğrencileri bir kerede çek
      final students = await (_db.select(_db.students)
            ..where((s) => s.id.isIn(studentIds)))
          .get();
      
      final studentMap = {for (var s in students) s.id: s};

      int totalExpected = 0;
      int totalPaid = 0;

      for (final occurrence in occurrences) {
        final student = studentMap[occurrence.studentId];
        if (student == null) continue;

        // Ücret hesapla: (hourlyRate * durationMin) / 60
        final feeExpected = ((student.hourlyRate * occurrence.durationMin) / 60).round();
        totalExpected += feeExpected;

        // Eğer paymentId varsa, ödenmiş sayılır
        if (occurrence.paymentId != null) {
          totalPaid += feeExpected;
        }
      }

      final totalDue = totalExpected - totalPaid;

      return PaymentSummary(
        totalExpected: totalExpected,
        totalPaid: totalPaid,
        totalDue: totalDue, // paymentId IS NULL olan done occurrence'lar = ALACAK
      );
    });
  }

  /// Tüm öğrenciler için ödeme özeti listesi - Stream
  /// TEK VERİ KAYNAĞI: SessionOccurrences (status='done')
  /// Öğrenci bazlı hesaplama: done occurrence'ların ücret toplamı
  Stream<List<StudentPaymentSummary>> watchStudentPaymentSummaries() {
    // SessionOccurrences'dan done occurrence'ları al
    final occurrencesQuery = _db.select(_db.sessionOccurrences)
      ..where((o) => o.status.equals('done'));

    // Payments tablosundan son ödeme tarihi
    final lastPaymentQuery = _db.selectOnly(_db.payments)
      ..addColumns([
        _db.payments.studentId,
        _db.payments.paidAt.max(),
      ])
      ..groupBy([_db.payments.studentId]);

    return occurrencesQuery.watch().asyncMap((occurrences) async {
      if (occurrences.isEmpty) {
        return <StudentPaymentSummary>[];
      }

      // Öğrenci ID'lerini topla
      final studentIds = occurrences.map((o) => o.studentId).toSet().toList();
      
      // Tüm öğrencileri bir kerede çek
      final students = await (_db.select(_db.students)
            ..where((s) => s.id.isIn(studentIds)))
          .get();
      
      final studentMap = {for (var s in students) s.id: s};

      // Öğrenci bazlı hesaplama
      final studentDataMap = <String, Map<String, dynamic>>{};

      for (final occurrence in occurrences) {
        final student = studentMap[occurrence.studentId];
        if (student == null) continue;

        // Ücret hesapla: (hourlyRate * durationMin) / 60
        final feeExpected = ((student.hourlyRate * occurrence.durationMin) / 60).round();

        if (!studentDataMap.containsKey(student.id)) {
          // Tarih parse et (son ders tarihi için)
          final dateParts = occurrence.date.split('-');
          final timeParts = occurrence.startTime.split(':');
          final lastLessonDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          studentDataMap[student.id] = {
            'studentId': student.id,
            'studentName': student.fullName,
            'totalExpected': feeExpected,
            'totalPaid': occurrence.paymentId != null ? feeExpected : 0,
            'lastLessonDate': lastLessonDate,
          };
        } else {
          final data = studentDataMap[student.id]!;
          data['totalExpected'] = (data['totalExpected'] as int) + feeExpected;
          if (occurrence.paymentId != null) {
            data['totalPaid'] = (data['totalPaid'] as int) + feeExpected;
          }

          // Son ders tarihini güncelle
          final dateParts = occurrence.date.split('-');
          final timeParts = occurrence.startTime.split(':');
          final lessonDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          final currentLast = data['lastLessonDate'] as DateTime;
          if (lessonDate.isAfter(currentLast)) {
            data['lastLessonDate'] = lessonDate;
          }
        }
      }

      // Son ödeme tarihlerini al
      final lastPaymentRows = await lastPaymentQuery.get();
      final lastPaymentMap = <String, DateTime?>{};
      for (final row in lastPaymentRows) {
        final studentId = row.read(_db.payments.studentId)!;
        lastPaymentMap[studentId] = row.read(_db.payments.paidAt.max());
      }

      // Her öğrenci için özet oluştur
      return studentDataMap.values.map((data) {
        final studentId = data['studentId'] as String;
        final totalExpected = data['totalExpected'] as int;
        final totalPaid = data['totalPaid'] as int;
        final totalDue = totalExpected - totalPaid;

        return StudentPaymentSummary(
          studentId: studentId,
          studentName: data['studentName'] as String,
          totalExpected: totalExpected,
          totalPaid: totalPaid,
          totalDue: totalDue, // paymentId IS NULL olan done occurrence'lar = ALACAK
          lastLessonDate: data['lastLessonDate'] as DateTime?,
          lastPaymentDate: lastPaymentMap[studentId],
        );
      }).toList();
    });
  }

  /// Belirli bir öğrenci için ödeme özeti - Stream
  /// TEK VERİ KAYNAĞI: SessionOccurrences (status='done')
  Stream<StudentPaymentSummary> watchStudentPayments(String studentId) {
    // Öğrenci bilgisini al
    final studentQuery = _db.selectOnly(_db.students)
      ..addColumns([_db.students.id, _db.students.fullName, _db.students.hourlyRate])
      ..where(_db.students.id.equals(studentId));

    // SessionOccurrences'dan done occurrence'ları al
    final occurrencesQuery = _db.select(_db.sessionOccurrences)
      ..where(
        (o) => o.status.equals('done') & o.studentId.equals(studentId),
      );

    // Öğrencinin son ödeme tarihi
    final lastPaymentQuery = _db.selectOnly(_db.payments)
      ..addColumns([_db.payments.paidAt.max()])
      ..where(_db.payments.studentId.equals(studentId));

    return studentQuery.watch().asyncExpand((studentRows) {
      if (studentRows.isEmpty) {
        return Stream<StudentPaymentSummary>.value(StudentPaymentSummary(
          studentId: studentId,
          studentName: 'Bilinmeyen',
          totalExpected: 0,
          totalPaid: 0,
          totalDue: 0,
        ));
      }

      final student = studentRows.first;
      final studentName = student.read(_db.students.fullName)!;
      final hourlyRate = student.read(_db.students.hourlyRate)!;

      // İki stream'i birleştir: occurrences ve lastPayment
      return occurrencesQuery.watch().asyncExpand((occurrences) {
        int totalExpected = 0;
        int totalPaid = 0;
        DateTime? lastLessonDate;

        for (final occurrence in occurrences) {
          // Ücret hesapla: (hourlyRate * durationMin) / 60
          final feeExpected = ((hourlyRate * occurrence.durationMin) / 60).round();
          totalExpected += feeExpected;

          // Eğer paymentId varsa, ödenmiş sayılır
          if (occurrence.paymentId != null) {
            totalPaid += feeExpected;
          }

          // Son ders tarihini güncelle
          final dateParts = occurrence.date.split('-');
          final timeParts = occurrence.startTime.split(':');
          final lessonDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          if (lastLessonDate == null || lessonDate.isAfter(lastLessonDate)) {
            lastLessonDate = lessonDate;
          }
        }

        // lastPayment stream'ini map ile birleştir
        return lastPaymentQuery.watch().map((lastPaymentRows) {
          final lastPaymentDate = lastPaymentRows.isEmpty
              ? null
              : lastPaymentRows.first.read(_db.payments.paidAt.max());
          final totalDue = totalExpected - totalPaid;

          return StudentPaymentSummary(
            studentId: studentId,
            studentName: studentName,
            totalExpected: totalExpected,
            totalPaid: totalPaid,
            totalDue: totalDue, // paymentId IS NULL olan done occurrence'lar = ALACAK
            lastLessonDate: lastLessonDate,
            lastPaymentDate: lastPaymentDate,
          );
        });
      });
    });
  }

  /// Öğrenci için ödeme özeti hesaplar (getStudentPaymentSummary alias) - Deprecated
  /// Yeni kod için watchStudentPayments kullanın
  @Deprecated('Use watchStudentPayments instead')
  Future<PaymentSummary> getStudentPaymentSummary(String studentId) async {
    return getPaymentSummary(studentId);
  }

  /// Öğrenci için ödeme özeti hesaplar - Deprecated
  /// Yeni kod için watchStudentPayments kullanın
  @Deprecated('Use watchStudentPayments instead')
  Future<PaymentSummary> getPaymentSummary(String studentId) async {
    final lessons = await (_db.select(_db.lessons)
          ..where((l) => l.studentId.equals(studentId)))
        .get();

    int totalExpected = 0;
    int totalPaid = 0;

    for (final lesson in lessons) {
      totalExpected += lesson.feeExpected;
      totalPaid += lesson.feePaidAmount;
    }

    return PaymentSummary(
      totalExpected: totalExpected,
      totalPaid: totalPaid,
      totalDue: totalExpected - totalPaid,
    );
  }

  /// Tüm öğrenciler için ödeme özeti listesi (stream) - Deprecated
  /// Yeni kod için watchStudentPaymentSummaries kullanın
  @Deprecated('Use watchStudentPaymentSummaries instead')
  Stream<List<StudentPaymentSummary>> watchAllStudentsPaymentSummary() {
    return watchStudentPaymentSummaries();
  }

  /// Ders günceller
  Future<void> updateLesson({
    required String id,
    DateTime? startDateTime,
    int? durationMin,
    String? topic,
    String? homework,
    String? lessonNotes,
    int? feeExpected,
    int? feePaidAmount,
    String? note,
    String? status,
  }) async {
    final companion = LessonsCompanion(
      startDateTime:
          startDateTime != null ? Value(startDateTime) : const Value.absent(),
      durationMin:
          durationMin != null ? Value(durationMin) : const Value.absent(),
      topic: topic != null ? Value(topic) : const Value.absent(),
      homework: homework != null ? Value(homework) : const Value.absent(),
      lessonNotes: lessonNotes != null ? Value(lessonNotes) : const Value.absent(),
      feeExpected:
          feeExpected != null ? Value(feeExpected) : const Value.absent(),
      feePaidAmount:
          feePaidAmount != null ? Value(feePaidAmount) : const Value.absent(),
      note: note != null ? Value(note) : const Value.absent(),
      status: status != null ? Value(status) : const Value.absent(),
    );

    await (_db.update(_db.lessons)..where((l) => l.id.equals(id)))
        .write(companion);
  }

  /// Ders durumunu günceller
  Future<void> updateLessonStatus({
    required String lessonId,
    String? status, // 'done' | 'not_done' | 'postponed' | null
  }) async {
    final companion = LessonsCompanion(
      status: status != null ? Value(status) : const Value.absent(),
    );

    await (_db.update(_db.lessons)..where((l) => l.id.equals(lessonId)))
        .write(companion);
  }

  /// Konu, ödev, ödev kaynağı ve ders notunu günceller
  Future<void> updateLessonNotes({
    required String lessonId,
    String? topic,
    String? homework,
    String? homeworkResource,
    String? lessonNotes,
  }) async {
    final companion = LessonsCompanion(
      topic: topic != null ? Value(topic) : const Value.absent(),
      homework: homework != null ? Value(homework) : const Value.absent(),
      homeworkResource: homeworkResource != null
          ? Value(homeworkResource)
          : const Value.absent(),
      lessonNotes: lessonNotes != null ? Value(lessonNotes) : const Value.absent(),
    );
    await (_db.update(_db.lessons)..where((l) => l.id.equals(lessonId)))
        .write(companion);

    final lesson = await (_db.select(_db.lessons)
          ..where((l) => l.id.equals(lessonId)))
        .getSingleOrNull();
    if (lesson != null) {
      await _homeworkRepo.syncFromLesson(
        lessonId: lessonId,
        studentId: lesson.studentId,
        assignedAt: lesson.startDateTime,
        homework: lesson.homework,
        homeworkResource: lesson.homeworkResource,
      );
    }
  }

  /// Ders durumunu sebep/kaynak ile günceller (ertelendi / yapılmadı)
  Future<void> updateLessonStatusWithReason({
    required String lessonId,
    required String status, // 'postponed' | 'not_done' (missed)
    required String source, // 'TEACHER' | 'STUDENT'
    required String reason,
    String? note,
    required DateTime statusChangedAt,
  }) async {
    final companion = LessonsCompanion(
      status: Value(status),
      statusReason: Value(reason),
      statusReasonSource: Value(source),
      statusChangedAt: Value(statusChangedAt),
      note: note != null ? Value(note) : const Value.absent(),
    );
    await (_db.update(_db.lessons)..where((l) => l.id.equals(lessonId)))
        .write(companion);
  }

  /// Bu dersten önceki en son dersi döndürür (aynı öğrenci, startDateTime < beforeDateTime)
  Future<Lesson?> getPreviousLesson(String studentId, DateTime beforeDateTime) async {
    final rows = await (_db.select(_db.lessons)
          ..where((l) =>
              l.studentId.equals(studentId) &
              l.startDateTime.isSmallerThanValue(beforeDateTime))
          ..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.desc)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.single;
  }

  /// Belirli bir gün için dersleri getirir (tarih bazında)
  /// TEK VERİ KAYNAĞI: SessionOccurrences
  /// Returns: Map[DateTime (sadece tarih), List[Lesson]]
  /// Lesson formatına dönüştürülmüş SessionOccurrences döner
  Stream<Map<DateTime, List<Lesson>>> watchLessonsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );

    // Tarih string formatları
    final startDateStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endDateStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    
    // SADECE SessionOccurrences kullan - TEK VERİ KAYNAĞI
    // Stream olarak izle - status değişikliklerini otomatik yakala
    final occurrencesQuery = _db.select(_db.sessionOccurrences)
      ..where((o) => 
          o.date.isBiggerOrEqualValue(startDateStr) &
          o.date.isSmallerOrEqualValue(endDateStr));

    // Stream olarak izle - her değişiklikte otomatik güncellenir
    return occurrencesQuery.watch().asyncMap((occurrences) async {
      // SessionOccurrences'dan Lesson formatına dönüştür
      // Pasif haftalık şablonlara ait planlanan dersleri gösterme (orphan).
      // Tekil (extra) ve done/missed kayıtlar korunur.
      final lessonList = <Lesson>[];

      // Template ve extra override cache
      final templateCache = <String, ScheduleTemplate?>{};
      final extraOverrideDates = <String>{}; // 'templateId|date'

      for (final occurrence in occurrences) {
        final status = occurrence.status;
        final tid = occurrence.templateId;

        // Planlanan dersler için aktif şablon / extra kontrolü
        if (status == 'planned') {
          if (tid == null) {
            continue; // orphan
          }

          if (!templateCache.containsKey(tid)) {
            templateCache[tid] = await (_db.select(_db.scheduleTemplates)
                  ..where((t) => t.id.equals(tid)))
                .getSingleOrNull();
          }
          final template = templateCache[tid];
          if (template == null) {
            continue; // silinmiş şablon
          }

          if (!template.isActive) {
            final key = '$tid|${occurrence.date}';
            if (!extraOverrideDates.contains(key)) {
              final extra = await (_db.select(_db.scheduleOverrides)
                    ..where(
                      (ov) =>
                          ov.templateId.equals(tid) &
                          ov.date.equals(occurrence.date) &
                          ov.overrideType.equals('extra'),
                    ))
                  .getSingleOrNull();
              if (extra != null) {
                extraOverrideDates.add(key);
              } else {
                continue; // pasif haftalık plan — takvimde gösterme
              }
            }
          }

          // Şablon başlangıç/bitiş penceresi dışındaki planlananları gösterme.
          // Tekil (extra) dersler pencere dışında da kalabilir.
          final extraKey = '$tid|${occurrence.date}';
          var isExtra = extraOverrideDates.contains(extraKey);
          if (!isExtra) {
            final extra = await (_db.select(_db.scheduleOverrides)
                  ..where(
                    (ov) =>
                        ov.templateId.equals(tid) &
                        ov.date.equals(occurrence.date) &
                        ov.overrideType.equals('extra'),
                  ))
                .getSingleOrNull();
            if (extra != null) {
              isExtra = true;
              extraOverrideDates.add(extraKey);
            }
          }
          if (!isExtra) {
            if (occurrence.date.compareTo(template.startDate) < 0) {
              continue;
            }
            final templateEnd = template.endDate;
            if (templateEnd != null &&
                occurrence.date.compareTo(templateEnd) > 0) {
              continue;
            }
          }
        }

        // Tarih ve saat bilgisini parse et
        final dateParts = occurrence.date.split('-');
        final timeParts = occurrence.startTime.split(':');
        final startDateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        
        // SessionOccurrence'ı Lesson formatına dönüştür
        // Status'ü SessionOccurrence'dan al (renk teması için)
        // paymentId bilgisini de ekle (ödeme durumu için)
        final parsed = occurrence.status == 'missed'
            ? CancelledLessonInfo.parseReasonNote(occurrence.notDoneReasonNote)
            : (reason: null, note: null);
        final virtualLesson = Lesson(
          id: 'occurrence_${occurrence.id}',
          studentId: occurrence.studentId,
          occurrenceId: occurrence.id,
          startDateTime: startDateTime,
          durationMin: occurrence.durationMin,
          topic: null,
          homework: null,
          feeExpected: 0,
          feePaidAmount: occurrence.paymentId != null ? 1 : 0,
          note: parsed.note,
          lessonNotes: null,
          status: occurrence.status,
          statusReason: parsed.reason,
          statusReasonSource: occurrence.notDoneReasonType == 'teacher_cancelled'
              ? 'TEACHER'
              : occurrence.notDoneReasonType == 'student_cancelled'
                  ? 'STUDENT'
                  : null,
          statusChangedAt: null,
          createdAt: occurrence.createdAt,
        );
        
        lessonList.add(virtualLesson);
      }
      
      // Tarihe göre grupla
      final map = <DateTime, List<Lesson>>{};
      for (final lesson in lessonList) {
        final dateOnly = DateTime(
          lesson.startDateTime.year,
          lesson.startDateTime.month,
          lesson.startDateTime.day,
        );
        map.putIfAbsent(dateOnly, () => []).add(lesson);
      }
      
      // Her günün derslerini saate göre sırala
      for (final key in map.keys) {
        map[key]!.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      }
      
      return map;
    });
  }

  /// Ders siler
  Future<void> deleteLesson(String id) async {
    await (_db.delete(_db.lessons)..where((l) => l.id.equals(id))).go();
  }

  /// Şablonları belirli bir tarih aralığı için otomatik olarak ders kaydına dönüştürür
  /// Returns: (createdCount, skippedCount)
  Future<Map<String, int>> createLessonsFromTemplates({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    int createdCount = 0;
    int skippedCount = 0;

    // Tüm aktif template'leri al
    final templates = await _scheduleRepo.getAllActiveTemplates();
    if (templates.isEmpty) {
      return {'created': 0, 'skipped': 0};
    }

    // Tüm öğrencileri al (hourlyRate için)
    final students = await _db.select(_db.students).get();
    final studentMap = {for (var s in students) s.id: s};

    // Tarih aralığındaki tüm günleri işle
    final currentDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final endDate = DateTime(toDate.year, toDate.month, toDate.day);

    // Mevcut ders kayıtlarını kontrol etmek için cache
    final existingLessons = await (_db.select(_db.lessons)
          ..where((l) =>
              l.startDateTime.isBiggerOrEqualValue(fromDate) &
              l.startDateTime.isSmallerOrEqualValue(toDate)))
        .get();
    final existingLessonsSet = {
      for (var lesson in existingLessons)
        '${lesson.studentId}_${lesson.startDateTime.millisecondsSinceEpoch}'
    };

    var date = currentDate;
    while (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
      final weekday = date.weekday;
      final dateStr = _formatDate(date);

      // Bu günün override'larını al
      final overrides = await (_db.select(_db.scheduleOverrides)
            ..where((o) => o.date.equals(dateStr)))
          .get();
      final overrideMap = {
        for (var override in overrides) override.templateId: override
      };

      // Bu günün template'lerini işle
      for (final template in templates) {
        if (template.weekday != weekday) continue;

        final override = overrideMap[template.id];

        // Eğer cancelled ise atla
        if (override?.overrideType == 'cancelled') {
          skippedCount++;
          continue;
        }

        // Override varsa onu kullan, yoksa template'i kullan
        final effectiveStartTime = override?.newStartTime ?? template.startTime;
        final effectiveDuration = override?.newDurationMin ?? template.durationMin;

        // Saati parse et
        final timeParts = effectiveStartTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        // DateTime oluştur
        final startDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Duplicate kontrolü
        final lessonKey = '${template.studentId}_${startDateTime.millisecondsSinceEpoch}';
        if (existingLessonsSet.contains(lessonKey)) {
          skippedCount++;
          continue;
        }

        // Öğrenci bilgisini al
        final student = studentMap[template.studentId];
        if (student == null) {
          skippedCount++;
          continue;
        }

        // Ders kaydı oluştur
        try {
          await createLessonFromSchedule(
            studentId: template.studentId,
            startDateTime: startDateTime,
            durationMin: effectiveDuration,
            hourlyRate: student.hourlyRate,
            feePaidAmount: 0,
          );
          createdCount++;
          existingLessonsSet.add(lessonKey); // Cache'e ekle
        } catch (e) {
          skippedCount++;
        }
      }

      // Sonraki güne geç
      date = date.add(const Duration(days: 1));
    }

    return {'created': createdCount, 'skipped': skippedCount};
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Toplu ödeme uygular (en eski borçtan başlayarak)
  /// Payments ve LessonPayments tablolarını kullanır
  /// Transaction içinde çalışır
  /// Returns: (appliedLessonsCount, remainingAmount, lastLessonUpdated)
  Future<Map<String, dynamic>> applyBulkPayment({
    required String studentId,
    required int paymentAmount,
    String method = 'cash', // 'cash' | 'transfer'
    String? note,
  }) async {
    return await _db.transaction(() async {
      final now = DateTime.now();
      final paymentId = _uuid.v4();

      // Payment kaydı oluştur
      await _db.into(_db.payments).insert(
        PaymentsCompanion.insert(
          id: paymentId,
          studentId: studentId,
          paidAt: now,
          amount: paymentAmount,
          method: method,
          note: Value(note),
          createdAt: now,
        ),
      );

      // Öğrencinin tüm derslerini al (en eski borç en üstte)
      final allLessons = await (_db.select(_db.lessons)
            ..where((l) => l.studentId.equals(studentId))
            ..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.asc)]))
          .get();

      // Her ders için LessonPayments'tan toplam ödenen miktarı hesapla
      final lessonPaidMap = <String, int>{};
      for (final lesson in allLessons) {
        final paidRows = await (_db.selectOnly(_db.lessonPayments)
              ..addColumns([_db.lessonPayments.appliedAmount.sum()])
              ..where(_db.lessonPayments.lessonId.equals(lesson.id)))
            .get();
        final totalPaid = paidRows.isEmpty
            ? 0
            : paidRows.first.read(_db.lessonPayments.appliedAmount.sum()) ?? 0;
        lessonPaidMap[lesson.id] = totalPaid;
      }

      // Borcu olan dersleri filtrele
      final lessons = allLessons.where((l) {
        final paid = lessonPaidMap[l.id] ?? 0;
        return paid < l.feeExpected;
      }).toList();

      if (lessons.isEmpty) {
        // Borç yok, fazla ödemeyi en son derse ekle
        final lastLesson = await (_db.select(_db.lessons)
              ..where((l) => l.studentId.equals(studentId))
              ..orderBy([(l) => OrderingTerm(expression: l.startDateTime, mode: OrderingMode.desc)])
              ..limit(1))
            .getSingleOrNull();

        if (lastLesson != null) {
          final lessonPaymentId = _uuid.v4();
          await _db.into(_db.lessonPayments).insert(
            LessonPaymentsCompanion.insert(
              id: lessonPaymentId,
              paymentId: paymentId,
              lessonId: lastLesson.id,
              appliedAmount: paymentAmount,
              createdAt: now,
            ),
          );

          return {
            'appliedLessonsCount': 0,
            'remainingAmount': paymentAmount,
            'lastLessonUpdated': true,
          };
        }

        return {
          'appliedLessonsCount': 0,
          'remainingAmount': paymentAmount,
          'lastLessonUpdated': false,
        };
      }

      int remaining = paymentAmount;
      int appliedLessonsCount = 0;
      Lesson? lastUpdatedLesson;

      // En eski borçtan başlayarak ödemeyi dağıt
      for (final lesson in lessons) {
        if (remaining <= 0) break;

        final paid = lessonPaidMap[lesson.id] ?? 0;
        final need = lesson.feeExpected - paid;
        final take = need < remaining ? need : remaining;

        if (take > 0) {
          final lessonPaymentId = _uuid.v4();
          await _db.into(_db.lessonPayments).insert(
            LessonPaymentsCompanion.insert(
              id: lessonPaymentId,
              paymentId: paymentId,
              lessonId: lesson.id,
              appliedAmount: take,
              createdAt: now,
            ),
          );

          remaining -= take;
          appliedLessonsCount++;
          lastUpdatedLesson = lesson;
        }

        if (remaining <= 0) break;
      }

      // Eğer hala kalan varsa, en son güncellenen derse ekle
      if (remaining > 0 && lastUpdatedLesson != null) {
        final lessonPaymentId = _uuid.v4();
        await _db.into(_db.lessonPayments).insert(
          LessonPaymentsCompanion.insert(
            id: lessonPaymentId,
            paymentId: paymentId,
            lessonId: lastUpdatedLesson.id,
            appliedAmount: remaining,
            createdAt: now,
          ),
        );
      }

      return {
        'appliedLessonsCount': appliedLessonsCount,
        'remainingAmount': remaining,
        'lastLessonUpdated': remaining > 0,
      };
    });
  }
}

// PERFORMANS NOTU: Ödeme sorguları için indeks önerileri
// 
// 1. Lessons.studentId için indeks zaten var (foreign key)
// 2. Lessons.startDateTime için indeks eklenebilir (tarih aralığı sorguları için):
//    - Migration'da: await m.createIndex(Index('idx_lessons_start_datetime', 'CREATE INDEX idx_lessons_start_datetime ON lessons(start_date_time)'));
// 
// 3. Ödeme sorguları için composite index (opsiyonel):
//    - studentId + startDateTime: await m.createIndex(Index('idx_lessons_student_date', 'CREATE INDEX idx_lessons_student_date ON lessons(student_id, start_date_time)'));
//
// Bu indeksler özellikle watchStudentPaymentSummaries() ve tarih aralığı sorgularında performans artışı sağlar.
