import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:uuid/uuid.dart';

/// Seçili ders ödemesi (UI'dan gelen)
class SelectedLessonPayment {
  final String lessonId;
  final int applyAmount;

  SelectedLessonPayment({
    required this.lessonId,
    required this.applyAmount,
  });
}

/// Öğrencinin ödenmemiş ders bilgisi
class UnpaidLesson {
  final String lessonId;
  final DateTime startDateTime;
  final int feeExpected;
  final int paidSoFar;
  final int remaining; // feeExpected - paidSoFar

  UnpaidLesson({
    required this.lessonId,
    required this.startDateTime,
    required this.feeExpected,
    required this.paidSoFar,
    required this.remaining,
  });
}

/// Öğrenci ödeme kaydı
class StudentPayment {
  final String paymentId;
  final DateTime paidAt;
  final int amount;
  final String method; // 'cash' | 'transfer'
  final String? note;

  StudentPayment({
    required this.paymentId,
    required this.paidAt,
    required this.amount,
    required this.method,
    this.note,
  });
}

/// Ödeme detayı (hangi derslere uygulandı)
class PaymentDetail {
  final String lessonPaymentId; // LessonPayments.id
  final String lessonId;
  final DateTime lessonDate;
  final int appliedAmount;

  PaymentDetail({
    required this.lessonPaymentId,
    required this.lessonId,
    required this.lessonDate,
    required this.appliedAmount,
  });
}

/// Derse uygulanan ödeme bilgisi (LessonPayments join Payments)
class LessonPaymentInfo {
  final String lessonPaymentId; // LessonPayments.id
  final String paymentId;
  final DateTime paidAt;
  final String method; // 'cash' | 'transfer'
  final int appliedAmount;

  LessonPaymentInfo({
    required this.lessonPaymentId,
    required this.paymentId,
    required this.paidAt,
    required this.method,
    required this.appliedAmount,
  });
}

class PaymentsRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  PaymentsRepository(this._db);

  /// Ödeme oluşturur ve seçili derslere uygular
  /// Transaction içinde çalışır
  /// 
  /// Validasyonlar:
  /// - Toplam applyAmount <= amount (aşarsa hata)
  /// - Her ders için applyAmount <= remaining (aşarsa hata)
  /// - Toplam applyAmount < amount ise uyarı (kullanıcı onayı gerekebilir)
  Future<String> createPaymentWithLessons({
    required String studentId,
    required DateTime paidAt,
    required int amount,
    required String method, // 'cash' | 'transfer'
    String? note,
    required List<SelectedLessonPayment> selectedLessons,
  }) async {
    return await _db.transaction(() async {
      final now = DateTime.now();

      // Önce öğrenciyi al
      final student = await (_db.select(_db.students)
            ..where((s) => s.id.equals(studentId)))
          .getSingleOrNull();

      if (student == null) {
        throw Exception('Öğrenci bulunamadı: $studentId');
      }

      // LessonPayments'a yazmadan önce: her ders için güncel remaining hesapla,
      // remaining <= 0 olanları atla, applyAmount'u remaining ile sınırla
      final effectiveLessons = <SelectedLessonPayment>[];
      for (final selectedLesson in selectedLessons) {
        final occurrence = await (_db.select(_db.sessionOccurrences)
              ..where((o) => o.id.equals(selectedLesson.lessonId)))
            .getSingleOrNull();

        if (occurrence == null) {
          throw Exception('Ders bulunamadı: ${selectedLesson.lessonId}');
        }

        final feeExpected = ((student.hourlyRate * occurrence.durationMin) / 60).round();
        final isPaid = occurrence.paymentId != null;
        final paidSoFar = isPaid ? feeExpected : 0;
        final remaining = feeExpected - paidSoFar;

        if (remaining <= 0) continue; // Zaten ödenmiş, uygulama yapma

        final cappedAmount = selectedLesson.applyAmount > remaining
            ? remaining
            : selectedLesson.applyAmount;
        if (cappedAmount <= 0) continue;

        effectiveLessons.add(SelectedLessonPayment(
          lessonId: selectedLesson.lessonId,
          applyAmount: cappedAmount,
        ));
      }

      // Hiçbir derse uygulanacak tutar yoksa ödeme kaydı oluşturma
      if (effectiveLessons.isEmpty) {
        throw Exception('Seçili dersler zaten ödenmiş.');
      }

      final totalApplied = effectiveLessons.fold<int>(
        0,
        (sum, lesson) => sum + lesson.applyAmount,
      );

      if (totalApplied > amount) {
        throw Exception(
          'Toplam uygulanan tutar ($totalApplied ₺) ödeme tutarını ($amount ₺) aşamaz',
        );
      }

      final paymentId = _uuid.v4();

      // Payment kaydı oluştur
      await _db.into(_db.payments).insert(
        PaymentsCompanion.insert(
          id: paymentId,
          studentId: studentId,
          paidAt: paidAt,
          amount: amount,
          method: method,
          note: Value(note),
          createdAt: now,
        ),
      );

      // Sadece effectiveLessons için LessonPayments oluştur
      for (final selectedLesson in effectiveLessons) {
        final occurrence = await (_db.select(_db.sessionOccurrences)
              ..where((o) => o.id.equals(selectedLesson.lessonId)))
            .getSingleOrNull();

        if (occurrence != null) {
          final lessonPaymentId = _uuid.v4();
          await _db.into(_db.lessonPayments).insert(
            LessonPaymentsCompanion.insert(
              id: lessonPaymentId,
              paymentId: paymentId,
              lessonId: selectedLesson.lessonId,
              appliedAmount: selectedLesson.applyAmount,
              createdAt: now,
            ),
          );

          await (_db.update(_db.sessionOccurrences)
                ..where((o) => o.id.equals(selectedLesson.lessonId)))
              .write(SessionOccurrencesCompanion(
                paymentId: Value(paymentId),
                updatedAt: Value(now),
              ));
        }
      }

      if (totalApplied < amount) {
        final remaining = amount - totalApplied;
        print('⚠️ Kalan tutar kullanılmadı: $remaining ₺');
      }

      return paymentId;
    });
  }

  /// Öğrencinin ödenmemiş derslerini getirir
  /// TEK VERİ KAYNAĞI: SessionOccurrences (status='done')
  /// includePaid=false ise tam ödenmiş dersleri getirmez
  Stream<List<UnpaidLesson>> watchStudentUnpaidLessons(
    String studentId, {
    bool includePaid = false,
  }) {
    // SessionOccurrences'dan done occurrence'ları al
    final occurrencesQuery = _db.select(_db.sessionOccurrences)
      ..where((o) => 
          o.studentId.equals(studentId) & 
          o.status.equals('done'))
      ..orderBy([(o) => OrderingTerm(expression: o.date, mode: OrderingMode.asc)]);

    return occurrencesQuery.watch().asyncMap((occurrences) async {
      // Öğrenci bilgisini al
      final student = await (_db.select(_db.students)
            ..where((s) => s.id.equals(studentId)))
          .getSingleOrNull();
      
      if (student == null) return <UnpaidLesson>[];

      final unpaidLessons = <UnpaidLesson>[];

      for (final occurrence in occurrences) {
        // Ücret hesapla
        final feeExpected = ((student.hourlyRate * occurrence.durationMin) / 60).round();
        
        // Ödeme durumu: paymentId varsa ödenmiş, yoksa ödenmemiş
        final isPaid = occurrence.paymentId != null;
        final paidSoFar = isPaid ? feeExpected : 0;
        final remaining = feeExpected - paidSoFar;

        // includePaid kontrolü
        if (!includePaid && remaining <= 0) {
          continue; // Tam ödenmiş dersleri atla
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

        // UnpaidLesson oluştur (occurrenceId'yi lessonId olarak kullan)
        unpaidLessons.add(UnpaidLesson(
          lessonId: occurrence.id, // occurrenceId'yi lessonId olarak kullan
          startDateTime: startDateTime,
          feeExpected: feeExpected,
          paidSoFar: paidSoFar,
          remaining: remaining,
        ));
      }

      return unpaidLessons;
    });
  }

  /// Öğrencinin ödeme listesini getirir (paidAt desc)
  Stream<List<StudentPayment>> watchStudentPayments(String studentId) {
    final query = _db.select(_db.payments)
      ..where((p) => p.studentId.equals(studentId))
      ..orderBy([(p) => OrderingTerm(expression: p.paidAt, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return StudentPayment(
          paymentId: row.id,
          paidAt: row.paidAt,
          amount: row.amount,
          method: row.method,
          note: row.note,
        );
      }).toList();
    });
  }

  /// Belirli bir ödemenin hangi derslere uygulandığını getirir
  /// lessonId aslında occurrenceId olabilir (SessionOccurrences.id)
  Future<List<PaymentDetail>> getPaymentDetails(String paymentId) async {
    // Önce LessonPayments'tan lessonId'leri al
    final lessonPayments = await (_db.select(_db.lessonPayments)
          ..where((lp) => lp.paymentId.equals(paymentId)))
        .get();
    
    final result = <PaymentDetail>[];
    
    for (final lp in lessonPayments) {
      // lessonId aslında occurrenceId olabilir
      // Önce SessionOccurrences'tan kontrol et
      final occurrence = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.id.equals(lp.lessonId)))
          .getSingleOrNull();
      
      DateTime lessonDate;
      if (occurrence != null) {
        // SessionOccurrence'dan tarih ve saat bilgisini parse et
        final dateParts = occurrence.date.split('-');
        final timeParts = occurrence.startTime.split(':');
        lessonDate = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } else {
        // Eski Lessons tablosundan al (geriye uyumluluk)
        final lesson = await (_db.select(_db.lessons)
              ..where((l) => l.id.equals(lp.lessonId)))
            .getSingleOrNull();
        
        if (lesson != null) {
          lessonDate = lesson.startDateTime;
        } else {
          // Bulunamadı, atla
          continue;
        }
      }
      
      result.add(PaymentDetail(
        lessonPaymentId: lp.id,
        lessonId: lp.lessonId,
        lessonDate: lessonDate,
        appliedAmount: lp.appliedAmount,
      ));
    }
    
    return result;
  }

  /// Belirli bir derse uygulanan ödemeleri getirir (LessonPayments join Payments)
  /// Ödeme tarihi, ödeme şekli, appliedAmount bilgileriyle
  /// lessonId aslında occurrenceId olabilir (SessionOccurrences.id)
  Stream<List<LessonPaymentInfo>> watchLessonPayments(String lessonId) {
    final query = _db.selectOnly(_db.lessonPayments)
      ..join([
        innerJoin(_db.payments, _db.payments.id.equalsExp(_db.lessonPayments.paymentId)),
      ])
      ..addColumns([
        _db.lessonPayments.id,
        _db.payments.paidAt,
        _db.payments.method,
        _db.lessonPayments.appliedAmount,
        _db.payments.id,
      ])
      ..where(_db.lessonPayments.lessonId.equals(lessonId))
      ..orderBy([OrderingTerm(expression: _db.payments.paidAt, mode: OrderingMode.desc)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return LessonPaymentInfo(
          lessonPaymentId: row.read(_db.lessonPayments.id)!,
          paymentId: row.read(_db.payments.id)!,
          paidAt: row.read(_db.payments.paidAt)!,
          method: row.read(_db.payments.method)!,
          appliedAmount: row.read(_db.lessonPayments.appliedAmount)!,
        );
      }).toList();
    });
  }

  /// Belirli bir LessonPayment kaydını siler (bu dersten ödemeyi geri alır)
  /// Transaction içinde çalışır
  /// SessionOccurrences.paymentId'yi de NULL yapar
  Future<void> removeAppliedPayment({required String lessonPaymentId}) async {
    await _db.transaction(() async {
      // Önce LessonPayment kaydını al
      final lessonPayment = await (_db.select(_db.lessonPayments)
            ..where((lp) => lp.id.equals(lessonPaymentId)))
          .getSingleOrNull();
      
      if (lessonPayment == null) {
        throw Exception('LessonPayment bulunamadı: $lessonPaymentId');
      }
      
      // Payment bilgisini al
      final payment = await (_db.select(_db.payments)
            ..where((p) => p.id.equals(lessonPayment.paymentId)))
          .getSingleOrNull();
      
      if (payment != null) {
        // Bu paymentId'ye sahip başka LessonPayment var mı kontrol et
        final otherLessonPayments = await (_db.select(_db.lessonPayments)
              ..where((lp) => 
                  lp.paymentId.equals(lessonPayment.paymentId) &
                  lp.id.isNotValue(lessonPaymentId)))
            .get();
        
        // Eğer bu son LessonPayment ise, SessionOccurrences.paymentId'yi NULL yap
        if (otherLessonPayments.isEmpty) {
          await (_db.update(_db.sessionOccurrences)
                ..where((o) => o.paymentId.equals(lessonPayment.paymentId)))
              .write(SessionOccurrencesCompanion(
                paymentId: Value(null), // NULL yapmak için Value(null) kullan
                updatedAt: Value(DateTime.now()),
              ));
        } else {
          // Sadece bu occurrence için paymentId'yi NULL yap
          await (_db.update(_db.sessionOccurrences)
                ..where((o) => o.id.equals(lessonPayment.lessonId)))
              .write(SessionOccurrencesCompanion(
                paymentId: Value(null), // NULL yapmak için Value(null) kullan
                updatedAt: Value(DateTime.now()),
              ));
        }
      }
      
      // LessonPayment kaydını sil
      await (_db.delete(_db.lessonPayments)
            ..where((lp) => lp.id.equals(lessonPaymentId)))
          .go();
    });
  }

  /// Belirli bir LessonPayment tutarını günceller
  /// newAmount 0 ise kaydı siler
  /// Transaction içinde çalışır
  /// 
  /// Validasyon: newAmount <= (dersin remaining + mevcut appliedAmount)
  /// lessonId aslında occurrenceId olabilir (SessionOccurrences.id)
  Future<void> updateAppliedAmount({
    required String lessonPaymentId,
    required int newAmount,
  }) async {
    await _db.transaction(() async {
      // Mevcut LessonPayment kaydını al
      final lessonPayment = await (_db.select(_db.lessonPayments)
            ..where((lp) => lp.id.equals(lessonPaymentId)))
          .getSingleOrNull();

      if (lessonPayment == null) {
        throw Exception('LessonPayment bulunamadı: $lessonPaymentId');
      }

      // newAmount 0 ise sil ve SessionOccurrences.paymentId'yi NULL yap
      if (newAmount == 0) {
        // Önce SessionOccurrences.paymentId'yi NULL yap
        final payment = await (_db.select(_db.payments)
              ..where((p) => p.id.equals(lessonPayment.paymentId)))
            .getSingleOrNull();
        
        if (payment != null) {
          // Bu paymentId'ye sahip tüm SessionOccurrences'ları kontrol et
          // Eğer başka LessonPayment yoksa paymentId'yi NULL yap
          final otherLessonPayments = await (_db.select(_db.lessonPayments)
                ..where((lp) => 
                    lp.paymentId.equals(lessonPayment.paymentId) &
                    lp.id.isNotValue(lessonPaymentId)))
              .get();
          
          // Eğer bu son LessonPayment ise, SessionOccurrences.paymentId'yi NULL yap
          if (otherLessonPayments.isEmpty) {
            await (_db.update(_db.sessionOccurrences)
                  ..where((o) => o.paymentId.equals(lessonPayment.paymentId)))
                .write(SessionOccurrencesCompanion(
                  paymentId: Value(null), // NULL yapmak için Value(null) kullan
                  updatedAt: Value(DateTime.now()),
                ));
          } else {
            // Sadece bu occurrence için paymentId'yi NULL yap
            await (_db.update(_db.sessionOccurrences)
                  ..where((o) => o.id.equals(lessonPayment.lessonId)))
                .write(SessionOccurrencesCompanion(
                  paymentId: Value(null), // NULL yapmak için Value(null) kullan
                  updatedAt: Value(DateTime.now()),
                ));
          }
        }
        
        await (_db.delete(_db.lessonPayments)
              ..where((lp) => lp.id.equals(lessonPaymentId)))
            .go();
        return;
      }

      // Ders bilgisini al (SessionOccurrence veya Lesson)
      // Önce SessionOccurrence'dan kontrol et
      final occurrence = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.id.equals(lessonPayment.lessonId)))
          .getSingleOrNull();
      
      int feeExpected;
      if (occurrence != null) {
        // SessionOccurrence'dan öğrenci bilgisini al ve ücret hesapla
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(occurrence.studentId)))
            .getSingleOrNull();
        
        if (student == null) {
          throw Exception('Öğrenci bulunamadı: ${occurrence.studentId}');
        }
        
        feeExpected = ((student.hourlyRate * occurrence.durationMin) / 60).round();
      } else {
        // Eski Lessons tablosundan al (geriye uyumluluk)
        final lesson = await (_db.select(_db.lessons)
              ..where((l) => l.id.equals(lessonPayment.lessonId)))
            .getSingleOrNull();

        if (lesson == null) {
          throw Exception('Ders bulunamadı: ${lessonPayment.lessonId}');
        }
        
        feeExpected = lesson.feeExpected;
      }

      // Dersin mevcut ödenen miktarını hesapla (bu kayıt hariç)
      final paidRows = await (_db.selectOnly(_db.lessonPayments)
            ..addColumns([_db.lessonPayments.appliedAmount.sum()])
            ..where(_db.lessonPayments.lessonId.equals(lessonPayment.lessonId))
            ..where(_db.lessonPayments.id.isNotValue(lessonPaymentId)))
          .get();
      final paidSoFar = paidRows.isEmpty
          ? 0
          : paidRows.first.read(_db.lessonPayments.appliedAmount.sum()) ?? 0;

      final remaining = feeExpected - paidSoFar;
      final maxAllowed = remaining + lessonPayment.appliedAmount;

      if (newAmount > maxAllowed) {
        throw Exception(
          'Yeni tutar ($newAmount ₺) izin verilen maksimum tutarı ($maxAllowed ₺) aşamaz',
        );
      }

      // Tutarı güncelle
      await (_db.update(_db.lessonPayments)
            ..where((lp) => lp.id.equals(lessonPaymentId)))
          .write(LessonPaymentsCompanion(
            appliedAmount: Value(newAmount),
          ));
    });
  }

  /// Bir ödeme kaydını tamamen siler (Payment + tüm LessonPayments)
  /// Transaction içinde çalışır
  /// SessionOccurrences.paymentId'yi de NULL yapar
  /// 
  /// NOT: Bu ödeme başka derslere de uygulanmış olabilir,
  /// bu yüzden UI'da kullanıcı onayı şart!
  Future<void> deletePayment({required String paymentId}) async {
    await _db.transaction(() async {
      final now = DateTime.now();
      
      // DEBUG: İptal öncesi count
      final beforeCount = await (_db.selectOnly(_db.sessionOccurrences)
            ..addColumns([_db.sessionOccurrences.id.count()])
            ..where(_db.sessionOccurrences.paymentId.equals(paymentId)))
          .getSingle();
      final beforeCountValue = beforeCount.read(_db.sessionOccurrences.id.count()) ?? 0;
      print('🔍 Ödeme iptali öncesi: paymentId=$paymentId, bağlı occurrence sayısı=$beforeCountValue');
      
      // 1) Önce LessonPayments kayıtlarını al (hangi occurrence'ların etkileneceğini görmek için)
      final lessonPayments = await (_db.select(_db.lessonPayments)
            ..where((lp) => lp.paymentId.equals(paymentId)))
          .get();
      
      print('🔍 İptal edilecek LessonPayments sayısı: ${lessonPayments.length}');
      
      // 2) Bu LessonPayments'lara bağlı occurrence ID'lerini topla (debug için)
      final affectedOccurrenceIds = lessonPayments.map((lp) => lp.lessonId).toSet().toList();
      print('🔍 Etkilenecek occurrence ID\'leri: ${affectedOccurrenceIds.join(", ")}');
      
      // 3) SessionOccurrences'taki paymentId'yi NULL yap
      // ÖNEMLİ: Tüm paymentId'ye bağlı occurrence'ları NULL yap
      // Önce mevcut occurrence'ları al (doğrulama için)
      final occurrencesToUpdate = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.paymentId.equals(paymentId)))
          .get();
      
      print('🔍 Güncellenecek occurrence sayısı: ${occurrencesToUpdate.length}');
      print('🔍 Güncellenecek occurrence ID\'leri: ${occurrencesToUpdate.map((o) => o.id).join(", ")}');
      
      // Şimdi güncelle
      // ÖNEMLİ: NULL yapmak için Value(null) kullanmalıyız, Value.absent() alanı güncellemez!
      final updateCount = await (_db.update(_db.sessionOccurrences)
            ..where((o) => o.paymentId.equals(paymentId)))
          .write(SessionOccurrencesCompanion(
            paymentId: Value(null), // NULL yapmak için Value(null) kullan
            updatedAt: Value(now),
          ));
      
      print('🔍 Güncellenen occurrence sayısı: $updateCount (beklenen: ${occurrencesToUpdate.length})');
      
      // Eğer hiçbir occurrence güncellenmediyse uyarı ver
      if (updateCount == 0 && occurrencesToUpdate.isNotEmpty) {
        print('⚠️ UYARI: Hiçbir occurrence güncellenmedi ama ${occurrencesToUpdate.length} occurrence bulundu!');
      }
      
      // DEBUG: İptal sonrası count (0 olmalı) - transaction içinde tekrar kontrol et
      final afterCount = await (_db.selectOnly(_db.sessionOccurrences)
            ..addColumns([_db.sessionOccurrences.id.count()])
            ..where(_db.sessionOccurrences.paymentId.equals(paymentId)))
          .getSingle();
      final afterCountValue = afterCount.read(_db.sessionOccurrences.id.count()) ?? 0;
      print('🔍 Ödeme iptali sonrası (transaction içinde): paymentId=$paymentId, bağlı occurrence sayısı=$afterCountValue');
      
      if (afterCountValue > 0) {
        // Hata durumunda daha fazla bilgi ver
        final stillLinked = await (_db.select(_db.sessionOccurrences)
              ..where((o) => o.paymentId.equals(paymentId)))
            .get();
        print('⚠️ Hala bağlı occurrence ID\'leri: ${stillLinked.map((o) => o.id).join(", ")}');
        print('⚠️ Hala bağlı occurrence paymentId değerleri: ${stillLinked.map((o) => o.paymentId).join(", ")}');
        throw Exception('Ödeme iptali sonrası hala $afterCountValue occurrence bağlı!');
      }

      // 4) LessonPayments tablosunda paymentId ile bağlı satırları sil
      await (_db.delete(_db.lessonPayments)
            ..where((lp) => lp.paymentId.equals(paymentId)))
          .go();
      
      print('🔍 Silinen LessonPayments sayısı: ${lessonPayments.length}');

      // 5) Payments kaydını sil
      await (_db.delete(_db.payments)
            ..where((p) => p.id.equals(paymentId)))
          .go();
      
      print('✅ Ödeme iptali tamamlandı: paymentId=$paymentId');
    });
  }

  /// Global ödeme özeti
  /// 
  /// - totalPaid = SUM(Payments.amount)
  /// - totalExpected = SUM(Lessons.feeExpected)
  /// - totalApplied = SUM(LessonPayments.appliedAmount)
  /// - totalDue = totalExpected - totalApplied
  Stream<Map<String, int>> watchGlobalPaymentSummary() {
    // Payments toplamı
    final paymentsQuery = _db.selectOnly(_db.payments)
      ..addColumns([_db.payments.amount.sum()]);

    // Lessons toplamı
    final lessonsQuery = _db.selectOnly(_db.lessons)
      ..addColumns([_db.lessons.feeExpected.sum()]);

    // LessonPayments toplamı
    final appliedQuery = _db.selectOnly(_db.lessonPayments)
      ..addColumns([_db.lessonPayments.appliedAmount.sum()]);

    // Her üç stream'i birleştir
    return paymentsQuery.watch().asyncExpand((paymentRows) {
      final totalPaid = paymentRows.isEmpty
          ? 0
          : paymentRows.first.read(_db.payments.amount.sum()) ?? 0;

      return lessonsQuery.watch().asyncExpand((lessonRows) {
        final totalExpected = lessonRows.isEmpty
            ? 0
            : lessonRows.first.read(_db.lessons.feeExpected.sum()) ?? 0;

        return appliedQuery.watch().map((appliedRows) {
          final totalApplied = appliedRows.isEmpty
              ? 0
              : appliedRows.first.read(_db.lessonPayments.appliedAmount.sum()) ?? 0;

          final totalDue = totalExpected - totalApplied;

          return {
            'totalPaid': totalPaid,
            'totalExpected': totalExpected,
            'totalApplied': totalApplied,
            'totalDue': totalDue,
          };
        });
      });
    });
  }
}
