import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/repositories/app_settings_repo.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';
import 'package:ozel_ders_takip/shared/models/teacher_profile.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tam yedekleme özeti.
class CloudBackupResult {
  const CloudBackupResult({
    required this.tables,
    required this.totalRows,
  });

  final Map<String, int> tables;
  final int totalRows;
}

/// Drift ↔ Supabase mirror (oturum varken).
class CloudSyncService {
  CloudSyncService(this._db, this._settings);

  final AppDatabase _db;
  final AppSettingsRepository _settings;

  static const storageBucket = 'edutrack';
  static const _chunkSize = 200;

  /// Yerel app_settings içinden buluta yazılmayan anahtarlar.
  static const _localOnlySettingKeys = {
    'cloud_backup_enabled',
    'cloud_backup_time',
    'cloud_backup_interval_days',
    'cloud_backup_last_at',
    'teacher_full_name',
    'teacher_phone',
    'teacher_photo_path',
    'teacher_branches',
    'teacher_visible_folders',
  };

  bool _busy = false;
  bool get isBusy => _busy;

  bool get canSync =>
      AppSupabase.isReady && AppSupabase.client.auth.currentSession != null;

  String? get ownerId =>
      AppSupabase.isReady ? AppSupabase.client.auth.currentUser?.id : null;

  SupabaseClient get _client => AppSupabase.client;

  String _iso(DateTime? dt) =>
      dt == null ? '' : dt.toUtc().toIso8601String();

  DateTime _parseDt(dynamic v, [DateTime? fallback]) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v)?.toLocal() ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }

  DateTime? _parseDtOrNull(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v)?.toLocal();
    }
    return null;
  }

  // ── Profil ─────────────────────────────────────────────

  Future<void> pushProfile(TeacherProfile profile) async {
    if (!canSync) return;
    final uid = ownerId!;
    String? storagePath;

    if (profile.photoPath != null &&
        profile.photoPath!.isNotEmpty &&
        File(profile.photoPath!).existsSync()) {
      storagePath = await _uploadAvatar(uid, File(profile.photoPath!));
    } else {
      storagePath = null;
      try {
        await _client.storage.from(storageBucket).remove(['$uid/avatar.jpg']);
      } catch (_) {}
    }

    final payload = <String, dynamic>{
      'id': uid,
      'full_name': profile.fullName,
      'phone': formatTurkishPhone(profile.phone),
      'photo_path': storagePath,
      'branches': profile.branches,
      'visible_folders': profile.visibleFolders,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await _client.from('profiles').upsert(payload);
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('phone') || msg.contains('pgrst204')) {
        payload.remove('phone');
        await _client.from('profiles').upsert(payload);
        debugPrint(
          'profiles.phone kolonu yok; telefonsuz kaydedildi. '
          '002_profile_phone.sql çalıştırın. ($e)',
        );
      } else {
        rethrow;
      }
    }
  }

  Future<TeacherProfile?> pullProfile() async {
    if (!canSync) return null;
    final uid = ownerId!;

    final row = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;

    final localBefore = await _settings.getTeacherProfile();
    final branches = _asStringList(row['branches']);
    final visible = _asStringList(row['visible_folders']);
    final remotePhoto = row['photo_path'] as String?;
    final String? phone;
    if (row.containsKey('phone')) {
      final remote = row['phone'] as String?;
      phone = (remote != null && remote.trim().isNotEmpty)
          ? formatTurkishPhone(remote.trim()) ?? remote.trim()
          : localBefore.phone;
    } else {
      phone = localBefore.phone;
    }
    String? localPhoto;

    if (remotePhoto != null && remotePhoto.isNotEmpty) {
      localPhoto = await _downloadAvatar(remotePhoto);
    } else {
      localPhoto = localBefore.photoPath;
    }

    await _settings.saveTeacherProfile(
      fullName: (row['full_name'] as String?) ?? '',
      phone: phone,
      branches: branches,
      visibleFolders: visible,
      photoPath: localPhoto,
      clearPhoto: localPhoto == null || localPhoto.isEmpty,
    );

    return TeacherProfile(
      fullName: (row['full_name'] as String?) ?? '',
      phone: phone,
      photoPath: localPhoto,
      branches: branches,
      visibleFolders: visible,
    );
  }

  Future<String> _uploadAvatar(String uid, File file) async {
    final path = '$uid/avatar.jpg';
    await _client.storage.from(storageBucket).upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return path;
  }

  Future<String?> _downloadAvatar(String storagePath) async {
    try {
      final bytes =
          await _client.storage.from(storageBucket).download(storagePath);
      final appDir = await getApplicationDocumentsDirectory();
      final profileDir = Directory(p.join(appDir.path, 'profile'));
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }
      final target = File(p.join(profileDir.path, 'avatar.jpg'));
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } catch (e) {
      debugPrint('Avatar download failed: $e');
      return null;
    }
  }

  // ── Öğrenciler (anlık) ─────────────────────────────────

  Map<String, dynamic> studentToRow(Student s) {
    final uid = ownerId!;
    return {
      'id': s.id,
      'owner_id': uid,
      'full_name': s.fullName,
      'phone': s.phone,
      'hourly_rate': s.hourlyRate,
      'notes': s.notes,
      'is_active': s.isActive,
      'guardian_full_name': s.guardianFullName,
      'guardian_phone': s.guardianPhone,
      'book_resource': s.bookResource,
      'book_resource_practice': s.bookResourcePractice,
      'grade_level': s.gradeLevel,
      'created_at': s.createdAt.toUtc().toIso8601String(),
    };
  }

  Student studentFromRow(Map<String, dynamic> row) {
    return Student(
      id: row['id'] as String,
      fullName: row['full_name'] as String,
      phone: formatTurkishPhone(row['phone'] as String?),
      hourlyRate: (row['hourly_rate'] as num?)?.toInt() ?? 0,
      notes: row['notes'] as String?,
      isActive: row['is_active'] as bool? ?? true,
      guardianFullName: row['guardian_full_name'] as String?,
      guardianPhone: formatTurkishPhone(row['guardian_phone'] as String?),
      bookResource: row['book_resource'] as String?,
      bookResourcePractice: row['book_resource_practice'] as String?,
      gradeLevel: row['grade_level'] as String?,
      createdAt: _parseDt(row['created_at']),
    );
  }

  Future<void> upsertStudent(Student student) async {
    if (!canSync) return;
    try {
      await _client.from('students').upsert(studentToRow(student));
    } catch (e) {
      debugPrint('Student upsert failed: $e');
    }
  }

  Future<void> deleteStudentRemote(String id) async {
    if (!canSync) return;
    try {
      await _client.from('students').delete().eq('id', id);
    } catch (e) {
      debugPrint('Student remote delete failed: $e');
    }
  }

  Future<void> deleteAllRemoteStudents() async {
    await deleteAllRemoteData();
  }

  /// Öğretmenin buluttaki tüm iş verisini siler.
  Future<void> deleteAllRemoteData() async {
    if (!canSync) return;
    final uid = ownerId!;
    // FK sırası: bağımlılar önce
    const tables = [
      'lesson_payments',
      'attachments',
      'homework_items',
      'teacher_todos',
      'student_topic_progress',
      'lessons',
      'session_occurrences',
      'schedule_overrides',
      'schedule_templates',
      'payments',
      'curriculum_outcomes',
      'curriculum_topics',
      'curriculum_units',
      'curriculum_subjects',
      'app_settings',
      'students',
    ];
    for (final t in tables) {
      try {
        await _client.from(t).delete().eq('owner_id', uid);
      } catch (e) {
        debugPrint('Remote clear $t failed: $e');
      }
    }
  }

  Future<int> pushAllStudents() async {
    final r = await pushAllData();
    return r.tables['students'] ?? 0;
  }

  Future<int> pullAllStudents() async {
    final r = await pullAllData();
    return r.tables['students'] ?? 0;
  }

  // ── Tam yedekleme ──────────────────────────────────────

  /// Tüm yerel iş verisini buluta yazar.
  Future<CloudBackupResult> pushAllData() async {
    if (!canSync) {
      throw StateError('Bulut oturumu yok');
    }
    if (_busy) {
      throw StateError('Yedekleme zaten sürüyor');
    }
    _busy = true;
    final tables = <String, int>{};
    try {
      final uid = ownerId!;
      final profile = await _settings.getTeacherProfile();
      await pushProfile(profile);

      final students = await (_db.select(_db.students)).get();
      tables['students'] = await _upsertChunks(
        'students',
        students.map(studentToRow).toList(),
      );

      final templates = await (_db.select(_db.scheduleTemplates)).get();
      tables['schedule_templates'] = await _upsertChunks(
        'schedule_templates',
        templates
            .map((t) => {
                  'id': t.id,
                  'owner_id': uid,
                  'student_id': t.studentId,
                  'weekday': t.weekday,
                  'start_time': t.startTime,
                  'duration_min': t.durationMin,
                  'start_date': t.startDate,
                  'end_date': t.endDate,
                  'is_active': t.isActive,
                  'created_at': _iso(t.createdAt),
                })
            .toList(),
      );

      final overrides = await (_db.select(_db.scheduleOverrides)).get();
      tables['schedule_overrides'] = await _upsertChunks(
        'schedule_overrides',
        overrides
            .map((o) => {
                  'id': o.id,
                  'owner_id': uid,
                  'template_id': o.templateId,
                  'date': o.date,
                  'override_type': o.overrideType,
                  'new_weekday': o.newWeekday,
                  'new_start_time': o.newStartTime,
                  'new_duration_min': o.newDurationMin,
                  'created_at': _iso(o.createdAt),
                })
            .toList(),
      );

      final payments = await (_db.select(_db.payments)).get();
      tables['payments'] = await _upsertChunks(
        'payments',
        payments
            .map((pmt) => {
                  'id': pmt.id,
                  'owner_id': uid,
                  'student_id': pmt.studentId,
                  'paid_at': _iso(pmt.paidAt),
                  'amount': pmt.amount,
                  'method': pmt.method,
                  'note': pmt.note,
                  'created_at': _iso(pmt.createdAt),
                })
            .toList(),
      );

      final occurrences = await (_db.select(_db.sessionOccurrences)).get();
      tables['session_occurrences'] = await _upsertChunks(
        'session_occurrences',
        occurrences
            .map((o) => {
                  'id': o.id,
                  'owner_id': uid,
                  'student_id': o.studentId,
                  'template_id': o.templateId,
                  'date': o.date,
                  'start_time': o.startTime,
                  'duration_min': o.durationMin,
                  'status': o.status,
                  'not_done_reason_type': o.notDoneReasonType,
                  'not_done_reason_note': o.notDoneReasonNote,
                  'payment_id': o.paymentId,
                  'completed_at':
                      o.completedAt == null ? null : _iso(o.completedAt),
                  'postponed_from_date': o.postponedFromDate,
                  'postponed_reason': o.postponedReason,
                  'created_at': _iso(o.createdAt),
                  'updated_at': _iso(o.updatedAt),
                })
            .toList(),
      );

      final lessons = await (_db.select(_db.lessons)).get();
      tables['lessons'] = await _upsertChunks(
        'lessons',
        lessons
            .map((l) => {
                  'id': l.id,
                  'owner_id': uid,
                  'student_id': l.studentId,
                  'occurrence_id': l.occurrenceId,
                  'start_date_time': _iso(l.startDateTime),
                  'duration_min': l.durationMin,
                  'topic': l.topic,
                  'homework': l.homework,
                  'homework_resource': l.homeworkResource,
                  'fee_expected': l.feeExpected,
                  'fee_paid_amount': l.feePaidAmount,
                  'note': l.note,
                  'lesson_notes': l.lessonNotes,
                  'status': l.status,
                  'status_reason': l.statusReason,
                  'status_reason_source': l.statusReasonSource,
                  'status_changed_at': l.statusChangedAt == null
                      ? null
                      : _iso(l.statusChangedAt),
                  'created_at': _iso(l.createdAt),
                })
            .toList(),
      );

      final homework = await (_db.select(_db.homeworkItems)).get();
      tables['homework_items'] = await _upsertChunks(
        'homework_items',
        homework
            .map((h) => {
                  'id': h.id,
                  'owner_id': uid,
                  'lesson_id': h.lessonId,
                  'student_id': h.studentId,
                  'assigned_at': _iso(h.assignedAt),
                  'resource': h.resource,
                  'topic': h.topic,
                  'detail': h.detail,
                  'status': h.status,
                  'status_note': h.statusNote,
                  'attention_cleared': h.attentionCleared,
                  'due_at': h.dueAt == null ? null : _iso(h.dueAt),
                  'status_changed_at': h.statusChangedAt == null
                      ? null
                      : _iso(h.statusChangedAt),
                  'created_at': _iso(h.createdAt),
                })
            .toList(),
      );

      final topics = await (_db.select(_db.studentTopicProgress)).get();
      tables['student_topic_progress'] = await _upsertChunks(
        'student_topic_progress',
        topics
            .map((t) => {
                  'id': t.id,
                  'owner_id': uid,
                  'student_id': t.studentId,
                  'label': t.label,
                  'created_at': _iso(t.createdAt),
                })
            .toList(),
      );

      final todos = await (_db.select(_db.teacherTodos)).get();
      tables['teacher_todos'] = await _upsertChunks(
        'teacher_todos',
        todos
            .map((t) => {
                  'id': t.id,
                  'owner_id': uid,
                  'title': t.title,
                  'student_id': t.studentId,
                  'student_name': t.studentName,
                  'homework_item_id': t.homeworkItemId,
                  'homework_topic': t.homeworkTopic,
                  'is_done': t.isDone,
                  'notify_at': t.notifyAt == null ? null : _iso(t.notifyAt),
                  'created_at': _iso(t.createdAt),
                })
            .toList(),
      );

      final lessonPayments = await (_db.select(_db.lessonPayments)).get();
      tables['lesson_payments'] = await _upsertChunks(
        'lesson_payments',
        lessonPayments
            .map((lp) => {
                  'id': lp.id,
                  'owner_id': uid,
                  'payment_id': lp.paymentId,
                  'lesson_id': lp.lessonId,
                  'applied_amount': lp.appliedAmount,
                  'created_at': _iso(lp.createdAt),
                })
            .toList(),
      );

      final subjects = await (_db.select(_db.curriculumSubjects)).get();
      tables['curriculum_subjects'] = await _upsertChunks(
        'curriculum_subjects',
        subjects
            .map((s) => {
                  'id': s.id,
                  'owner_id': uid,
                  'name': s.name,
                  'folder': s.folder,
                  'sort_order': s.sortOrder,
                  'created_at': _iso(s.createdAt),
                })
            .toList(),
      );

      final units = await (_db.select(_db.curriculumUnits)).get();
      tables['curriculum_units'] = await _upsertChunks(
        'curriculum_units',
        units
            .map((u) => {
                  'id': u.id,
                  'owner_id': uid,
                  'subject_id': u.subjectId,
                  'name': u.name,
                  'sort_order': u.sortOrder,
                  'created_at': _iso(u.createdAt),
                })
            .toList(),
      );

      final curTopics = await (_db.select(_db.curriculumTopics)).get();
      tables['curriculum_topics'] = await _upsertChunks(
        'curriculum_topics',
        curTopics
            .map((t) => {
                  'id': t.id,
                  'owner_id': uid,
                  'unit_id': t.unitId,
                  'name': t.name,
                  'sort_order': t.sortOrder,
                  'created_at': _iso(t.createdAt),
                })
            .toList(),
      );

      final outcomes = await (_db.select(_db.curriculumOutcomes)).get();
      tables['curriculum_outcomes'] = await _upsertChunks(
        'curriculum_outcomes',
        outcomes
            .map((o) => {
                  'id': o.id,
                  'owner_id': uid,
                  'topic_id': o.topicId,
                  'name': o.name,
                  'sort_order': o.sortOrder,
                  'created_at': _iso(o.createdAt),
                })
            .toList(),
      );

      final attachments = await (_db.select(_db.attachments)).get();
      final attachmentRows = <Map<String, dynamic>>[];
      for (final a in attachments) {
        String? storagePath;
        final file = File(a.filePath);
        if (await file.exists()) {
          try {
            storagePath = await _uploadAttachment(uid, a.id, file);
          } catch (e) {
            debugPrint('Attachment upload ${a.id}: $e');
          }
        }
        attachmentRows.add({
          'id': a.id,
          'owner_id': uid,
          'lesson_id': a.lessonId,
          'file_path': a.filePath,
          'storage_path': storagePath,
          'created_at': _iso(a.createdAt),
        });
      }
      tables['attachments'] =
          await _upsertChunks('attachments', attachmentRows);

      final settings = await (_db.select(_db.appSettings)).get();
      final settingRows = settings
          .where((s) => !_localOnlySettingKeys.contains(s.key))
          .map((s) => {
                'owner_id': uid,
                'key': s.key,
                'value': s.value,
              })
          .toList();
      tables['app_settings'] =
          await _upsertChunks('app_settings', settingRows);

      final total = tables.values.fold<int>(0, (a, b) => a + b);
      await _settings.setCloudBackupLastAt(DateTime.now());
      return CloudBackupResult(tables: tables, totalRows: total);
    } finally {
      _busy = false;
    }
  }

  /// Buluttan tüm iş verisini çeker (yereli ezer / birleştirir).
  Future<CloudBackupResult> pullAllData() async {
    if (!canSync) {
      throw StateError('Bulut oturumu yok');
    }
    if (_busy) {
      throw StateError('Senkron zaten sürüyor');
    }
    _busy = true;
    final tables = <String, int>{};
    try {
      final uid = ownerId!;
      await pullProfile();

      tables['students'] = await _pullStudents(uid);
      tables['schedule_templates'] = await _pullScheduleTemplates(uid);
      tables['schedule_overrides'] = await _pullScheduleOverrides(uid);
      tables['payments'] = await _pullPayments(uid);
      tables['session_occurrences'] = await _pullSessionOccurrences(uid);
      tables['lessons'] = await _pullLessons(uid);
      tables['homework_items'] = await _pullHomework(uid);
      tables['student_topic_progress'] = await _pullTopicProgress(uid);
      tables['teacher_todos'] = await _pullTodos(uid);
      tables['lesson_payments'] = await _pullLessonPayments(uid);
      tables['curriculum_subjects'] = await _pullCurriculumSubjects(uid);
      tables['curriculum_units'] = await _pullCurriculumUnits(uid);
      tables['curriculum_topics'] = await _pullCurriculumTopics(uid);
      tables['curriculum_outcomes'] = await _pullCurriculumOutcomes(uid);
      tables['attachments'] = await _pullAttachments(uid);
      tables['app_settings'] = await _pullAppSettings(uid);

      final total = tables.values.fold<int>(0, (a, b) => a + b);
      return CloudBackupResult(tables: tables, totalRows: total);
    } finally {
      _busy = false;
    }
  }

  Future<int> _upsertChunks(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return 0;
    for (var i = 0; i < rows.length; i += _chunkSize) {
      final end = (i + _chunkSize < rows.length) ? i + _chunkSize : rows.length;
      final chunk = rows.sublist(i, end);
      try {
        await _client.from(table).upsert(chunk);
      } catch (e) {
        // attention_cleared / student_topic_progress migration eksik olabilir
        if (table == 'homework_items') {
          final stripped = chunk.map((r) {
            final copy = Map<String, dynamic>.from(r);
            copy.remove('attention_cleared');
            return copy;
          }).toList();
          try {
            await _client.from(table).upsert(stripped);
            debugPrint(
              'homework_items attention_cleared atlandı — 004 migration çalıştırın',
            );
            continue;
          } catch (_) {}
        }
        if (table == 'student_topic_progress') {
          debugPrint(
            'student_topic_progress yedeklenemedi — 004_full_backup_schema.sql çalıştırın: $e',
          );
          return 0;
        }
        rethrow;
      }
    }
    return rows.length;
  }

  Future<List<Map<String, dynamic>>> _selectOwner(String table, String uid) async {
    final raw = await _client.from(table).select().eq('owner_id', uid);
    return (raw as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<int> _pullStudents(String uid) async {
    final rows = await _selectOwner('students', uid);
    for (final map in rows) {
      final s = studentFromRow(map);
      await _db.into(_db.students).insertOnConflictUpdate(
            StudentsCompanion(
              id: Value(s.id),
              fullName: Value(s.fullName),
              phone: Value(s.phone),
              hourlyRate: Value(s.hourlyRate),
              notes: Value(s.notes),
              isActive: Value(s.isActive),
              guardianFullName: Value(s.guardianFullName),
              guardianPhone: Value(s.guardianPhone),
              bookResource: Value(s.bookResource),
              bookResourcePractice: Value(s.bookResourcePractice),
              gradeLevel: Value(s.gradeLevel),
              createdAt: Value(s.createdAt),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullScheduleTemplates(String uid) async {
    final rows = await _selectOwner('schedule_templates', uid);
    for (final r in rows) {
      await _db.into(_db.scheduleTemplates).insertOnConflictUpdate(
            ScheduleTemplatesCompanion(
              id: Value(r['id'] as String),
              studentId: Value(r['student_id'] as String),
              weekday: Value((r['weekday'] as num).toInt()),
              startTime: Value(r['start_time'] as String),
              durationMin: Value((r['duration_min'] as num).toInt()),
              startDate: Value(r['start_date'] as String),
              endDate: Value(r['end_date'] as String?),
              isActive: Value(r['is_active'] as bool? ?? true),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullScheduleOverrides(String uid) async {
    final rows = await _selectOwner('schedule_overrides', uid);
    for (final r in rows) {
      await _db.into(_db.scheduleOverrides).insertOnConflictUpdate(
            ScheduleOverridesCompanion(
              id: Value(r['id'] as String),
              templateId: Value(r['template_id'] as String),
              date: Value(r['date'] as String),
              overrideType: Value(r['override_type'] as String),
              newWeekday: Value((r['new_weekday'] as num?)?.toInt()),
              newStartTime: Value(r['new_start_time'] as String?),
              newDurationMin: Value((r['new_duration_min'] as num?)?.toInt()),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullPayments(String uid) async {
    final rows = await _selectOwner('payments', uid);
    for (final r in rows) {
      await _db.into(_db.payments).insertOnConflictUpdate(
            PaymentsCompanion(
              id: Value(r['id'] as String),
              studentId: Value(r['student_id'] as String),
              paidAt: Value(_parseDt(r['paid_at'])),
              amount: Value((r['amount'] as num).toInt()),
              method: Value(r['method'] as String),
              note: Value(r['note'] as String?),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullSessionOccurrences(String uid) async {
    final rows = await _selectOwner('session_occurrences', uid);
    for (final r in rows) {
      await _db.into(_db.sessionOccurrences).insertOnConflictUpdate(
            SessionOccurrencesCompanion(
              id: Value(r['id'] as String),
              studentId: Value(r['student_id'] as String),
              templateId: Value(r['template_id'] as String?),
              date: Value(r['date'] as String),
              startTime: Value(r['start_time'] as String),
              durationMin: Value((r['duration_min'] as num).toInt()),
              status: Value(r['status'] as String),
              notDoneReasonType: Value(r['not_done_reason_type'] as String?),
              notDoneReasonNote: Value(r['not_done_reason_note'] as String?),
              paymentId: Value(r['payment_id'] as String?),
              completedAt: Value(_parseDtOrNull(r['completed_at'])),
              postponedFromDate: Value(r['postponed_from_date'] as String?),
              postponedReason: Value(r['postponed_reason'] as String?),
              createdAt: Value(_parseDt(r['created_at'])),
              updatedAt: Value(_parseDt(r['updated_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullLessons(String uid) async {
    final rows = await _selectOwner('lessons', uid);
    for (final r in rows) {
      await _db.into(_db.lessons).insertOnConflictUpdate(
            LessonsCompanion(
              id: Value(r['id'] as String),
              studentId: Value(r['student_id'] as String),
              occurrenceId: Value(r['occurrence_id'] as String?),
              startDateTime: Value(_parseDt(r['start_date_time'])),
              durationMin: Value((r['duration_min'] as num).toInt()),
              topic: Value(r['topic'] as String?),
              homework: Value(r['homework'] as String?),
              homeworkResource: Value(r['homework_resource'] as String?),
              feeExpected: Value((r['fee_expected'] as num?)?.toInt() ?? 0),
              feePaidAmount: Value((r['fee_paid_amount'] as num?)?.toInt() ?? 0),
              note: Value(r['note'] as String?),
              lessonNotes: Value(r['lesson_notes'] as String?),
              status: Value(r['status'] as String?),
              statusReason: Value(r['status_reason'] as String?),
              statusReasonSource: Value(r['status_reason_source'] as String?),
              statusChangedAt: Value(_parseDtOrNull(r['status_changed_at'])),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullHomework(String uid) async {
    List<Map<String, dynamic>> rows;
    try {
      rows = await _selectOwner('homework_items', uid);
    } catch (e) {
      debugPrint('homework pull: $e');
      return 0;
    }
    for (final r in rows) {
      await _db.into(_db.homeworkItems).insertOnConflictUpdate(
            HomeworkItemsCompanion(
              id: Value(r['id'] as String),
              lessonId: Value(r['lesson_id'] as String),
              studentId: Value(r['student_id'] as String),
              assignedAt: Value(_parseDt(r['assigned_at'])),
              resource: Value(r['resource'] as String?),
              topic: Value(r['topic'] as String),
              detail: Value(r['detail'] as String?),
              status: Value(r['status'] as String? ?? 'pending'),
              statusNote: Value(r['status_note'] as String?),
              attentionCleared: Value(r['attention_cleared'] as bool? ?? false),
              dueAt: Value(_parseDtOrNull(r['due_at'])),
              statusChangedAt: Value(_parseDtOrNull(r['status_changed_at'])),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullTopicProgress(String uid) async {
    List<Map<String, dynamic>> rows;
    try {
      rows = await _selectOwner('student_topic_progress', uid);
    } catch (e) {
      debugPrint(
        'student_topic_progress yok — 004_full_backup_schema.sql: $e',
      );
      return 0;
    }
    for (final r in rows) {
      await _db.into(_db.studentTopicProgress).insertOnConflictUpdate(
            StudentTopicProgressCompanion(
              id: Value(r['id'] as String),
              studentId: Value(r['student_id'] as String),
              label: Value(r['label'] as String),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullTodos(String uid) async {
    final rows = await _selectOwner('teacher_todos', uid);
    for (final r in rows) {
      await _db.into(_db.teacherTodos).insertOnConflictUpdate(
            TeacherTodosCompanion(
              id: Value(r['id'] as String),
              title: Value(r['title'] as String),
              studentId: Value(r['student_id'] as String?),
              studentName: Value(r['student_name'] as String?),
              homeworkItemId: Value(r['homework_item_id'] as String?),
              homeworkTopic: Value(r['homework_topic'] as String?),
              isDone: Value(r['is_done'] as bool? ?? false),
              notifyAt: Value(_parseDtOrNull(r['notify_at'])),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullLessonPayments(String uid) async {
    final rows = await _selectOwner('lesson_payments', uid);
    for (final r in rows) {
      await _db.into(_db.lessonPayments).insertOnConflictUpdate(
            LessonPaymentsCompanion(
              id: Value(r['id'] as String),
              paymentId: Value(r['payment_id'] as String),
              lessonId: Value(r['lesson_id'] as String),
              appliedAmount: Value((r['applied_amount'] as num).toInt()),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullCurriculumSubjects(String uid) async {
    final rows = await _selectOwner('curriculum_subjects', uid);
    for (final r in rows) {
      await _db.into(_db.curriculumSubjects).insertOnConflictUpdate(
            CurriculumSubjectsCompanion(
              id: Value(r['id'] as String),
              name: Value(r['name'] as String),
              folder: Value(r['folder'] as String? ?? 'MATEMATİK'),
              sortOrder: Value((r['sort_order'] as num?)?.toInt() ?? 0),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullCurriculumUnits(String uid) async {
    final rows = await _selectOwner('curriculum_units', uid);
    for (final r in rows) {
      await _db.into(_db.curriculumUnits).insertOnConflictUpdate(
            CurriculumUnitsCompanion(
              id: Value(r['id'] as String),
              subjectId: Value(r['subject_id'] as String),
              name: Value(r['name'] as String),
              sortOrder: Value((r['sort_order'] as num?)?.toInt() ?? 0),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullCurriculumTopics(String uid) async {
    final rows = await _selectOwner('curriculum_topics', uid);
    for (final r in rows) {
      await _db.into(_db.curriculumTopics).insertOnConflictUpdate(
            CurriculumTopicsCompanion(
              id: Value(r['id'] as String),
              unitId: Value(r['unit_id'] as String),
              name: Value(r['name'] as String),
              sortOrder: Value((r['sort_order'] as num?)?.toInt() ?? 0),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullCurriculumOutcomes(String uid) async {
    final rows = await _selectOwner('curriculum_outcomes', uid);
    for (final r in rows) {
      await _db.into(_db.curriculumOutcomes).insertOnConflictUpdate(
            CurriculumOutcomesCompanion(
              id: Value(r['id'] as String),
              topicId: Value(r['topic_id'] as String),
              name: Value(r['name'] as String),
              sortOrder: Value((r['sort_order'] as num?)?.toInt() ?? 0),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullAttachments(String uid) async {
    final rows = await _selectOwner('attachments', uid);
    final appDir = await getApplicationDocumentsDirectory();
    final attDir = Directory(p.join(appDir.path, 'attachments'));
    if (!await attDir.exists()) {
      await attDir.create(recursive: true);
    }

    for (final r in rows) {
      final id = r['id'] as String;
      final storagePath = r['storage_path'] as String?;
      var localPath = r['file_path'] as String? ?? '';
      if (storagePath != null && storagePath.isNotEmpty) {
        try {
          final bytes =
              await _client.storage.from(storageBucket).download(storagePath);
          final ext = p.extension(storagePath);
          final target = File(p.join(attDir.path, '$id$ext'));
          await target.writeAsBytes(bytes, flush: true);
          localPath = target.path;
        } catch (e) {
          debugPrint('Attachment download $id: $e');
        }
      }
      await _db.into(_db.attachments).insertOnConflictUpdate(
            AttachmentsCompanion(
              id: Value(id),
              lessonId: Value(r['lesson_id'] as String),
              filePath: Value(localPath),
              createdAt: Value(_parseDt(r['created_at'])),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _pullAppSettings(String uid) async {
    final rows = await _selectOwner('app_settings', uid);
    var count = 0;
    for (final r in rows) {
      final key = r['key'] as String;
      if (_localOnlySettingKeys.contains(key)) continue;
      await _settings.setSetting(key, r['value'] as String);
      count++;
    }
    return count;
  }

  Future<String> _uploadAttachment(String uid, String id, File file) async {
    final ext = p.extension(file.path);
    final path = '$uid/attachments/$id${ext.isEmpty ? '.bin' : ext}';
    final lower = ext.toLowerCase();
    final contentType = lower == '.png'
        ? 'image/png'
        : lower == '.webp'
            ? 'image/webp'
            : 'image/jpeg';
    await _client.storage.from(storageBucket).upload(
          path,
          file,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );
    return path;
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}
