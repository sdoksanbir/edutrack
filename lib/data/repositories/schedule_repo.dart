import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/repositories/app_settings_repo.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:ozel_ders_takip/services/notification_service.dart';
import 'package:uuid/uuid.dart';

/// Effective schedule için kullanılan model
class EffectiveScheduleItem {
  final String templateId;
  final String studentId;
  final String studentName;
  final int weekday;
  final String startTime;
  final int durationMin;
  final DateTime date; // Hangi tarih için geçerli
  
  // Occurrence bilgileri
  final String? occurrenceId;
  final String? status; // 'planned' | 'done' | 'not_done'
  final String? notDoneReasonType; // 'student_cancelled' | 'teacher_cancelled' | 'other'
  final String? notDoneReasonNote;

  EffectiveScheduleItem({
    required this.templateId,
    required this.studentId,
    required this.studentName,
    required this.weekday,
    required this.startTime,
    required this.durationMin,
    required this.date,
    this.occurrenceId,
    this.status,
    this.notDoneReasonType,
    this.notDoneReasonNote,
  });
}

class ScheduleRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();
  final _notificationService = NotificationService();
  final HomeworkRepository _homeworkRepo;

  /// ensureOccurrencesForRange önbelleği (aynı aralık kısa sürede tekrar prune/upsert olmasın).
  final Map<String, DateTime> _ensureCache = {};
  static const _ensureTtl = Duration(minutes: 2);

  ScheduleRepository(this._db, [HomeworkRepository? homeworkRepo])
      : _homeworkRepo = homeworkRepo ?? HomeworkRepository(_db);

  /// Şablon / program değişince çağır — sonraki ensure yeniden çalışır.
  void clearOccurrenceEnsureCache() => _ensureCache.clear();

  /// Home / takvim: gerekirse prune + upsert; yakın zamanda yapıldıysa atlar.
  Future<void> ensureOccurrencesForRange({
    required DateTime startDate,
    required DateTime endDate,
    bool force = false,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final key = '${_formatDate(start)}|${_formatDate(end)}';
    final cached = _ensureCache[key];
    if (!force &&
        cached != null &&
        DateTime.now().difference(cached) < _ensureTtl) {
      return;
    }
    await prunePlannedOutsideActiveTemplateWindows();
    await upsertOccurrencesForRange(startDate: start, endDate: end);
    _ensureCache[key] = DateTime.now();
  }

  /// Ortak tarih formatı: 'YYYY-MM-DD'
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Ortak saat formatı: 'HH:mm'
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  /// Öğrenciye ait tüm aktif şablonları stream olarak döndürür
  Stream<List<ScheduleTemplate>> watchTemplatesByStudent(String studentId) {
    return (_db.select(_db.scheduleTemplates)
          ..where((t) => t.studentId.equals(studentId) & t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.weekday),
            (t) => OrderingTerm(expression: t.startTime),
          ]))
        .watch();
  }

  /// Öğrenciye ait tüm aktif şablonları getirir
  Future<List<ScheduleTemplate>> getTemplatesByStudent(String studentId) async {
    return await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.studentId.equals(studentId) & t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.weekday),
            (t) => OrderingTerm(expression: t.startTime),
          ]))
        .get();
  }

  /// Tüm aktif şablonları getirir
  Future<List<ScheduleTemplate>> getAllActiveTemplates() async {
    return await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.weekday),
            (t) => OrderingTerm(expression: t.startTime),
          ]))
        .get();
  }

  /// ID'ye göre şablon getirir
  Future<ScheduleTemplate?> getTemplateById(String templateId) async {
    return await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.id.equals(templateId)))
        .getSingleOrNull();
  }

  /// Şablon ekler (createTemplate alias)
  Future<String> createTemplate({
    required String studentId,
    required int weekday,
    required String startTime,
    required int durationMin,
    required String startDate, // 'YYYY-MM-DD' formatında
    String? endDate, // 'YYYY-MM-DD' formatında, null ise AppSettings'ten alınır
  }) async {
    return insertTemplate(
      studentId: studentId,
      weekday: weekday,
      startTime: startTime,
      durationMin: durationMin,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Haftalık plan ekler ve [startDate, endDate] (dahil) aralığında
  /// yalnızca şablon gününe denk gelen dersleri üretir.
  ///
  /// [endDate] null ise ayarlardaki varsayılan bitiş tarihi kullanılır.
  Future<String> createWeeklyPlanAndOccurrences({
    required String studentId,
    required int weekday,
    required String startTime,
    required int durationMin,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final appSettingsRepo = AppSettingsRepository(_db);
    final defaultEnd = await appSettingsRepo.getDefaultScheduleEndDate();

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    final rangeEnd = endDate != null
        ? DateTime(endDate.year, endDate.month, endDate.day)
        : DateTime(defaultEnd.year, defaultEnd.month, defaultEnd.day);

    if (rangeEnd.isBefore(rangeStart)) {
      throw Exception('Bitiş tarihi başlangıçtan önce olamaz');
    }

    final startDateStr = _formatDate(rangeStart);
    // Kullanıcı bitiş girdiyse mutlaka kaydet; girmediyse ayar tarihini kaydet
    final endDateStr = _formatDate(rangeEnd);

    final templateId = await insertTemplate(
      studentId: studentId,
      weekday: weekday,
      startTime: startTime,
      durationMin: durationMin,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    // Başlangıç–bitiş dahil, sadece weekday günlerine ders yerleştir
    await _generatePlannedOccurrencesForTemplate(
      templateId: templateId,
      studentId: studentId,
      weekday: weekday,
      startTime: startTime,
      durationMin: durationMin,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );

    return templateId;
  }

  /// Mevcut haftalık planı günceller; dersleri [startDate, endDate] dahil üretir.
  Future<void> updateWeeklyPlanAndOccurrences({
    required String templateId,
    required int weekday,
    required String startTime,
    required int durationMin,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final appSettingsRepo = AppSettingsRepository(_db);
    final defaultEnd = await appSettingsRepo.getDefaultScheduleEndDate();

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    final rangeEnd = endDate != null
        ? DateTime(endDate.year, endDate.month, endDate.day)
        : DateTime(defaultEnd.year, defaultEnd.month, defaultEnd.day);

    if (rangeEnd.isBefore(rangeStart)) {
      throw Exception('Bitiş tarihi başlangıçtan önce olamaz');
    }

    final template = await getTemplateById(templateId);
    if (template == null) {
      throw Exception('Şablon bulunamadı');
    }

    await updateTemplate(
      id: templateId,
      weekday: weekday,
      startTime: startTime,
      durationMin: durationMin,
      startDate: _formatDate(rangeStart),
      endDate: _formatDate(rangeEnd),
    );

    await _generatePlannedOccurrencesForTemplate(
      templateId: templateId,
      studentId: template.studentId,
      weekday: weekday,
      startTime: startTime,
      durationMin: durationMin,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  /// Verilen aralıkta (dahil) şablon gününe uyan planned occurrence üretir;
  /// aralık dışı veya gün/saat uyuşmayan planned kayıtları bu şablon için siler.
  Future<void> _generatePlannedOccurrencesForTemplate({
    required String templateId,
    required String studentId,
    required int weekday,
    required String startTime,
    required int durationMin,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    final now = DateTime.now();
    final startStr = _formatDate(rangeStart);
    final endStr = _formatDate(rangeEnd);

    // Bu şablona ait moved override tarihleri (tekil saat kaydırması korunur)
    final movedOverrides = await (_db.select(_db.scheduleOverrides)
          ..where(
            (o) =>
                o.templateId.equals(templateId) &
                o.overrideType.equals('moved'),
          ))
        .get();
    final movedByDate = {
      for (final o in movedOverrides) o.date: o,
    };

    // Aralık dışı VEYA eski gün/saat slotundaki planned dersleri temizle
    // (güncellemede eski Pazartesi + yeni Çarşamba ikisi birden kalmasın)
    final allForTemplate = await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.templateId.equals(templateId)))
        .get();
    for (final occ in allForTemplate) {
      if (occ.status != 'planned') continue;

      final outsideRange =
          occ.date.compareTo(startStr) < 0 || occ.date.compareTo(endStr) > 0;

      final occParts = occ.date.split('-');
      final occDate = DateTime(
        int.parse(occParts[0]),
        int.parse(occParts[1]),
        int.parse(occParts[2]),
      );
      final moved = movedByDate[occ.date];
      final expectedTime = moved?.newStartTime ?? startTime;
      final wrongSlot =
          occDate.weekday != weekday || occ.startTime != expectedTime;

      if (outsideRange || wrongSlot) {
        await (_db.delete(_db.sessionOccurrences)
              ..where((o) => o.id.equals(occ.id)))
            .go();
        try {
          await _notificationService.cancelLessonReminder(
            templateId,
            occ.date,
          );
        } catch (_) {}
      }
    }

    // Aralık içinde weekday günlerine yerleştir
    for (var day = rangeStart;
        !day.isAfter(rangeEnd);
        day = day.add(const Duration(days: 1))) {
      if (day.weekday != weekday) continue;

      final dateStr = _formatDate(day);
      final moved = movedByDate[dateStr];
      final effectiveStartTime = moved?.newStartTime ?? startTime;
      final effectiveDuration = moved?.newDurationMin ?? durationMin;

      // cancelled override varsa üretme
      final cancelled = await (_db.select(_db.scheduleOverrides)
            ..where(
              (o) =>
                  o.templateId.equals(templateId) &
                  o.date.equals(dateStr) &
                  o.overrideType.equals('cancelled'),
            ))
          .getSingleOrNull();
      if (cancelled != null) continue;

      final existing = await (_db.select(_db.sessionOccurrences)
            ..where(
              (o) =>
                  o.studentId.equals(studentId) &
                  o.date.equals(dateStr) &
                  o.startTime.equals(effectiveStartTime),
            ))
          .getSingleOrNull();

      if (existing != null) {
        if (existing.status == 'planned') {
          await (_db.update(_db.sessionOccurrences)
                ..where((o) => o.id.equals(existing.id)))
              .write(
            SessionOccurrencesCompanion(
              templateId: Value(templateId),
              durationMin: Value(effectiveDuration),
              updatedAt: Value(now),
            ),
          );
        }
        continue;
      }

      await _db.into(_db.sessionOccurrences).insert(
            SessionOccurrencesCompanion.insert(
              id: _uuid.v4(),
              studentId: studentId,
              templateId: Value(templateId),
              date: dateStr,
              startTime: effectiveStartTime,
              durationMin: effectiveDuration,
              status: 'planned',
              notDoneReasonType: const Value.absent(),
              notDoneReasonNote: const Value.absent(),
              paymentId: const Value.absent(),
              completedAt: const Value.absent(),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  /// Şablon ekler.
  /// Aynı öğrenci+gün+saat kaydı varsa:
  /// - aktifse kullanıcıya anlaşılır hata
  /// - pasifse eski kayıt tamamen silinir, yenisi eklenir
  Future<String> insertTemplate({
    required String studentId,
    required int weekday,
    required String startTime,
    required int durationMin,
    required String startDate, // 'YYYY-MM-DD' formatında
    String? endDate, // 'YYYY-MM-DD' — null ise NULL yazılır
  }) async {
    clearOccurrenceEnsureCache();
    final existing = await (_db.select(_db.scheduleTemplates)
          ..where(
            (t) =>
                t.studentId.equals(studentId) &
                t.weekday.equals(weekday) &
                t.startTime.equals(startTime),
          ))
        .getSingleOrNull();

    if (existing != null) {
      if (existing.isActive) {
        throw Exception(
          'Bu öğrenci için seçilen gün ve saatte zaten bir ders planı var. '
          'Önce mevcut planı düzenleyin veya kaldırın.',
        );
      }

      await hardDeleteTemplate(existing.id);
    }

    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.scheduleTemplates).insert(
          ScheduleTemplatesCompanion.insert(
            id: id,
            studentId: studentId,
            weekday: weekday,
            startTime: startTime,
            durationMin: durationMin,
            startDate: startDate,
            endDate: endDate != null ? Value(endDate) : const Value(null),
            isActive: const Value(true),
            createdAt: now,
          ),
        );

    try {
      await _scheduleRemindersForNewTemplate(id, studentId, weekday, startTime);
    } catch (e) {
      print('⚠️ Yeni şablon için bildirimler planlanırken hata (template eklendi): $e');
    }

    return id;
  }

  /// Yeni eklenen şablon için gelecek 7 gün için bildirimleri planlar
  Future<void> _scheduleRemindersForNewTemplate(
    String templateId,
    String studentId,
    int weekday,
    String startTime,
  ) async {
    try {
      // Öğrenci bilgisini al
      final student = await (_db.select(_db.students)
            ..where((s) => s.id.equals(studentId)))
          .getSingleOrNull();
      
      if (student == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Gelecek 7 gün içinde bu weekday'e denk gelen tarihler için bildirim kur
      for (int i = 0; i < 7; i++) {
        final targetDate = today.add(Duration(days: i));
        
        // Eğer bu tarih şablonun weekday'ine denk geliyorsa
        if (targetDate.weekday == weekday) {
          final timeParts = startTime.split(':');
          final startTimeOfDay = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          
          // Bu tarih için occurrence var mı kontrol et
          final dateStr = _formatDate(targetDate);
          final occurrence = await (_db.select(_db.sessionOccurrences)
                ..where((o) => o.templateId.equals(templateId) & o.date.equals(dateStr)))
              .getSingleOrNull();
          
          // Eğer occurrence yoksa veya status 'planned' ise bildirim kur
          if (occurrence == null || occurrence.status == 'planned') {
            await _notificationService.scheduleLessonReminder(
              templateId: templateId,
              date: targetDate,
              startTime: startTimeOfDay,
              studentName: student.fullName,
              reminderMinutes: 10,
            );
          }
        }
      }
    } catch (e) {
      print('Yeni şablon için bildirimler planlanırken hata: $e');
    }
  }

  /// Şablon günceller (kalıcı değişiklik — yeni satır oluşturmaz).
  Future<void> updateTemplate({
    required String id,
    int? weekday,
    String? startTime,
    int? durationMin,
    bool? isActive,
    String? startDate, // 'YYYY-MM-DD'
    String? endDate, // 'YYYY-MM-DD' formatında, null ise değiştirilmez
  }) async {
    // Önce mevcut template'i al
    final oldTemplate = await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    
    if (oldTemplate == null) return;

    final companion = ScheduleTemplatesCompanion(
      weekday: weekday != null ? Value(weekday) : const Value.absent(),
      startTime: startTime != null ? Value(startTime) : const Value.absent(),
      durationMin:
          durationMin != null ? Value(durationMin) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      startDate: startDate != null ? Value(startDate) : const Value.absent(),
      endDate: endDate != null ? Value(endDate) : const Value.absent(),
    );

    await (_db.update(_db.scheduleTemplates)..where((t) => t.id.equals(id)))
        .write(companion);
    
    // Template değiştiyse gelecek 7 gün için bildirimleri yeniden planla
    final effectiveWeekday = weekday ?? oldTemplate.weekday;
    final effectiveStartTime = startTime ?? oldTemplate.startTime;
    final effectiveIsActive = isActive ?? oldTemplate.isActive;
    
    if (effectiveIsActive) {
      // Eski bildirimleri iptal et (gelecek 7 gün için)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      for (int i = 0; i < 7; i++) {
        final targetDate = today.add(Duration(days: i));
        if (targetDate.weekday == oldTemplate.weekday) {
          final dateStr = _formatDate(targetDate);
          await _notificationService.cancelLessonReminder(id, dateStr);
        }
      }
      
      // Yeni bildirimleri kur
      await _scheduleRemindersForNewTemplate(
        id,
        oldTemplate.studentId,
        effectiveWeekday,
        effectiveStartTime,
      );
    }
  }

  /// Haftalık şablonu "değişiklik başlangıç tarihi" ile versionlar: eski şablonu kapatır,
  /// yeni şablon ekler ve sadece [effectiveFrom, newEndDate] aralığında occurrence üretir.
  /// effectiveFrom öncesi takvim/occurrence'lara dokunulmaz.
  ///
  /// [oldTemplateId] Kapatılacak şablonun ID'si.
  /// [effectiveFrom] Değişikliğin geçerli olacağı tarih (bu tarih dahil yeni kural).
  /// [newWeekday], [newStartTime], [newDurationMin] Yeni şablonun değerleri.
  /// [endDate] Yeni şablonun bitiş tarihi; null ise AppSettings varsayılanı kullanılır.
  /// Returns: Yeni oluşturulan template ID.
  Future<String> changeWeeklyTemplateEffectiveFrom({
    required String oldTemplateId,
    required DateTime effectiveFrom,
    required int newWeekday,
    required String newStartTime,
    required int newDurationMin,
    DateTime? endDate,
  }) async {
    final appSettingsRepo = AppSettingsRepository(_db);
    final defaultEndDate = await appSettingsRepo.getDefaultScheduleEndDate();

    final effectiveFromDate = DateTime(effectiveFrom.year, effectiveFrom.month, effectiveFrom.day);
    final effectiveFromStr = _formatDate(effectiveFromDate);
    final newEndDate = endDate != null
        ? DateTime(endDate.year, endDate.month, endDate.day)
        : defaultEndDate;
    final newEndDateStr = _formatDate(newEndDate);

    String? newTemplateId;
    String? studentIdForReminders;

    await _db.transaction(() async {
      // 1) Eski template'i al
      final oldTemplate = await (_db.select(_db.scheduleTemplates)
            ..where((t) => t.id.equals(oldTemplateId)))
          .getSingleOrNull();

      if (oldTemplate == null) {
        throw Exception('Şablon bulunamadı: $oldTemplateId');
      }
      studentIdForReminders = oldTemplate.studentId;

      final oldStartParts = oldTemplate.startDate.split('-');
      final oldStart = DateTime(
        int.parse(oldStartParts[0]),
        int.parse(oldStartParts[1]),
        int.parse(oldStartParts[2]),
      );
      final newEndOld = effectiveFromDate.subtract(const Duration(days: 1));

      // 2) Eski template'i kapat: endDate = effectiveFrom - 1 gün + pasifleştir
      // (listeye çift kayıt düşmesin diye isActive her zaman false)
      if (newEndOld.isBefore(oldStart)) {
        await (_db.update(_db.scheduleTemplates)
              ..where((t) => t.id.equals(oldTemplateId)))
            .write(const ScheduleTemplatesCompanion(isActive: Value(false)));
      } else {
        await (_db.update(_db.scheduleTemplates)
              ..where((t) => t.id.equals(oldTemplateId)))
            .write(ScheduleTemplatesCompanion(
              endDate: Value(_formatDate(newEndOld)),
              isActive: const Value(false),
            ));
      }

      // 3) Yeni template oluştur (INSERT)
      newTemplateId = _uuid.v4();
      final now = DateTime.now();
      await _db.into(_db.scheduleTemplates).insert(
            ScheduleTemplatesCompanion.insert(
              id: newTemplateId!,
              studentId: oldTemplate.studentId,
              weekday: newWeekday,
              startTime: newStartTime,
              durationMin: newDurationMin,
              startDate: effectiveFromStr,
              endDate: Value(newEndDateStr),
              isActive: const Value(true),
              createdAt: now,
            ),
          );

      // 4) Sadece [effectiveFrom, newEndDate] aralığında occurrence üret/güncelle (PRUNE bu aralıkta çalışır)
      await upsertOccurrencesForRange(
        startDate: effectiveFromDate,
        endDate: newEndDate,
        templateId: null, // Tüm aktif template'ler (eski kapatıldı, yeni eklendi)
      );
    });

    try {
      if (studentIdForReminders != null) {
        await _scheduleRemindersForNewTemplate(
          newTemplateId!,
          studentIdForReminders!,
          newWeekday,
          newStartTime,
        );
      }
    } catch (e) {
      // Bildirim hatası işlemi bozmasın
    }

    return newTemplateId!;
  }

  /// Şablon siler: önce pasifleştirir, planlananları temizler;
  /// yapılmış/kaçırılmış yoksa satırı tamamen siler.
  Future<void> deleteTemplate(String id) async {
    clearOccurrenceEnsureCache();
    await (_db
            .update(_db.scheduleTemplates)
              ..where((t) => t.id.equals(id)))
        .write(const ScheduleTemplatesCompanion(isActive: Value(false)));

    await _deletePlannedOccurrencesForInactiveTemplate(id);

    // Geçmiş (done/missed) yoksa hard delete — UNIQUE alan boşalsın
    final kept = await (_db.select(_db.sessionOccurrences)
          ..where(
            (o) =>
                o.templateId.equals(id) &
                (o.status.equals('done') | o.status.equals('missed')),
          ))
        .get();
    if (kept.isEmpty) {
      await hardDeleteTemplate(id);
    }
  }

  /// Şablonu ve bağlı planlanan ders / override kayıtlarını kalıcı siler.
  /// done/missed occurrence'ların templateId'si null yapılır (geçmiş korunur).
  Future<void> hardDeleteTemplate(String templateId) async {
    clearOccurrenceEnsureCache();
    // Planlananları sil
    final planned = await (_db.select(_db.sessionOccurrences)
          ..where(
            (o) =>
                o.templateId.equals(templateId) & o.status.equals('planned'),
          ))
        .get();
    for (final occ in planned) {
      await (_db.delete(_db.sessionOccurrences)
            ..where((o) => o.id.equals(occ.id)))
          .go();
      try {
        await _notificationService.cancelLessonReminder(templateId, occ.date);
      } catch (_) {}
    }

    // Geçmiş kayıtlarda şablon bağını kopar (FK yok ama tutarlılık için)
    await (_db.update(_db.sessionOccurrences)
          ..where(
            (o) =>
                o.templateId.equals(templateId) &
                (o.status.equals('done') | o.status.equals('missed')),
          ))
        .write(const SessionOccurrencesCompanion(templateId: Value(null)));

    // Override'ları sil
    await (_db.delete(_db.scheduleOverrides)
          ..where((o) => o.templateId.equals(templateId)))
        .go();

    // Şablon satırını sil
    await (_db.delete(_db.scheduleTemplates)
          ..where((t) => t.id.equals(templateId)))
        .go();
  }

  /// Pasif şablona ait, 'extra' olmayan planlanan occurrence'ları siler.
  Future<void> _deletePlannedOccurrencesForInactiveTemplate(
    String templateId,
  ) async {
    final planned = await (_db.select(_db.sessionOccurrences)
          ..where(
            (o) =>
                o.templateId.equals(templateId) & o.status.equals('planned'),
          ))
        .get();

    for (final occ in planned) {
      final extraOverride = await (_db.select(_db.scheduleOverrides)
            ..where(
              (ov) =>
                  ov.templateId.equals(templateId) &
                  ov.date.equals(occ.date) &
                  ov.overrideType.equals('extra'),
            ))
          .getSingleOrNull();
      if (extraOverride != null) continue;

      await (_db.delete(_db.sessionOccurrences)
            ..where((o) => o.id.equals(occ.id)))
          .go();
      try {
        await _notificationService.cancelLessonReminder(templateId, occ.date);
      } catch (_) {}
    }
  }

  /// Aktif olmayan / silinmiş şablonlara bağlı planlanan dersleri temizler.
  /// Tekil (extra) dersler korunur. Yapıldı/Yapılmadı kayıtları korunur.
  Future<int> pruneOrphanPlannedOccurrences({
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) async {
    var query = _db.select(_db.sessionOccurrences)
      ..where((o) => o.status.equals('planned'));

    if (rangeStart != null && rangeEnd != null) {
      final startStr = _formatDate(
        DateTime(rangeStart.year, rangeStart.month, rangeStart.day),
      );
      final endStr = _formatDate(
        DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day),
      );
      query = _db.select(_db.sessionOccurrences)
        ..where(
          (o) =>
              o.status.equals('planned') &
              o.date.isBiggerOrEqualValue(startStr) &
              o.date.isSmallerOrEqualValue(endStr),
        );
    }

    final planned = await query.get();
    int deleted = 0;

    for (final occ in planned) {
      final tid = occ.templateId;
      if (tid == null) {
        // Şablonsuz planlanan kayıt — orphan
        await (_db.delete(_db.sessionOccurrences)
              ..where((o) => o.id.equals(occ.id)))
            .go();
        deleted++;
        continue;
      }

      final template = await (_db.select(_db.scheduleTemplates)
            ..where((t) => t.id.equals(tid)))
          .getSingleOrNull();

      if (template == null) {
        await (_db.delete(_db.sessionOccurrences)
              ..where((o) => o.id.equals(occ.id)))
            .go();
        deleted++;
        continue;
      }

      if (template.isActive) continue;

      // Pasif şablon: sadece extra (tekil) değilse sil
      final extraOverride = await (_db.select(_db.scheduleOverrides)
            ..where(
              (ov) =>
                  ov.templateId.equals(tid) &
                  ov.date.equals(occ.date) &
                  ov.overrideType.equals('extra'),
            ))
          .getSingleOrNull();
      if (extraOverride != null) continue;

      await (_db.delete(_db.sessionOccurrences)
            ..where((o) => o.id.equals(occ.id)))
          .go();
      try {
        await _notificationService.cancelLessonReminder(tid, occ.date);
      } catch (_) {}
      deleted++;
    }

    return deleted;
  }

  /// Aktif şablonların start/end penceresi dışındaki planlanan occurrence'ları siler.
  /// Yapıldı/Yapılmadı ve Lesson'a bağlı kayıtlar korunur.
  /// Takvim ay gezintisinde yeşil flaş yapan eski fazla kayıtları temizlemek için.
  Future<int> prunePlannedOutsideActiveTemplateWindows() async {
    final appSettingsRepo = AppSettingsRepository(_db);
    final defaultEndDate = await appSettingsRepo.getDefaultScheduleEndDate();
    final templates = await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.isActive.equals(true)))
        .get();
    if (templates.isEmpty) return 0;

    int deleted = 0;
    for (final template in templates) {
      final startParts = template.startDate.split('-');
      final effectiveStart = DateTime(
        int.parse(startParts[0]),
        int.parse(startParts[1]),
        int.parse(startParts[2]),
      );
      final effectiveEnd = template.endDate != null
          ? () {
              final endParts = template.endDate!.split('-');
              return DateTime(
                int.parse(endParts[0]),
                int.parse(endParts[1]),
                int.parse(endParts[2]),
              );
            }()
          : defaultEndDate;

      final templateOccurrences = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.templateId.equals(template.id)))
          .get();

      for (final occ in templateOccurrences) {
        if (occ.status != 'planned') continue;

        final linkedLesson = await (_db.select(_db.lessons)
              ..where((l) => l.occurrenceId.equals(occ.id)))
            .getSingleOrNull();
        if (linkedLesson != null) continue;

        final occParts = occ.date.split('-');
        final occDate = DateTime(
          int.parse(occParts[0]),
          int.parse(occParts[1]),
          int.parse(occParts[2]),
        );

        if (occDate.isBefore(effectiveStart) || occDate.isAfter(effectiveEnd)) {
          await (_db.delete(_db.sessionOccurrences)
                ..where((o) => o.id.equals(occ.id)))
              .go();
          try {
            await _notificationService.cancelLessonReminder(
              template.id,
              occ.date,
            );
          } catch (_) {}
          deleted++;
        }
      }
    }
    return deleted;
  }

  /// Override ekler (sadece bu hafta değişiklik)
  Future<String> insertOverride({
    required String templateId,
    required String date, // 'YYYY-MM-DD'
    required String overrideType, // 'moved' | 'cancelled' | 'extra'
    int? newWeekday,
    String? newStartTime,
    int? newDurationMin,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.scheduleOverrides).insert(
          ScheduleOverridesCompanion.insert(
            id: id,
            templateId: templateId,
            date: date,
            overrideType: overrideType,
            newWeekday: Value(newWeekday),
            newStartTime: Value(newStartTime),
            newDurationMin: Value(newDurationMin),
            createdAt: now,
          ),
        );

    // Override eklendiğinde eski bildirimi iptal et
    await _notificationService.cancelLessonReminder(templateId, date);
    
    // Eğer cancelled değilse yeni bildirimi planla
    if (overrideType != 'cancelled') {
      // Template bilgisini al
      final template = await (_db.select(_db.scheduleTemplates)
            ..where((t) => t.id.equals(templateId)))
          .getSingleOrNull();
      
      if (template != null) {
        // Öğrenci bilgisini al
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(template.studentId)))
            .getSingleOrNull();
        
        if (student != null) {
          final effectiveStartTime = newStartTime ?? template.startTime;
          final timeParts = effectiveStartTime.split(':');
          final startTimeOfDay = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          
          final dateParts = date.split('-');
          final targetDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          
          // Occurrence kontrolü
          final occurrence = await (_db.select(_db.sessionOccurrences)
                ..where((o) => o.templateId.equals(templateId) & o.date.equals(date)))
            .getSingleOrNull();
          
          // Eğer occurrence yoksa veya status 'planned' ise bildirim kur
          if (occurrence == null || occurrence.status == 'planned') {
            await _notificationService.scheduleLessonReminder(
              templateId: templateId,
              date: targetDate,
              startTime: startTimeOfDay,
              studentName: student.fullName,
              reminderMinutes: 10,
            );
          }
        }
      }
    }

    return id;
  }

  /// Belirli bir tarih için effective schedule hesaplar (stream)
  /// (template + override uygulanmış) - Optimize edilmiş versiyon
  Stream<List<EffectiveScheduleItem>> watchEffectiveScheduleForDate(DateTime date) {
    final weekday = date.weekday; // 1-7
    final dateStr = _formatDate(date);

    // Template'leri stream olarak izle
    final templatesStream = (_db.select(_db.scheduleTemplates)
          ..where((t) => t.weekday.equals(weekday) & t.isActive.equals(true)))
        .watch();

    // Her iki stream'i birleştir ve effective schedule hesapla
    return templatesStream.asyncMap((templates) async {
      if (templates.isEmpty) {
        return <EffectiveScheduleItem>[];
      }

      // Override'ları bir kerede çek
      final overrides = await (_db.select(_db.scheduleOverrides)
            ..where((o) => o.date.equals(dateStr)))
          .get();

      final overrideMap = {
        for (var override in overrides) override.templateId: override
      };

      // Occurrence'ları bir kerede çek
      final occurrences = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.date.equals(dateStr)))
          .get();

      final occurrenceMap = {
        for (var occurrence in occurrences) occurrence.templateId: occurrence
      };

      // Tüm öğrenci ID'lerini topla
      final studentIds = templates.map((t) => t.studentId).toSet();

      // Tüm öğrencileri çek ve filtrele (optimize - tek sorgu)
      final allStudents = await _db.select(_db.students).get();
      final studentMap = {
        for (var student in allStudents.where((s) => studentIds.contains(s.id)))
          student.id: student
      };

      final result = <EffectiveScheduleItem>[];

      for (final template in templates) {
        final override = overrideMap[template.id];

        // Eğer cancelled ise atla
        if (override?.overrideType == 'cancelled') {
          continue;
        }

        // Override varsa onu kullan, yoksa template'i kullan
        final effectiveWeekday = override?.newWeekday ?? template.weekday;
        final effectiveStartTime = override?.newStartTime ?? template.startTime;
        final effectiveDuration = override?.newDurationMin ?? template.durationMin;

        // Occurrence bilgisini al
        final occurrence = occurrenceMap[template.id];

        // Öğrenci bilgisini map'ten al (optimize)
        final student = studentMap[template.studentId];

        if (student != null) {
          result.add(EffectiveScheduleItem(
            templateId: template.id,
            studentId: template.studentId,
            studentName: student.fullName,
            weekday: effectiveWeekday,
            startTime: effectiveStartTime,
            durationMin: effectiveDuration,
            date: date,
            occurrenceId: occurrence?.id,
            status: occurrence?.status,
            notDoneReasonType: occurrence?.notDoneReasonType,
            notDoneReasonNote: occurrence?.notDoneReasonNote,
          ));
        }
      }

      // Saate göre sırala
      result.sort((a, b) => a.startTime.compareTo(b.startTime));

      return result;
    });
  }

  /// Belirli bir tarih için effective schedule hesaplar
  /// (template + override uygulanmış) - Future versiyonu (geriye uyumluluk için)
  Future<List<EffectiveScheduleItem>> getEffectiveSchedule(DateTime date) async {
    final weekday = date.weekday; // 1-7
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dateStr = _formatDate(dateOnly);

    final appSettingsRepo = AppSettingsRepository(_db);
    final defaultEndDate = await appSettingsRepo.getDefaultScheduleEndDate();

    // O günün şablonlarını getir
    final templates = await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.weekday.equals(weekday) & t.isActive.equals(true)))
        .get();

    // O günün override'larını getir
    final overrides = await (_db.select(_db.scheduleOverrides)
          ..where((o) => o.date.equals(dateStr)))
        .get();

    // Override'ları map'e çevir (templateId -> override)
    final overrideMap = {
      for (var override in overrides) override.templateId: override
    };

    // Occurrence'ları getir
    final occurrences = await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.date.equals(dateStr)))
        .get();

    final occurrenceMap = {
      for (var occurrence in occurrences)
        if (occurrence.templateId != null) occurrence.templateId!: occurrence
    };

    // Aktif öğrencileri tek sorguda al (N+1 yok)
    final studentIds = templates.map((t) => t.studentId).toSet().toList();
    final students = studentIds.isEmpty
        ? <Student>[]
        : await (_db.select(_db.students)
              ..where(
                (s) => s.id.isIn(studentIds) & s.isActive.equals(true),
              ))
            .get();
    final studentMap = {for (final s in students) s.id: s};

    final result = <EffectiveScheduleItem>[];

    for (final template in templates) {
      final override = overrideMap[template.id];

      // Eğer cancelled ise atla
      if (override?.overrideType == 'cancelled') {
        continue;
      }

      // Şablon tarih penceresi dışında üretme / gösterme
      final startParts = template.startDate.split('-');
      final templateStart = DateTime(
        int.parse(startParts[0]),
        int.parse(startParts[1]),
        int.parse(startParts[2]),
      );
      final templateEnd = template.endDate != null
          ? () {
              final p = template.endDate!.split('-');
              return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
            }()
          : defaultEndDate;
      if (dateOnly.isBefore(templateStart) || dateOnly.isAfter(templateEnd)) {
        continue;
      }

      // Override varsa onu kullan, yoksa template'i kullan
      final effectiveWeekday = override?.newWeekday ?? template.weekday;
      final effectiveStartTime = override?.newStartTime ?? template.startTime;
      final effectiveDuration = override?.newDurationMin ?? template.durationMin;

      // Occurrence bilgisini al
      final occurrence = occurrenceMap[template.id];

      final student = studentMap[template.studentId];

      if (student != null) {
        result.add(EffectiveScheduleItem(
          templateId: template.id,
          studentId: template.studentId,
          studentName: student.fullName,
          weekday: effectiveWeekday,
          startTime: effectiveStartTime,
          durationMin: effectiveDuration,
          date: dateOnly,
          occurrenceId: occurrence?.id,
          status: occurrence?.status,
          notDoneReasonType: occurrence?.notDoneReasonType,
          notDoneReasonNote: occurrence?.notDoneReasonNote,
        ));
      }
    }

    // Saate göre sırala
    result.sort((a, b) => a.startTime.compareTo(b.startTime));

    return result;
  }

  /// Occurrence oluşturur veya günceller
  Future<String> upsertOccurrenceForTemplateDate({
    String? templateId, // NULL olabilir (extra/ertelemeler için)
    required String date, // 'YYYY-MM-DD'
    required String startTime, // 'HH:mm'
    required int durationMin,
    required String status, // 'planned' | 'done' | 'not_done'
    String? notDoneReasonType,
    String? notDoneReasonNote,
    required String studentId, // Artık zorunlu - templateId null olabilir
  }) async {
    final now = DateTime.now();
    
    // studentId zorunlu (templateId null olabilir)
    final finalStudentId = studentId;
    
    // Mevcut occurrence'ı kontrol et (yeni unique: studentId|date|startTime)
    final existing = await (_db.select(_db.sessionOccurrences)
          ..where(
            (o) => o.studentId.equals(finalStudentId) &
                o.date.equals(date) &
                o.startTime.equals(startTime),
          ))
        .getSingleOrNull();
    
    final oldStatus = existing?.status;
    
    if (existing != null) {
      // Update
      await (_db.update(_db.sessionOccurrences)
            ..where((o) => o.id.equals(existing.id)))
          .write(SessionOccurrencesCompanion(
            status: Value(status),
            notDoneReasonType: Value(notDoneReasonType),
            notDoneReasonNote: Value(notDoneReasonNote),
            durationMin: Value(durationMin),
            updatedAt: Value(now),
          ));
      
      // Status değiştiyse bildirimleri güncelle (templateId varsa)
      if (oldStatus != status && existing.templateId != null) {
        if (status == 'done' || status == 'not_done' || status == 'missed') {
          // Bildirimi iptal et
          await _notificationService.cancelLessonReminder(
            existing.templateId!,
            date,
          );
        } else if (status == 'planned') {
          // Bildirimi planla
          final dateParts = date.split('-');
          final dateTime = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          final timeParts = startTime.split(':');
          final timeOfDay = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          
          // Öğrenci bilgisini al
          final student = await (_db.select(_db.students)
                ..where((s) => s.id.equals(finalStudentId)))
              .getSingleOrNull();
          if (student != null) {
            await _notificationService.scheduleLessonReminder(
              templateId: existing.templateId!,
              date: dateTime,
              startTime: timeOfDay,
              studentName: student.fullName,
              reminderMinutes: 10,
            );
          }
        }
      }
      
      return existing.id;
    } else {
      // Insert
      final id = _uuid.v4();
      await _db.into(_db.sessionOccurrences).insert(
            SessionOccurrencesCompanion.insert(
              id: id,
              studentId: finalStudentId,
              templateId: Value(templateId), // NULL olabilir
              date: date,
              startTime: startTime,
              durationMin: durationMin,
              status: status,
              notDoneReasonType: Value(notDoneReasonType),
              notDoneReasonNote: Value(notDoneReasonNote),
              createdAt: now,
              updatedAt: now,
            ),
          );
      
      // Eğer planned ise bildirimi planla (templateId varsa)
      if (status == 'planned' && templateId != null) {
        final dateParts = date.split('-');
        final dateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
        );
        final timeParts = startTime.split(':');
        final timeOfDay = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        
        // Öğrenci bilgisini al
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(finalStudentId)))
            .getSingleOrNull();
        if (student != null) {
          await _notificationService.scheduleLessonReminder(
            templateId: templateId,
            date: dateTime,
            startTime: timeOfDay,
            studentName: student.fullName,
            reminderMinutes: 10,
          );
        }
      }
      
      return id;
    }
  }

  /// Occurrence için ders kaydı oluşturur (konu, ödev, ders notu ile)
  Future<String> createLessonForOccurrence({
    required String occurrenceId,
    required String studentId,
    required DateTime startDateTime,
    required int durationMin,
    required int hourlyRate,
    String? topic,
    String? homework,
    String? homeworkResource,
    String? lessonNotes,
    int feePaidAmount = 0,
    String? note,
  }) async {
    // Eğer occurrenceId zaten Lessons'ta varsa hata
    final existingLesson = await (_db.select(_db.lessons)
          ..where((l) => l.occurrenceId.equals(occurrenceId)))
        .getSingleOrNull();
    
    if (existingLesson != null) {
      throw Exception('Bu ders için zaten kayıt var');
    }
    
    // Occurrence bilgisini al (bildirimi iptal etmek için)
    final occurrence = await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .getSingleOrNull();
    
    // Occurrence'ı done olarak işaretle
    await (_db.update(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .write(SessionOccurrencesCompanion(
          status: const Value('done'),
          updatedAt: Value(DateTime.now()),
        ));
    
    // Bildirimi iptal et (templateId varsa)
    if (occurrence != null && occurrence.templateId != null) {
      await _notificationService.cancelLessonReminder(
        occurrence.templateId!,
        occurrence.date,
      );
    }
    
    // Ders kaydı oluştur (LessonsRepository'deki createLessonFromSchedule benzeri)
    final feeExpected = ((hourlyRate * durationMin) / 60).round();
    final id = _uuid.v4();
    final now = DateTime.now();
    
    await _db.into(_db.lessons).insert(
          LessonsCompanion.insert(
            id: id,
            studentId: studentId,
            occurrenceId: Value(occurrenceId),
            startDateTime: startDateTime,
            durationMin: durationMin,
            topic: Value(topic),
            homework: Value(homework),
            homeworkResource: homeworkResource != null
                ? Value(homeworkResource)
                : const Value.absent(),
            lessonNotes: lessonNotes != null ? Value(lessonNotes) : const Value.absent(),
            feeExpected: feeExpected,
            feePaidAmount: feePaidAmount,
            note: Value(note),
            status: const Value('done'),
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

  /// Occurrence'ı "yapıldı" olarak işaretler.
  /// SADECE status='done' ve completedAt güncellenir.
  /// Ödeme oluşturulmaz - ödemeler ekranında "ALACAK" olarak görünecek.
  Future<void> markDone(String occurrenceId) async {
    final now = DateTime.now();
    
    final occurrence = await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .getSingleOrNull();
    
    if (occurrence == null) {
      throw Exception('Occurrence bulunamadı: $occurrenceId');
    }
    
    await (_db.update(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .write(SessionOccurrencesCompanion(
          status: const Value('done'),
          completedAt: Value(now),
          updatedAt: Value(now),
        ));
    
    // Bildirimi iptal et
    if (occurrence.templateId != null) {
      await _notificationService.cancelLessonReminder(
        occurrence.templateId!,
        occurrence.date,
      );
    }
  }

  /// Occurrence'ı "yapılmadı" olarak işaretler.
  /// SADECE status='missed' güncellenir.
  Future<void> markMissed(String occurrenceId) async {
    final now = DateTime.now();
    final occurrence = await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .getSingleOrNull();
    if (occurrence == null) {
      throw Exception('Occurrence bulunamadı: $occurrenceId');
    }
    await (_db.update(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .write(SessionOccurrencesCompanion(
          status: const Value('missed'),
          updatedAt: Value(now),
        ));
    if (occurrence.templateId != null) {
      await _notificationService.cancelLessonReminder(
        occurrence.templateId!,
        occurrence.date,
      );
    }
  }

  /// Occurrence'ı "yapılmadı" olarak işaretler; sebep ve kaynak kaydeder.
  /// source: 'TEACHER' | 'STUDENT' -> notDoneReasonType: teacher_cancelled | student_cancelled
  Future<void> markMissedWithReason({
    required String occurrenceId,
    required String source,
    required String reason,
    String? note,
  }) async {
    final now = DateTime.now();
    final occurrence = await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .getSingleOrNull();
    if (occurrence == null) {
      throw Exception('Occurrence bulunamadı: $occurrenceId');
    }
    final reasonType = source == 'TEACHER' ? 'teacher_cancelled' : 'student_cancelled';
    // Sebep ve ek notu ayırı sakla: ek not yoksa sadece sebep; varsa "sebep\n---\nek not"
    const delimiter = '\n---\n';
    final fullNote = (note != null && note.isNotEmpty) ? '$reason$delimiter$note' : reason;
    await (_db.update(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .write(SessionOccurrencesCompanion(
          status: const Value('missed'),
          notDoneReasonType: Value(reasonType),
          notDoneReasonNote: Value(fullNote),
          updatedAt: Value(now),
        ));
    if (occurrence.templateId != null) {
      await _notificationService.cancelLessonReminder(
        occurrence.templateId!,
        occurrence.date,
      );
    }
  }

  /// Dersi başka bir tarihe taşır (ertele) - ESKİ FONKSİYON (geriye uyumluluk için)
  /// SADECE O SessionOccurrence güncellenir, template'e dokunulmaz
  /// Çakışma kontrolü yapar: startAt < newEnd AND endAt > newStart
  @Deprecated('Use postponeByMove instead - it deletes old and inserts new occurrence')
  Future<bool> postponeOccurrence({
    required String occurrenceId,
    required DateTime newDate,
    required TimeOfDay newTime,
    int? newDurationMin,
  }) async {
    return await postponeByMove(
      oldOccurrenceId: occurrenceId,
      newDate: newDate,
      newStartTime: newTime,
      newDurationMin: newDurationMin,
    );
  }

  /// Dersi başka bir tarihe taşır (ertele) - YENİ FONKSİYON
  /// DB UYGULAMA: DELETE + INSERT (taşı)
  /// A) Yeni occurrence oluştur (insert); erteleme sebebi ve eski tarih yazılır
  /// B) Eski occurrence'ı delete et
  /// Böylece eski kaydı hem takvimden hem DB'den kaldırmış olacağız.
  /// Transaction içinde yapılır.
  Future<bool> postponeByMove({
    required String oldOccurrenceId,
    required DateTime newDate,
    required TimeOfDay newStartTime,
    int? newDurationMin,
    String? postponementReason,
  }) async {
    try {
      // Mevcut occurrence'ı al
      final oldOccurrence = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.id.equals(oldOccurrenceId)))
          .getSingleOrNull();
      
      if (oldOccurrence == null) {
        throw Exception('Occurrence bulunamadı: $oldOccurrenceId');
      }
      
      // Öğrenci bilgisini direkt occurrence'dan al
      final student = await (_db.select(_db.students)
            ..where((s) => s.id.equals(oldOccurrence.studentId)))
          .getSingleOrNull();
      
      if (student == null) {
        throw Exception('Öğrenci bulunamadı: ${oldOccurrence.studentId}');
      }
      
      // Yeni tarih ve saat bilgileri
      final newDateStr = _formatDate(newDate);
      final newTimeStr = _formatTime(newStartTime);
      final effectiveDuration = newDurationMin ?? oldOccurrence.durationMin;
      
      // Yeni başlangıç ve bitiş zamanları
      final newStartDateTime = DateTime(
        newDate.year,
        newDate.month,
        newDate.day,
        newStartTime.hour,
        newStartTime.minute,
      );
      final newEndDateTime =
          newStartDateTime.add(Duration(minutes: effectiveDuration));
      
      // ÇAKIŞMA KONTROLÜ: Aynı öğrenci için başka bir occurrence var mı?
      // time overlap: existingStart < newEnd AND existingEnd > newStart
      // exclude: existing.id != oldOccurrenceId
      final hasConflict = await checkConflict(
        studentId: oldOccurrence.studentId,
        newStart: newStartDateTime,
        newEnd: newEndDateTime,
        excludeOccurrenceId: oldOccurrenceId,
      );
      if (hasConflict) {
        return false; // Çakışma var
      }
      
      // Eski bildirimi iptal et (templateId varsa)
      if (oldOccurrence.templateId != null) {
        try {
          await _notificationService.cancelLessonReminder(
            oldOccurrence.templateId!,
            oldOccurrence.date,
          );
        } catch (e) {
          // Bildirim iptal hatası kritik değil
          print('Bildirim iptal hatası (göz ardı edildi): $e');
        }
      }
      
      // TRANSACTION: insert(newOcc) + delete(oldOcc) + create override for old date
      final now = DateTime.now();
      await _db.transaction(() async {
        // Yeni occurrence oluştur (insert)
        final newOccurrenceId = _uuid.v4();
        await _db.into(_db.sessionOccurrences).insert(
              SessionOccurrencesCompanion.insert(
                id: newOccurrenceId,
                studentId: oldOccurrence.studentId, // aynı studentId
                templateId: Value(oldOccurrence.templateId), // templateId aynı kalabilir veya null olabilir
                date: newDateStr, // yeni tarih
                startTime: newTimeStr, // yeni saat
                durationMin: effectiveDuration, // yeni süre
                status: 'planned',
                notDoneReasonType: const Value.absent(),
                notDoneReasonNote: const Value.absent(),
                paymentId: const Value.absent(),
                completedAt: const Value.absent(),
                postponedFromDate: Value(oldOccurrence.date), // eski tarih (ertelenen dersler listesi için)
                postponedReason: postponementReason != null && postponementReason.isNotEmpty
                    ? Value(postponementReason)
                    : const Value.absent(),
                createdAt: now,
                updatedAt: now,
              ),
            );
        
        // Eski occurrence'ı delete et
        await (_db.delete(_db.sessionOccurrences)
              ..where((o) => o.id.equals(oldOccurrenceId)))
            .go();
        
        // ÖNEMLİ: Eski tarih için override oluştur (cancelled)
        // Böylece template'den tekrar occurrence üretilmez
        if (oldOccurrence.templateId != null) {
          // Eski tarih için override var mı kontrol et
          final existingOverride = await (_db.select(_db.scheduleOverrides)
                ..where(
                  (o) => o.templateId.equals(oldOccurrence.templateId!) &
                      o.date.equals(oldOccurrence.date),
                ))
              .getSingleOrNull();
          
          // Eğer override yoksa, cancelled override oluştur
          if (existingOverride == null) {
            final overrideId = _uuid.v4();
            await _db.into(_db.scheduleOverrides).insert(
                  ScheduleOverridesCompanion.insert(
                    id: overrideId,
                    templateId: oldOccurrence.templateId!,
                    date: oldOccurrence.date, // eski tarih
                    overrideType: 'cancelled', // cancelled = bu gün occurrence üretilmez
                    createdAt: now,
                  ),
                );
          }
        }
      });
      
      // Yeni bildirimi planla (templateId varsa)
      if (oldOccurrence.templateId != null) {
        try {
          await _notificationService.scheduleLessonReminder(
            templateId: oldOccurrence.templateId!,
            date: newDate,
            startTime: newStartTime,
            studentName: student.fullName,
            reminderMinutes: 10,
          );
        } catch (e) {
          // Bildirim planlama hatası kritik değil
          print('Bildirim planlama hatası (göz ardı edildi): $e');
        }
      }
      
      return true; // Başarılı
    } catch (e, stackTrace) {
      print('postponeByMove hatası: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Occurrence'ı ID'ye göre getirir
  Future<SessionOccurrence?> getOccurrenceById(String occurrenceId) async {
    return await (_db.select(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .getSingleOrNull();
  }

  /// Occurrence'ı siler
  Future<void> deleteOccurrence(String occurrenceId) async {
    try {
      // Occurrence'ı al
      final occurrence = await (_db.select(_db.sessionOccurrences)
            ..where((o) => o.id.equals(occurrenceId)))
          .getSingleOrNull();
      
      if (occurrence != null && occurrence.templateId != null) {
        // Bildirimi iptal et (templateId varsa)
        try {
          await _notificationService.cancelLessonReminder(
            occurrence.templateId!,
            occurrence.date,
          );
        } catch (e) {
          // Bildirim iptal hatası kritik değil
          print('Bildirim iptal hatası (göz ardı edildi): $e');
        }
      }
      
      // Occurrence'ı sil
      await (_db.delete(_db.sessionOccurrences)
            ..where((o) => o.id.equals(occurrenceId)))
          .go();
    } catch (e, stackTrace) {
      print('deleteOccurrence hatası: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Stream<List<SessionOccurrenceWithStudent>> watchNotDoneOccurrences() {
    return (_db.select(_db.sessionOccurrences)
          ..where((o) => o.status.equals('missed'))
          ..orderBy([(o) => OrderingTerm(expression: o.date, mode: OrderingMode.desc)]))
        .watch()
        .asyncMap((occurrences) async {
      final result = <SessionOccurrenceWithStudent>[];
      
      for (final occurrence in occurrences) {
        // Öğrenciyi direkt occurrence'dan al (artık studentId var)
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(occurrence.studentId)))
            .getSingleOrNull();
        
        if (student == null) continue;
        
        // Template'i al (templateId varsa)
        ScheduleTemplate? template;
        if (occurrence.templateId != null) {
          template = await (_db.select(_db.scheduleTemplates)
                ..where((t) => t.id.equals(occurrence.templateId!)))
              .getSingleOrNull();
        }
        
        // Template null olsa bile occurrence'ı ekle (template opsiyonel)
        // Eğer template null ise, dummy template oluştur
        final finalTemplate = template ?? ScheduleTemplate(
          id: '',
          studentId: occurrence.studentId, // studentId NOT NULL, güvenli
          weekday: 0,
          startTime: occurrence.startTime,
          durationMin: occurrence.durationMin,
          startDate: occurrence.date, // Dummy template için occurrence tarihini kullan
          endDate: null,
          isActive: false,
          createdAt: occurrence.createdAt,
        );
        
        result.add(SessionOccurrenceWithStudent(
          occurrence: occurrence,
          student: student,
          template: finalTemplate,
        ));
      }
      
      return result;
    });
  }

  /// "Yapıldı" olan ve ödeme alınmamış (paymentId IS NULL) dersleri getirir
  /// Ödemeler ekranında seçim için kullanılır
  Stream<List<SessionOccurrenceWithStudent>> watchDoneUnpaidOccurrences() {
    return (_db.select(_db.sessionOccurrences)
          ..where((o) => 
              o.status.equals('done') & 
              o.paymentId.isNull())
          ..orderBy([(o) => OrderingTerm(expression: o.date, mode: OrderingMode.desc)]))
        .watch()
        .asyncMap((occurrences) async {
      final result = <SessionOccurrenceWithStudent>[];
      
      for (final occurrence in occurrences) {
        // Öğrenciyi direkt occurrence'dan al (artık studentId var)
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(occurrence.studentId)))
            .getSingleOrNull();
        
        if (student == null) continue;
        
        // Template'i al (templateId varsa)
        ScheduleTemplate? template;
        if (occurrence.templateId != null) {
          template = await (_db.select(_db.scheduleTemplates)
                ..where((t) => t.id.equals(occurrence.templateId!)))
              .getSingleOrNull();
        }
        
        // Template null olsa bile occurrence'ı ekle (template opsiyonel)
        // Eğer template null ise, dummy template oluştur
        final finalTemplate = template ?? ScheduleTemplate(
          id: '',
          studentId: occurrence.studentId, // studentId NOT NULL, güvenli
          weekday: 0,
          startTime: occurrence.startTime,
          durationMin: occurrence.durationMin,
          startDate: occurrence.date, // Dummy template için occurrence tarihini kullan
          endDate: null,
          isActive: false,
          createdAt: occurrence.createdAt,
        );
        
        result.add(SessionOccurrenceWithStudent(
          occurrence: occurrence,
          student: student,
          template: finalTemplate,
        ));
      }
      
      return result;
    });
  }

  /// "Yapıldı" olan TÜM dersleri getirir (ödendi + ödenmedi)
  /// Öğrenci detay ekranında geçmiş dersler için kullanılır
  Stream<List<SessionOccurrenceWithStudent>> watchDoneOccurrences({
    String? studentId,
  }) {
    var query = _db.select(_db.sessionOccurrences)
      ..where((o) => o.status.equals('done'));
    
    // Öğrenci filtresi
    if (studentId != null) {
      query = query..where((o) => o.studentId.equals(studentId));
    }
    
    query = query..orderBy([(o) => OrderingTerm(expression: o.date, mode: OrderingMode.desc)]);
    
    return query.watch().asyncMap((occurrences) async {
      final result = <SessionOccurrenceWithStudent>[];
      
      for (final occurrence in occurrences) {
        // Öğrenciyi direkt occurrence'dan al (artık studentId var)
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(occurrence.studentId)))
            .getSingleOrNull();
        
        if (student == null) continue;
        
        // Template'i al (templateId varsa)
        ScheduleTemplate? template;
        if (occurrence.templateId != null) {
          template = await (_db.select(_db.scheduleTemplates)
                ..where((t) => t.id.equals(occurrence.templateId!)))
              .getSingleOrNull();
        }
        
        // Template null olsa bile occurrence'ı ekle (template opsiyonel)
        // Eğer template null ise, dummy template oluştur
        final finalTemplate = template ?? ScheduleTemplate(
          id: '',
          studentId: occurrence.studentId, // studentId NOT NULL, güvenli
          weekday: 0,
          startTime: occurrence.startTime,
          durationMin: occurrence.durationMin,
          startDate: occurrence.date, // Dummy template için occurrence tarihini kullan
          endDate: null,
          isActive: false,
          createdAt: occurrence.createdAt,
        );
        
        result.add(SessionOccurrenceWithStudent(
          occurrence: occurrence,
          student: student,
          template: finalTemplate,
        ));
      }
      
      return result;
    });
  }

  /// Belirli bir öğrenci ve zaman aralığı için occurrence çakışması var mı kontrol eder.
  ///
  /// Çakışma kuralı:
  ///   (existingStart < newEnd) AND (existingEnd > newStart)
  ///
  /// - studentId: Öğrenci ID
  /// - newStart: Yeni ders başlangıç DateTime
  /// - newEnd: Yeni ders bitiş DateTime
  /// - excludeOccurrenceId: Kendisiyle kıyaslamamak için hariç tutulacak occurrence ID
  Future<bool> checkConflict({
    required String studentId,
    required DateTime newStart,
    required DateTime newEnd,
    String? excludeOccurrenceId,
  }) async {
    // Sadece aynı gün içindeki dersler çakışma adayıdır (özel dersler için yeterli).
    final dateStr = _formatDate(newStart);

    // Öğrencinin tüm occurrence'larını (aynı gün) direkt studentId ile bul.
    final occurrences = await (_db.select(_db.sessionOccurrences)
          ..where(
            (o) => o.date.equals(dateStr) & o.studentId.equals(studentId),
          ))
        .get();

    for (final occurrence in occurrences) {
      if (excludeOccurrenceId != null && occurrence.id == excludeOccurrenceId) {
        continue;
      }

      // Tarih ve saat bilgisini parse et
      final dateParts = occurrence.date.split('-');
      final timeParts = occurrence.startTime.split(':');
      final existingStart = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      final existingEnd =
          existingStart.add(Duration(minutes: occurrence.durationMin));

      // Çakışma kontrolü
      if (existingStart.isBefore(newEnd) && existingEnd.isAfter(newStart)) {
        return true;
      }
    }

    return false;
  }

  /// Belirli bir occurrence'ı "reset" eder.
  ///
  /// Kurallar:
  /// - status = 'planned'
  /// - completedAt = NULL
  /// - paymentId = NULL
  /// - notDoneReasonType/Note = NULL
  /// - İlgili Payments kaydı SİLİNMEZ (bağımsız ödeme olarak kalır).
  Future<void> resetOccurrence(String occurrenceId) async {
    final now = DateTime.now();

    await (_db.update(_db.sessionOccurrences)
          ..where((o) => o.id.equals(occurrenceId)))
        .write(
      const SessionOccurrencesCompanion(
        status: Value('planned'),
        notDoneReasonType: Value(null),
        notDoneReasonNote: Value(null),
        paymentId: Value(null),
        completedAt: Value(null),
      ).copyWith(
        updatedAt: Value(now),
      ),
    );
  }

  /// Seçilen tarih aralığı için occurrence üretir ve veritabanına yazar.
  ///
  /// Kurallar:
  /// - Kaynak: Sadece aktif ScheduleTemplates
  /// - Aralık: [max(viewStart, template.startDate), min(viewEnd, template.endDate ?? AppSettings.default_schedule_end_date)]
  /// - Template'in startDate'inden önce occurrence üretilmez
  /// - Template'in endDate'inden sonra occurrence üretilmez (null ise AppSettings kullanılır)
  /// - Unique(studentId, date, startTime) kuralına uyar, yoksa INSERT eder.
  /// - ScheduleOverrides:
  ///   - cancelled: o gün occurrence oluşturulmaz; varsa ve status='planned'
  ///                olan occurrence silinir.
  ///   - moved: ilgili occurrence, override'daki yeni saat/süre bilgisine göre
  ///            üretilir.
  ///   - extra: override.date için "tekil ders" occurrence üretir.
  Future<void> upsertOccurrencesForRange({
    required DateTime startDate,
    required DateTime endDate,
    String? templateId, // Belirli bir template için (opsiyonel)
  }) async {
    if (endDate.isBefore(startDate)) return;

    // Tarihleri normalize et (sadece gün)
    var rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    var rangeEnd = DateTime(endDate.year, endDate.month, endDate.day);

    // Global/ayar bitiş tarihi: yalnızca şablonda endDate YOKSA kullanılır.
    // Kullanıcının şablona yazdığı bitiş tarihi asla ayar tarihine kırpılmaz.
    final appSettingsRepo = AppSettingsRepository(_db);
    final defaultEndDate = await appSettingsRepo.getDefaultScheduleEndDate();

    if (rangeEnd.isBefore(rangeStart)) return;

    final startStr = _formatDate(rangeStart);
    final endStr = _formatDate(rangeEnd);

    // Pasif/eksik şablonlara bağlı planlanan (orphan) dersleri temizle
    await pruneOrphanPlannedOccurrences(
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );

    // Tüm aktif template'leri al
    final templates = await (_db.select(_db.scheduleTemplates)
          ..where((t) => t.isActive.equals(true)))
        .get();
    if (templates.isEmpty) return;

    final templateMap = {for (var t in templates) t.id: t};
    // İlgili aralıktaki tüm occurrence'ları al
    final occurrences = await (_db.select(_db.sessionOccurrences)
          ..where(
            (o) => o.date.isBiggerOrEqualValue(startStr) &
                o.date.isSmallerOrEqualValue(endStr),
          ))
        .get();

    // Unique key: studentId|date|startTime (yeni unique constraint)
    final occurrenceMap = <String, SessionOccurrence>{
      for (final o in occurrences) '${o.studentId}|${o.date}|${o.startTime}': o,
    };

    // İlgili aralıktaki override'ları al
    final overrides = await (_db.select(_db.scheduleOverrides)
          ..where(
            (o) => o.date.isBiggerOrEqualValue(startStr) &
                o.date.isSmallerOrEqualValue(endStr),
          ))
        .get();

    final overrideMap = <String, ScheduleOverride>{};
    final extraOverrides = <ScheduleOverride>[];

    for (final o in overrides) {
      if (o.overrideType == 'extra') {
        extraOverrides.add(o);
      } else {
        overrideMap['${o.templateId}|${o.date}'] = o;
      }
    }

    final now = DateTime.now();

    await _db.transaction(() async {
      // Her template için önce pencere dışı planned'ı temizle, sonra üret.
      // (Ara durumda eski yeşillerin stream'e düşmesini engeller.)
      for (final template in templates) {
        // Template ID filtresi (opsiyonel)
        if (templateId != null && template.id != templateId) {
          continue;
        }
        
        // Template'in startDate ve endDate'ini parse et
        final templateStartDateParts = template.startDate.split('-');
        final effectiveStart = DateTime(
          int.parse(templateStartDateParts[0]),
          int.parse(templateStartDateParts[1]),
          int.parse(templateStartDateParts[2]),
        );
        
        // Template'in endDate'i (null ise defaultEndDate kullan)
        final effectiveEnd = template.endDate != null
            ? (() {
                final templateEndDateParts = template.endDate!.split('-');
                return DateTime(
                  int.parse(templateEndDateParts[0]),
                  int.parse(templateEndDateParts[1]),
                  int.parse(templateEndDateParts[2]),
                );
              })()
            : defaultEndDate;
        
        // DEBUG LOG (sadece debug mode'da)
        assert(() {
          print('🔍 Template Debug:');
          print('  template.id: ${template.id}');
          print('  template.startDate: ${template.startDate}');
          print('  template.endDate: ${template.endDate}');
          print('  defaultEndDate: ${_formatDate(defaultEndDate)}');
          print('  effectiveStart: ${_formatDate(effectiveStart)}');
          print('  effectiveEnd: ${_formatDate(effectiveEnd)}');
          return true;
        }());
        
        // KIRMIZI ÇİZGİ KURALI: effectiveEnd < effectiveStart ise üretme (yine de prune yap)
        final hasValidWindow = !effectiveEnd.isBefore(effectiveStart);
        
        // Üretilecek kesişim: genStart = max(viewStart, effectiveStart), genEnd = min(viewEnd, effectiveEnd)
        final viewStart = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
        final viewEnd = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
        
        final genStart = viewStart.isAfter(effectiveStart) ? viewStart : effectiveStart;
        final genEnd = viewEnd.isBefore(effectiveEnd) ? viewEnd : effectiveEnd;
        
        // DEBUG LOG (sadece debug mode'da)
        assert(() {
          print('  genStart: ${_formatDate(genStart)}');
          print('  genEnd: ${_formatDate(genEnd)}');
          return true;
        }());

        // PRUNE ÖNCE: şablon penceresi / gün-saat uyumsuz planned'ları sil
        final templateOccurrences = await (_db.select(_db.sessionOccurrences)
              ..where((o) => o.templateId.equals(template.id)))
          .get();
        
        for (final occ in templateOccurrences) {
          if (occ.status != 'planned') {
            continue;
          }

          final linkedLesson = await (_db.select(_db.lessons)
                ..where((l) => l.occurrenceId.equals(occ.id)))
              .getSingleOrNull();
          if (linkedLesson != null) {
            continue;
          }
          
          final occDateParts = occ.date.split('-');
          final occDate = DateTime(
            int.parse(occDateParts[0]),
            int.parse(occDateParts[1]),
            int.parse(occDateParts[2]),
          );
          
          final dateCompare = occDate.compareTo(effectiveStart);
          final endCompare = occDate.compareTo(effectiveEnd);
          
          if (dateCompare < 0 || endCompare > 0) {
            await (_db.delete(_db.sessionOccurrences)
                  ..where((o) => o.id.equals(occ.id)))
                .go();
            occurrenceMap.remove('${occ.studentId}|${occ.date}|${occ.startTime}');
            continue;
          }

          if (occDate.weekday != template.weekday ||
              occ.startTime != template.startTime) {
            // moved override ile saat değişmiş olabilir — override yoksa sil
            final ov = overrideMap['${template.id}|${occ.date}'];
            if (ov == null || ov.overrideType != 'moved') {
              await (_db.delete(_db.sessionOccurrences)
                    ..where((o) => o.id.equals(occ.id)))
                  .go();
              occurrenceMap.remove('${occ.studentId}|${occ.date}|${occ.startTime}');
            }
          }
        }
        
        // SADECE genStart..genEnd aralığında üret (kesişim varsa)
        if (hasValidWindow && !genStart.isAfter(genEnd)) {
        // SADECE genStart..genEnd aralığında, template.weekday'e denk gelen günlerde üret
        // genStart'tan önceki weekday günlerine dönüp üretme (en büyük hata bu)
        for (var current = genStart;
            !current.isAfter(genEnd);
            current = current.add(const Duration(days: 1))) {
          // Sadece template'in weekday'ine denk gelen günlerde üret
          if (current.weekday != template.weekday) {
            continue;
          }
          
          final dateStr = _formatDate(current);
          
          final override = overrideMap['${template.id}|$dateStr'];

          // cancelled: occurrence oluşturma, varsa planned'ı sil
          if (override?.overrideType == 'cancelled') {
            // Template'in normal saatini kullanarak key oluştur
            final key = '${template.studentId}|$dateStr|${template.startTime}';
            final existing = occurrenceMap[key];
            if (existing != null && existing.status == 'planned') {
              await (_db.delete(_db.sessionOccurrences)
                    ..where((o) => o.id.equals(existing.id)))
                  .go();
            }
            continue;
          }

          // moved: override'daki saat/süre bilgisi kullanılır (tarih aynı kalır)
          final effectiveStartTime =
              override?.newStartTime ?? template.startTime;
          final effectiveDuration =
              override?.newDurationMin ?? template.durationMin;

          // Unique key: studentId|date|startTime
          final key = '${template.studentId}|$dateStr|$effectiveStartTime';
          final existing = occurrenceMap[key];

          if (existing != null) {
            // Mevcut occurrence varsa ve planned ise temel alanları güncelle
            if (existing.status == 'planned' &&
                (existing.durationMin != effectiveDuration)) {
              await (_db.update(_db.sessionOccurrences)
                    ..where((o) => o.id.equals(existing.id)))
                  .write(
                SessionOccurrencesCompanion(
                  durationMin: Value(effectiveDuration),
                  updatedAt: Value(now),
                ),
              );
            }
          } else {
            // Yeni planned occurrence oluştur
            final id = _uuid.v4();
            await _db.into(_db.sessionOccurrences).insert(
                  SessionOccurrencesCompanion.insert(
                    id: id,
                    studentId: template.studentId,
                    templateId: Value(template.id),
                    date: dateStr,
                    startTime: effectiveStartTime,
                    durationMin: effectiveDuration,
                    status: 'planned',
                    notDoneReasonType: const Value.absent(),
                    notDoneReasonNote: const Value.absent(),
                    paymentId: const Value.absent(),
                    completedAt: const Value.absent(),
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
          }
        }
        } // hasValidWindow && kesişim var
      }

      // EXTRA override'lar için tekil occurrence üretimi
      for (final o in extraOverrides) {
        final template = templateMap[o.templateId];
        if (template == null) continue;

        final dateStr = o.date;
        final effectiveStartTime = o.newStartTime ?? template.startTime;
        final effectiveDuration = o.newDurationMin ?? template.durationMin;

        // Unique key: studentId|date|startTime
        final key = '${template.studentId}|$dateStr|$effectiveStartTime';
        final existing = occurrenceMap[key];

        if (existing != null) {
          if (existing.status == 'planned' &&
              existing.durationMin != effectiveDuration) {
            await (_db.update(_db.sessionOccurrences)
                  ..where((oc) => oc.id.equals(existing.id)))
                .write(
              SessionOccurrencesCompanion(
                durationMin: Value(effectiveDuration),
                updatedAt: Value(now),
              ),
            );
          }
        } else {
          final id = _uuid.v4();
          await _db.into(_db.sessionOccurrences).insert(
                SessionOccurrencesCompanion.insert(
                  id: id,
                  studentId: template.studentId,
                  templateId: Value(template.id),
                  date: dateStr,
                  startTime: effectiveStartTime,
                  durationMin: effectiveDuration,
                  status: 'planned',
                  notDoneReasonType: const Value.absent(),
                  notDoneReasonNote: const Value.absent(),
                  paymentId: const Value.absent(),
                  completedAt: const Value.absent(),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }
      }
    });

    // Tam aralık upsert → ensure önbelleğini güncelle
    if (templateId == null) {
      _ensureCache['${_formatDate(rangeStart)}|${_formatDate(rangeEnd)}'] =
          DateTime.now();
    } else {
      clearOccurrenceEnsureCache();
    }
  }

  /// İptal edilen dersleri stream olarak izler (status='missed')
  /// Students ile JOIN yaparak öğrenci adını da getirir
  Stream<List<CancelledLessonInfo>> watchCancelledLessons() {
    final query = _db.select(_db.sessionOccurrences)
      ..where((o) => o.status.equals('missed'))
      ..orderBy([
        (o) => OrderingTerm(expression: o.date, mode: OrderingMode.desc),
        (o) => OrderingTerm(expression: o.startTime, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((occurrences) async {
      final result = <CancelledLessonInfo>[];

      for (final occurrence in occurrences) {
        // Öğrenci bilgisini direkt occurrence'dan al (artık studentId var)
        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(occurrence.studentId)))
            .getSingleOrNull();

        if (student == null) continue;

        // Tarih ve saat bilgisini parse et
        final dateParts = occurrence.date.split('-');
        final timeParts = occurrence.startTime.split(':');
        final dateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        final parsed = CancelledLessonInfo.parseReasonNote(occurrence.notDoneReasonNote);
        result.add(CancelledLessonInfo(
          occurrenceId: occurrence.id,
          date: dateTime,
          studentId: student.id,
          studentName: student.fullName,
          reasonType: occurrence.notDoneReasonType,
          reasonNote: occurrence.notDoneReasonNote,
          reason: parsed.reason,
          note: parsed.note,
        ));
      }

      return result;
    });
  }

  /// Ertelenen dersleri stream olarak izler (postponed_from_date dolu olanlar)
  /// Eski tarih, yeni tarih ve erteleme sebebi ile listeler
  Stream<List<PostponedLessonInfo>> watchPostponedLessons() {
    final query = _db.select(_db.sessionOccurrences)
      ..where((o) => o.postponedFromDate.isNotNull())
      ..orderBy([
        (o) => OrderingTerm(expression: o.date, mode: OrderingMode.desc),
        (o) => OrderingTerm(expression: o.startTime, mode: OrderingMode.desc),
      ]);

    return query.watch().asyncMap((occurrences) async {
      final result = <PostponedLessonInfo>[];

      for (final occurrence in occurrences) {
        final fromDateStr = occurrence.postponedFromDate;
        if (fromDateStr == null) continue;

        final student = await (_db.select(_db.students)
              ..where((s) => s.id.equals(occurrence.studentId)))
            .getSingleOrNull();
        if (student == null) continue;

        final fromParts = fromDateStr.split('-');
        final toDateParts = occurrence.date.split('-');
        final timeParts = occurrence.startTime.split(':');
        final fromDate = DateTime(
          int.parse(fromParts[0]),
          int.parse(fromParts[1]),
          int.parse(fromParts[2]),
        );
        final toDateTime = DateTime(
          int.parse(toDateParts[0]),
          int.parse(toDateParts[1]),
          int.parse(toDateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        result.add(PostponedLessonInfo(
          occurrenceId: occurrence.id,
          studentId: occurrence.studentId,
          studentName: student.fullName,
          fromDate: fromDate,
          toDateTime: toDateTime,
          reason: occurrence.postponedReason,
        ));
      }

      return result;
    });
  }

  /// Tekil (one-off / extra) ders occurrence'ı oluşturur.
  ///
  /// Kurallar:
  /// - Önce aynı öğrenci + weekday + startTime için mevcut template aranır.
  /// - Yoksa isActive=false olacak şekilde "extra" template oluşturulur.
  /// - Aynı (templateId, date) için SessionOccurrence yoksa 'planned'
  ///   olarak oluşturulur.
  /// - Ayrıca ScheduleOverrides.overrideType='extra' kaydı eklenir.
  Future<String> createOneOffOccurrence({
    required String studentId,
    required DateTime date,
    required TimeOfDay startTime,
    required int durationMin,
  }) async {
    final weekday = date.weekday;
    final dateStr = _formatDate(date);
    final startTimeStr = _formatTime(startTime);
    final now = DateTime.now();

    // Öğrenci için aynı slot'ta bir template var mı?
    var template = await (_db.select(_db.scheduleTemplates)
          ..where(
            (t) =>
                t.studentId.equals(studentId) &
                t.weekday.equals(weekday) &
                t.startTime.equals(startTimeStr),
          ))
        .getSingleOrNull();

    // Yoksa pasif bir template oluştur (sadece bu extra ders için)
    if (template == null) {
      final templateId = _uuid.v4();
      // Extra ders için başlangıç tarihi = ders tarihi
      await _db.into(_db.scheduleTemplates).insert(
            ScheduleTemplatesCompanion.insert(
              id: templateId,
              studentId: studentId,
              weekday: weekday,
              startTime: startTimeStr,
              durationMin: durationMin,
              startDate: dateStr, // Extra ders için başlangıç tarihi = ders tarihi
              endDate: const Value.absent(), // NULL
              isActive: const Value(false),
              createdAt: now,
            ),
          );

      template = ScheduleTemplate(
        id: templateId,
        studentId: studentId,
        weekday: weekday,
        startTime: startTimeStr,
        durationMin: durationMin,
        startDate: dateStr,
        endDate: null,
        isActive: false,
        createdAt: now,
      );
    }

    // Override kaydı: 'extra'
    await insertOverride(
      templateId: template.id,
      date: dateStr,
      overrideType: 'extra',
      newDurationMin: durationMin,
      newStartTime: startTimeStr,
    );

    // SessionOccurrence upsert (studentId ile, templateId ile)
    final occurrenceId = await upsertOccurrenceForTemplateDate(
      templateId: template.id,
      date: dateStr,
      startTime: startTimeStr,
      durationMin: durationMin,
      status: 'planned',
      studentId: studentId,
    );

    return occurrenceId;
  }

  /// Güvenli template devre dışı bırakma (aralık bazında)
  /// 
  /// Kurallar:
  /// - Seçilen aralıkta status='planned' occurrence'ları siler
  /// - status IN ('done','missed') olanları ASLA silmez
  /// - Template'in endDate'ini kısaltır veya isActive=false yapar
  /// 
  /// Returns: SafeDisableResult (silinen sayı ve korunan occurrence'lar)
  Future<SafeDisableResult> safeDisableTemplateInRange({
    required String templateId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final appSettingsRepo = AppSettingsRepository(_db);
    
    return await _db.transaction(() async {
      // A) Varsayılan bitiş tarihini al
      final defaultEnd = await appSettingsRepo.getDefaultScheduleEndDate();
      
      // B) Template'i oku
      final template = await getTemplateById(templateId);
      if (template == null) {
        throw Exception('Template bulunamadı: $templateId');
      }
      
      // Template'in effective end date'i
      final templateStartDateParts = template.startDate.split('-');
      final templateStart = DateTime(
        int.parse(templateStartDateParts[0]),
        int.parse(templateStartDateParts[1]),
        int.parse(templateStartDateParts[2]),
      );
      
      final templateEndEffective = template.endDate != null
          ? (() {
              final templateEndDateParts = template.endDate!.split('-');
              return DateTime(
                int.parse(templateEndDateParts[0]),
                int.parse(templateEndDateParts[1]),
                int.parse(templateEndDateParts[2]),
              );
            })()
          : defaultEnd;
      
      // Tarihleri normalize et
      final fromDateStr = _formatDate(fromDate);
      final toDateStr = _formatDate(toDate);
      
      // C) "Silinmeyecek" dersleri çek (rapor için)
      final keptOccurrences = await (_db.select(_db.sessionOccurrences)
            ..where(
              (o) => o.templateId.equals(templateId) &
                  o.date.isBiggerOrEqualValue(fromDateStr) &
                  o.date.isSmallerOrEqualValue(toDateStr) &
                  (o.status.equals('done') | o.status.equals('missed')),
            ))
          .get();
      
      // D) Planlananları sil
      final plannedOccurrences = await (_db.select(_db.sessionOccurrences)
            ..where(
              (o) => o.templateId.equals(templateId) &
                  o.date.isBiggerOrEqualValue(fromDateStr) &
                  o.date.isSmallerOrEqualValue(toDateStr) &
                  o.status.equals('planned'),
            ))
          .get();
      
      int deletedPlannedCount = 0;
      for (final occ in plannedOccurrences) {
        await (_db.delete(_db.sessionOccurrences)
              ..where((o) => o.id.equals(occ.id)))
            .go();
        deletedPlannedCount++;
        
        // Bildirimi iptal et (templateId varsa)
        if (occ.templateId != null) {
          try {
            await _notificationService.cancelLessonReminder(
              occ.templateId!,
              occ.date,
            );
          } catch (e) {
            // Bildirim iptal hatası kritik değil
            print('Bildirim iptal hatası (göz ardı edildi): $e');
          }
        }
      }
      
      // E) Template'i kısalt / pasifleştir
      // newEnd = min(templateEndEffective, fromDate - 1 gün)
      final newEnd = fromDate.subtract(const Duration(days: 1));
      final finalNewEnd = newEnd.isBefore(templateEndEffective) ? newEnd : templateEndEffective;
      
      // Eğer newEnd < template.startDate => isActive=false, gerekirse hard delete
      if (finalNewEnd.isBefore(templateStart)) {
        await (_db.update(_db.scheduleTemplates)
              ..where((t) => t.id.equals(templateId)))
            .write(const ScheduleTemplatesCompanion(
              isActive: Value(false),
            ));

        // Aralık dışı done/missed yoksa satırı tamamen sil (UNIQUE boşalsın)
        final anyHistory = await (_db.select(_db.sessionOccurrences)
              ..where(
                (o) =>
                    o.templateId.equals(templateId) &
                    (o.status.equals('done') | o.status.equals('missed')),
              ))
            .get();
        if (anyHistory.isEmpty) {
          await (_db.delete(_db.scheduleOverrides)
                ..where((o) => o.templateId.equals(templateId)))
              .go();
          await (_db.delete(_db.scheduleTemplates)
                ..where((t) => t.id.equals(templateId)))
              .go();
        }
      } else {
        // Template'in endDate'ini güncelle
        await (_db.update(_db.scheduleTemplates)
              ..where((t) => t.id.equals(templateId)))
            .write(ScheduleTemplatesCompanion(
              endDate: Value(_formatDate(finalNewEnd)),
              isActive: const Value(true),
            ));
      }
      
      return SafeDisableResult(
        deletedPlannedCount: deletedPlannedCount,
        keptOccurrences: keptOccurrences,
      );
    });
  }
}

/// Güvenli template devre dışı bırakma sonucu
class SafeDisableResult {
  final int deletedPlannedCount;
  final List<SessionOccurrence> keptOccurrences;
  
  SafeDisableResult({
    required this.deletedPlannedCount,
    required this.keptOccurrences,
  });
}

/// İptal edilen ders bilgisi. Sebep ve ek not ayrı alanlarda; gösterimde ikisi ayrı yazılır.
class CancelledLessonInfo {
  static const String _reasonNoteDelimiter = '\n---\n';

  final String occurrenceId;
  final DateTime date;
  final String studentId;
  final String studentName;
  final String? reasonType; // 'student_cancelled' | 'teacher_cancelled' | 'other'
  /// Ham not (geriye uyumluluk). Gösterimde [reason] ve [note] kullanın.
  final String? reasonNote;
  /// Yapılmama sebebi (ayrı gösterilir).
  final String? reason;
  /// Ek not (varsa ayrı satırda gösterilir; yoksa boş).
  final String? note;

  CancelledLessonInfo({
    required this.occurrenceId,
    required this.date,
    required this.studentId,
    required this.studentName,
    this.reasonType,
    this.reasonNote,
    this.reason,
    this.note,
  });

  /// DB'deki notDoneReasonNote'dan sebep ve ek notu ayırır.
  static ({String? reason, String? note}) parseReasonNote(String? raw) {
    if (raw == null || raw.isEmpty) return (reason: null, note: null);
    final idx = raw.indexOf(_reasonNoteDelimiter);
    if (idx < 0) return (reason: raw, note: null);
    return (
      reason: raw.substring(0, idx).trim(),
      note: raw.substring(idx + _reasonNoteDelimiter.length).trim(),
    );
  }
}

/// Ertelenen ders bilgisi (yeni tarihe taşınmış; eski tarih ve sebep saklanır)
class PostponedLessonInfo {
  final String occurrenceId;
  final String studentId;
  final String studentName;
  final DateTime fromDate;
  final DateTime toDateTime;
  final String? reason;

  PostponedLessonInfo({
    required this.occurrenceId,
    required this.studentId,
    required this.studentName,
    required this.fromDate,
    required this.toDateTime,
    this.reason,
  });
}

/// SessionOccurrence ile öğrenci ve template bilgisini birleştiren model
class SessionOccurrenceWithStudent {
  final SessionOccurrence occurrence;
  final Student student;
  final ScheduleTemplate template;

  SessionOccurrenceWithStudent({
    required this.occurrence,
    required this.student,
    required this.template,
  });
}
