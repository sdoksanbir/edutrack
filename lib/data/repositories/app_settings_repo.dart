import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/shared/models/teacher_profile.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppSettingsRepository {
  final AppDatabase _db;
  final ImagePicker _imagePicker = ImagePicker();

  AppSettingsRepository(this._db);

  static const _kTeacherName = 'teacher_full_name';
  static const _kTeacherPhone = 'teacher_phone';
  static const _kTeacherPhoto = 'teacher_photo_path';
  static const _kTeacherBranches = 'teacher_branches';
  static const _kVisibleFolders = 'teacher_visible_folders';

  /// Genel kullanım için tarih formatı: 'YYYY-MM-DD'
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  List<String> _decodeList(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String _encodeList(List<String> items) => jsonEncode(items);

  Future<TeacherProfile> getTeacherProfile() async {
    final name = await getSetting(_kTeacherName) ?? '';
    final phone = await getSetting(_kTeacherPhone);
    final photo = await getSetting(_kTeacherPhoto);
    final branches = _decodeList(await getSetting(_kTeacherBranches));
    final visible = _decodeList(await getSetting(_kVisibleFolders));
    return TeacherProfile(
      fullName: name,
      phone: (phone == null || phone.isEmpty) ? null : phone,
      photoPath: (photo == null || photo.isEmpty) ? null : photo,
      branches: branches,
      visibleFolders: visible,
    );
  }

  Future<void> saveTeacherProfile({
    required String fullName,
    required List<String> branches,
    required List<String> visibleFolders,
    String? phone,
    String? photoPath,
    bool clearPhoto = false,
  }) async {
    await setSetting(_kTeacherName, formatPersonFullName(fullName));
    await setSetting(
      _kTeacherPhone,
      formatTurkishPhone(phone) ?? '',
    );
    await setSetting(_kTeacherBranches, _encodeList(branches));
    await setSetting(_kVisibleFolders, _encodeList(visibleFolders));
    if (clearPhoto) {
      final old = await getSetting(_kTeacherPhoto);
      if (old != null && old.isNotEmpty) {
        final f = File(old);
        if (await f.exists()) await f.delete();
      }
      await setSetting(_kTeacherPhoto, '');
    } else if (photoPath != null) {
      await setSetting(_kTeacherPhoto, photoPath);
    }
  }

  /// Galeri veya kameradan profil fotoğrafı kaydeder; dosya yolunu döner.
  Future<String?> pickAndSaveTeacherPhoto({required bool fromCamera}) async {
    final image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (image == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory(p.join(appDir.path, 'profile'));
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final targetPath = p.join(profileDir.path, 'avatar.jpg');
    final target = File(targetPath);
    if (await target.exists()) await target.delete();
    await File(image.path).copy(targetPath);

    await setSetting(_kTeacherPhoto, targetPath);
    return targetPath;
  }

  /// Ayar değerini getirir
  Future<String?> getSetting(String key) async {
    final setting = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return setting?.value;
  }

  /// Ayar değerini set eder
  Future<void> setSetting(String key, String value) async {
    final existing = await (_db.select(_db.appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.appSettings)
            ..where((s) => s.key.equals(key)))
          .write(AppSettingsCompanion(value: Value(value)));
    } else {
      await _db.into(_db.appSettings).insert(
            AppSettingsCompanion.insert(key: key, value: value),
          );
    }
  }

  /// Günlük özet saati getirir (HH:mm formatında)
  Future<String?> getDailySummaryTime() async {
    return await getSetting('dailySummaryTime');
  }

  /// Günlük özet saati set eder (HH:mm formatında)
  Future<void> setDailySummaryTime(String time) async {
    await setSetting('dailySummaryTime', time);
  }

  /// Program üretimi için global bitiş tarihini getirir.
  Future<DateTime> getScheduleEndDate() async {
    final raw = await getSetting('schedule_end_date');
    if (raw != null) {
      try {
        final parts = raw.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    final defaultEnd = DateTime(now.year + 1, now.month, now.day);
    await setScheduleEndDate(defaultEnd);
    return defaultEnd;
  }

  /// Varsayılan haftalık ders bitiş tarihini getirir.
  Future<DateTime> getDefaultScheduleEndDate() async {
    final raw = await getSetting('default_schedule_end_date');
    if (raw != null) {
      try {
        final parts = raw.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (_) {}
    }

    final now = DateTime.now();
    final defaultEnd = DateTime(now.year + 1, now.month, now.day);
    await setDefaultScheduleEndDate(defaultEnd);
    return defaultEnd;
  }

  Future<void> setDefaultScheduleEndDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await setSetting('default_schedule_end_date', _formatDate(normalized));
  }

  Future<void> setScheduleEndDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await setSetting('schedule_end_date', _formatDate(normalized));
  }

  // ── Bulut yedekleme ────────────────────────────────────

  /// Varsayılan: açık
  Future<bool> getCloudBackupEnabled() async {
    final v = await getSetting('cloud_backup_enabled');
    if (v == null) return true;
    return v == '1' || v.toLowerCase() == 'true';
  }

  Future<void> setCloudBackupEnabled(bool enabled) async {
    await setSetting('cloud_backup_enabled', enabled ? '1' : '0');
  }

  /// HH:mm — varsayılan 22:00
  Future<String> getCloudBackupTime() async {
    return await getSetting('cloud_backup_time') ?? '22:00';
  }

  Future<void> setCloudBackupTime(String time) async {
    await setSetting('cloud_backup_time', time);
  }

  /// Kaç günde bir (1 = her gün). Varsayılan 1.
  Future<int> getCloudBackupIntervalDays() async {
    final v = await getSetting('cloud_backup_interval_days');
    final n = int.tryParse(v ?? '') ?? 1;
    return n < 1 ? 1 : n;
  }

  Future<void> setCloudBackupIntervalDays(int days) async {
    await setSetting('cloud_backup_interval_days', '${days < 1 ? 1 : days}');
  }

  Future<DateTime?> getCloudBackupLastAt() async {
    final raw = await getSetting('cloud_backup_last_at');
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setCloudBackupLastAt(DateTime at) async {
    await setSetting('cloud_backup_last_at', at.toIso8601String());
  }

  /// Otomatik yedekleme zamanı geldi mi?
  Future<bool> isCloudBackupDue([DateTime? now]) async {
    if (!await getCloudBackupEnabled()) return false;
    final nowLocal = now ?? DateTime.now();
    final timeStr = await getCloudBackupTime();
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 22;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final interval = await getCloudBackupIntervalDays();
    final lastAt = await getCloudBackupLastAt();

    final todaySlot = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
      hour,
      minute,
    );

    if (lastAt == null) {
      return !nowLocal.isBefore(todaySlot);
    }

    final lastDay = DateTime(lastAt.year, lastAt.month, lastAt.day);
    final nextDay = lastDay.add(Duration(days: interval));
    final nextSlot = DateTime(
      nextDay.year,
      nextDay.month,
      nextDay.day,
      hour,
      minute,
    );
    return !nowLocal.isBefore(nextSlot);
  }
}
