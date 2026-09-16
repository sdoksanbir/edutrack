import 'package:flutter/foundation.dart';
import 'package:ozel_ders_takip/data/repositories/app_settings_repo.dart';
import 'package:ozel_ders_takip/services/cloud_sync_service.dart';

/// Uygulama açıkken / açılışta zamanı gelmiş tam yedeklemeyi çalıştırır.
class CloudBackupScheduler {
  CloudBackupScheduler(this._cloud, this._settings);

  final CloudSyncService _cloud;
  final AppSettingsRepository _settings;

  DateTime? _lastAttempt;

  /// Due ise pushAllData çalıştırır. Başarıda true.
  Future<bool> runIfDue({bool force = false}) async {
    if (!_cloud.canSync || _cloud.isBusy) return false;

    if (!force) {
      final due = await _settings.isCloudBackupDue();
      if (!due) return false;
      // Aynı dakikada tekrar deneme
      final now = DateTime.now();
      if (_lastAttempt != null &&
          now.difference(_lastAttempt!).inMinutes < 5) {
        return false;
      }
    }

    _lastAttempt = DateTime.now();
    try {
      final result = await _cloud.pushAllData();
      debugPrint(
        '☁️ Otomatik yedekleme: ${result.totalRows} satır '
        '(${result.tables})',
      );
      return true;
    } catch (e) {
      debugPrint('☁️ Otomatik yedekleme hatası: $e');
      return false;
    }
  }
}
