/// Uygulama ayarları modeli
class AppSettings {
  /// Günlük özet bildirimi zamanı (HH:mm formatında)
  final String dailySummaryTime;
  
  /// Ders hatırlatma süresi (dakika cinsinden)
  final int lessonReminderMinutes;
  
  const AppSettings({
    this.dailySummaryTime = '20:00',
    this.lessonReminderMinutes = 10,
  });
  
  /// Varsayılan ayarlar
  factory AppSettings.defaultSettings() {
    return const AppSettings(
      dailySummaryTime: '20:00',
      lessonReminderMinutes: 10,
    );
  }
  
  /// Ayarları kopyalama (immutability için)
  AppSettings copyWith({
    String? dailySummaryTime,
    int? lessonReminderMinutes,
  }) {
    return AppSettings(
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      lessonReminderMinutes: lessonReminderMinutes ?? this.lessonReminderMinutes,
    );
  }
  
  /// JSON'dan oluşturma
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dailySummaryTime: json['dailySummaryTime'] as String? ?? '20:00',
      lessonReminderMinutes: json['lessonReminderMinutes'] as int? ?? 10,
    );
  }
  
  /// JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'dailySummaryTime': dailySummaryTime,
      'lessonReminderMinutes': lessonReminderMinutes,
    };
  }
}
