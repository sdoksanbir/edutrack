import 'package:drift/drift.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';

class AppSettingsRepository {
  final AppDatabase _db;

  AppSettingsRepository(this._db);

  /// Genel kullanım için tarih formatı: 'YYYY-MM-DD'
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
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
      // Update
      await (_db.update(_db.appSettings)
            ..where((s) => s.key.equals(key)))
          .write(AppSettingsCompanion(value: Value(value)));
    } else {
      // Insert
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
  ///
  /// - AppSettings.key = 'schedule_end_date', value = 'YYYY-MM-DD'
  /// - Kayıt yoksa, bugünden 1 yıl sonrasını varsayılan olarak üretir
  ///   ve veritabanına yazar.
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
      } catch (_) {
        // Aşağıda varsayılan değere düşülür.
      }
    }

    // Varsayılan: bugünden 1 yıl sonrası
    final now = DateTime.now();
    final defaultEnd = DateTime(now.year + 1, now.month, now.day);
    await setScheduleEndDate(defaultEnd);
    return defaultEnd;
  }

  /// Varsayılan haftalık ders bitiş tarihini getirir.
  ///
  /// - AppSettings.key = 'default_schedule_end_date', value = 'YYYY-MM-DD'
  /// - Kayıt yoksa, bugünden 1 yıl sonrasını varsayılan olarak üretir
  ///   ve veritabanına yazar.
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
      } catch (_) {
        // Aşağıda varsayılan değere düşülür.
      }
    }

    // Varsayılan: bugünden 1 yıl sonrası
    final now = DateTime.now();
    final defaultEnd = DateTime(now.year + 1, now.month, now.day);
    await setDefaultScheduleEndDate(defaultEnd);
    return defaultEnd;
  }

  /// Varsayılan haftalık ders bitiş tarihini set eder.
  ///
  /// date sadece tarih kısmı ile kaydedilir (YYYY-MM-DD).
  Future<void> setDefaultScheduleEndDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await setSetting('default_schedule_end_date', _formatDate(normalized));
  }

  /// Program üretimi için global bitiş tarihini set eder.
  ///
  /// date sadece tarih kısmı ile kaydedilir (YYYY-MM-DD).
  Future<void> setScheduleEndDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    await setSetting('schedule_end_date', _formatDate(normalized));
  }
}
