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

/// Drift ↔ Supabase mirror (oturum varken).
class CloudSyncService {
  CloudSyncService(this._db, this._settings);

  final AppDatabase _db;
  final AppSettingsRepository _settings;

  static const storageBucket = 'edutrack';

  bool get canSync =>
      AppSupabase.isReady && AppSupabase.client.auth.currentSession != null;

  String? get ownerId =>
      AppSupabase.isReady ? AppSupabase.client.auth.currentUser?.id : null;

  SupabaseClient get _client => AppSupabase.client;

  // ── Profil ─────────────────────────────────────────────

  /// Yerel profili buluta yazar; foto varsa Storage'a yükler.
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
      // 002_profile_phone.sql çalıştırılmamış olabilir
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

  /// Buluttan profil çeker, yereli günceller.
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
    // Kolon yoksa veya boşsa yerel telefonu koru (silme).
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

  // ── Öğrenciler ─────────────────────────────────────────

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
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
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

  /// Buluttaki tüm öğrencileri siler (yerel temizleme ile birlikte).
  Future<void> deleteAllRemoteStudents() async {
    if (!canSync) return;
    final uid = ownerId!;
    try {
      await _client.from('students').delete().eq('owner_id', uid);
    } catch (e) {
      debugPrint('Remote students clear failed: $e');
      rethrow;
    }
  }

  /// Tüm yerel öğrencileri buluta upsert eder.
  Future<int> pushAllStudents() async {
    if (!canSync) return 0;
    final list = await (_db.select(_db.students)).get();
    if (list.isEmpty) return 0;
    await _client.from('students').upsert(list.map(studentToRow).toList());
    return list.length;
  }

  /// Buluttan öğrencileri çeker; aynı id yerelde varsa ezer.
  Future<int> pullAllStudents() async {
    if (!canSync) return 0;
    final uid = ownerId!;
    final raw = await _client.from('students').select().eq('owner_id', uid);
    final rows = raw as List<dynamic>;

    var count = 0;
    for (final item in rows) {
      final map = Map<String, dynamic>.from(item as Map);
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
      count++;
    }
    return count;
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}
