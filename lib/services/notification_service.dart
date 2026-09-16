import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Public getter for pending notifications (debug için)
  FlutterLocalNotificationsPlugin get notifications => _notifications;

  /// Bildirim servisini başlatır
  Future<void> init() async {
    if (_isInitialized) return;

    // Timezone'u başlat
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Bildirim kanallarını önceden oluştur (Android için kritik!)
    await _createNotificationChannels();

    _isInitialized = true;
  }

  /// Android bildirim kanallarını oluşturur
  /// Bu kanalların önceden oluşturulması scheduled bildirimler için kritiktir
  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    // Ders Hatırlatmaları kanalı
    const lessonRemindersChannel = AndroidNotificationChannel(
      'lesson_reminders',
      'Ders Hatırlatmaları',
      description: 'Planlanmış dersler için hatırlatma bildirimleri',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Günlük Özet kanalı
    const dailySummaryChannel = AndroidNotificationChannel(
      'daily_summary',
      'Günlük Özet',
      description: 'Günlük ders özeti bildirimleri',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: false,
    );

    // Test Bildirimleri kanalı
    const testChannel = AndroidNotificationChannel(
      'test_channel',
      'Test Bildirimleri',
      description: 'Test bildirimleri için kanal',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Görev hatırlatmaları
    const todoChannel = AndroidNotificationChannel(
      'todo_reminders',
      'Görev Hatırlatmaları',
      description: 'Yapılacaklar listesi için hatırlatma bildirimleri',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Kanalları oluştur
    await androidImplementation.createNotificationChannel(lessonRemindersChannel);
    await androidImplementation.createNotificationChannel(dailySummaryChannel);
    await androidImplementation.createNotificationChannel(testChannel);
    await androidImplementation.createNotificationChannel(todoChannel);

    print('Bildirim kanalları oluşturuldu: lesson_reminders, daily_summary, test_channel');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Bildirime tıklandığında yapılacak işlemler
    // Şimdilik boş bırakıyoruz
  }

  /// Bildirim izni ister
  Future<bool> requestPermissionIfNeeded() async {
    if (!_isInitialized) {
      await init();
    }

    // Android 13+ için izin kontrolü
    final androidInfo = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return androidInfo ?? true;
  }

  /// Exact alarm izninin olup olmadığını kontrol eder (Android 12+)
  /// Eğer izin yoksa inexact kullanılmalı
  Future<bool> canScheduleExactAlarms() async {
    try {
      const platform = MethodChannel('com.example.ozel_ders_takip/alarm');
      final bool canSchedule = await platform.invokeMethod('canScheduleExactAlarms');
      return canSchedule;
    } catch (e) {
      // Platform channel yoksa veya hata varsa varsayılan olarak false döndür
      print('⚠️ Exact alarm izni kontrol edilemedi: $e');
      return false;
    }
  }

  /// Ders bildirimi ID'sini hesaplar
  /// FNV-1a hash kullanarak deterministik ID üretir
  /// ID aralığı: 100000-899999 (daily summary 999999 kalsın)
  int _getLessonNotificationId(String templateId, String date) {
    final input = '$templateId|$date';
    
    // FNV-1a hash algoritması
    int hash = 2166136261; // FNV offset basis
    const int fnvPrime = 16777619;
    
    for (int i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * fnvPrime) & 0xFFFFFFFF; // 32-bit wrap
    }
    
    // 100000-899999 aralığına map et
    final id = 100000 + (hash.abs() % 800000);
    return id;
  }

  /// Ders hatırlatma bildirimi planlar
  Future<void> scheduleLessonReminder({
    required String templateId,
    required DateTime date,
    required TimeOfDay startTime,
    required String studentName,
    required int reminderMinutes,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    // Ders zamanını oluştur
    final lessonDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    // Bildirim zamanı = ders zamanı - reminderMinutes
    final notificationDateTime = lessonDateTime.subtract(
      Duration(minutes: reminderMinutes),
    );

    // Eğer bildirim zamanı geçmişse ama ders zamanı henüz gelmemişse
    // Bildirimi ders zamanından 1 dakika önceye ayarla (minimum hatırlatma)
    final now = DateTime.now();
    DateTime finalNotificationDateTime = notificationDateTime;
    
    if (notificationDateTime.isBefore(now)) {
      // Bildirim zamanı geçmiş ama ders henüz gelmemiş
      if (lessonDateTime.isAfter(now)) {
        // Ders zamanından 1 dakika önce bildirim kur (minimum hatırlatma)
        finalNotificationDateTime = lessonDateTime.subtract(const Duration(minutes: 1));
        print('⚠️ Bildirim zamanı geçmiş, minimum 1 dakika önceye ayarlandı: $finalNotificationDateTime');
      } else {
        // Ders zamanı da geçmiş, bildirim kurma
        print('❌ Hem bildirim hem ders zamanı geçmiş, kurulmadı: Bildirim=$notificationDateTime, Ders=$lessonDateTime');
        return;
      }
    }
    
    print('Bildirim planlanıyor: $finalNotificationDateTime, Öğrenci: $studentName');

    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final notificationId = _getLessonNotificationId(templateId, dateStr);

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'lesson_reminders',
      'Ders Hatırlatmaları',
      channelDescription: 'Planlanmış dersler için hatırlatma bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // TZDateTime oluştur (finalNotificationDateTime kullan)
    final scheduledTZDateTime = tz.TZDateTime.from(finalNotificationDateTime, tz.local);
    
    // Platform channel ile AlarmManager kullan (uygulama kapalıyken çalışır)
    try {
      const platform = MethodChannel('com.example.ozel_ders_takip/alarm');
      final timestamp = scheduledTZDateTime.millisecondsSinceEpoch;
      
      // AlarmManager ile exact alarm kur (bildirim içeriğini de gönder)
      await platform.invokeMethod('scheduleExactAlarm', {
        'timestamp': timestamp,
        'notificationId': notificationId,
        'title': 'Ders Hatırlatması',
        'body': '$studentName ile dersiniz $reminderMinutes dakika sonra başlayacak',
      });
      
      print('✅ AlarmManager ile bildirim planlandı: $scheduledTZDateTime');
    } catch (e) {
      print('⚠️ AlarmManager ile bildirim planlanamadı: $e');
      // Hata durumunda sadece flutter_local_notifications kullan
    }
    
    // Ayrıca flutter_local_notifications ile de planla (fallback)
    // Samsung cihazlarda exact alarm'lar güvenilir değil
    // Bu yüzden her zaman inexact kullanıyoruz
    final scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;
    
    try {
      await _notifications.zonedSchedule(
        notificationId,
        'Ders Hatırlatması',
        '$studentName ile dersiniz $reminderMinutes dakika sonra başlayacak',
        scheduledTZDateTime,
        notificationDetails,
        androidScheduleMode: scheduleMode,
      );
      
      print('✅ flutter_local_notifications ile de planlandı (fallback)');
      
      // Debug: Pending bildirim sayısını kontrol et
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      
      print('✅ Bildirim planlandı:');
      print('   ID: $notificationId');
      print('   TemplateId: $templateId');
      print('   Tarih: $dateStr');
      print('   Ders Zamanı: $lessonDateTime');
      print('   Hesaplanan Bildirim Zamanı: $notificationDateTime');
      print('   Final Bildirim Zamanı: $finalNotificationDateTime');
      print('   TZDateTime: $scheduledTZDateTime');
      print('   Şu An: $now');
      print('   Schedule Mode: inexactAllowWhileIdle');
      print('   Öğrenci: $studentName');
      print('   Toplam Pending Bildirim: ${pendingNotifications.length}');
      
      // Bu bildirimin pending listesinde olup olmadığını kontrol et
      try {
        final thisNotification = pendingNotifications.firstWhere(
          (n) => n.id == notificationId,
        );
        print('   ✅ Bu bildirim pending listesinde: ID=${thisNotification.id}');
      } catch (e) {
        print('   ⚠️ Bu bildirim pending listesinde bulunamadı!');
      }
    } catch (e) {
      print('❌ Bildirim planlanırken hata: $e');
      print('   TemplateId: $templateId');
      print('   NotificationId: $notificationId');
      print('   Scheduled Time: $scheduledTZDateTime');
      rethrow;
    }
  }

  /// Ders hatırlatma bildirimini iptal eder
  Future<void> cancelLessonReminder(String templateId, String date) async {
    final dateStr = date.replaceAll('-', ''); // YYYY-MM-DD -> YYYYMMDD
    final notificationId = _getLessonNotificationId(templateId, dateStr);
    
    // AlarmManager'dan da iptal et
    try {
      const platform = MethodChannel('com.example.ozel_ders_takip/alarm');
      await platform.invokeMethod('cancelAlarm', {
        'notificationId': notificationId,
      });
      print('✅ AlarmManager bildirimi iptal edildi: $notificationId');
    } catch (e) {
      print('⚠️ AlarmManager bildirimi iptal edilemedi: $e');
    }
    
    // flutter_local_notifications'dan da iptal et
    await _notifications.cancel(notificationId);
  }

  /// Günlük özet bildirimi planlar
  /// lessons: Bugünkü dersler listesi {time: 'HH:mm', studentName: '...'}
  Future<void> scheduleDailySummary({
    required TimeOfDay time,
    List<Map<String, dynamic>>? lessons,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    // Önce mevcut günlük özet bildirimini iptal et
    await cancelDailySummary();

    const notificationId = 999999;

    // Bildirim içeriği
    String body;
    if (lessons == null || lessons.isEmpty) {
      body = 'Bugün planlanmış ders yok';
    } else {
      final lessonsText = lessons
          .map((l) => '${l['time']} - ${l['studentName']}')
          .join('\n');
      body = 'Bugünkü derslerin:\n$lessonsText';
    }

    // Android notification details
    const androidDetails = AndroidNotificationDetails(
      'daily_summary',
      'Günlük Özet',
      channelDescription: 'Günlük ders özeti bildirimleri',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    // iOS notification details
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Bugünün saatini oluştur
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Eğer saat geçmişse yarın için planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Ekstra kontrol: Eğer hala geçmişse (çok nadir durumlar için), bir gün daha ekle
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    // Final kontrol: scheduledDate mutlaka gelecekte olmalı
    if (scheduledDate.isBefore(now)) {
      print('❌ Günlük özet bildirimi için geçmiş tarih oluşturuldu, iptal ediliyor');
      print('   Şu An: $now');
      print('   Planlanan: $scheduledDate');
      return; // Bildirim kurma, hata oluşmasın
    }

    print('📅 Günlük özet bildirimi planlanıyor: $scheduledDate');

    // Her gün tekrarlanacak şekilde planla
    await _notifications.zonedSchedule(
      notificationId,
      'Bugünkü Dersler',
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    print('✅ Günlük özet bildirimi planlandı: $scheduledDate');
  }

  /// Günlük özet bildirimini iptal eder
  Future<void> cancelDailySummary() async {
    const notificationId = 999999;
    await _notifications.cancel(notificationId);
  }

  /// Günlük özet bildirimi içeriğini günceller
  /// Bu fonksiyon scheduleDailySummary içinde çağrılacak
  Future<void> updateDailySummaryContent({
    required List<Map<String, dynamic>> lessons, // {time: 'HH:mm', studentName: '...'}
  }) async {
    // Günlük özet bildirimi scheduled notification olarak çalıştığı için
    // içeriği dinamik olarak güncelleyemeyiz. Bunun yerine
    // scheduleDailySummary çağrıldığında güncel ders listesi ile çağrılmalı
  }

  /// Görev bildirimi ID'si (900000-999998 aralığı, 999999 daily summary)
  int _getTodoNotificationId(String todoId) {
    int hash = 2166136261;
    const int fnvPrime = 16777619;
    for (int i = 0; i < todoId.length; i++) {
      hash ^= todoId.codeUnitAt(i);
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return 900000 + (hash.abs() % 99998);
  }

  /// Görev için bildirim planlar
  Future<void> scheduleTodoReminder({
    required String todoId,
    required String title,
    required DateTime notifyAt,
    String? studentName,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    final now = DateTime.now();
    if (!notifyAt.isAfter(now)) return;

    await cancelTodoReminder(todoId);

    final notificationId = _getTodoNotificationId(todoId);
    final body = studentName != null && studentName.trim().isNotEmpty
        ? '$studentName · $title'
        : title;

    const androidDetails = AndroidNotificationDetails(
      'todo_reminders',
      'Görev Hatırlatmaları',
      channelDescription: 'Yapılacaklar listesi için hatırlatma bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTZ = tz.TZDateTime.from(notifyAt, tz.local);

    try {
      const platform = MethodChannel('com.example.ozel_ders_takip/alarm');
      await platform.invokeMethod('scheduleExactAlarm', {
        'timestamp': scheduledTZ.millisecondsSinceEpoch,
        'notificationId': notificationId,
        'title': 'Görev hatırlatması',
        'body': body,
      });
    } catch (_) {
      // Fallback: flutter_local_notifications
    }

    await _notifications.zonedSchedule(
      notificationId,
      'Görev hatırlatması',
      body,
      scheduledTZ,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'todo|$todoId',
    );
  }

  Future<void> cancelTodoReminder(String todoId) async {
    if (!_isInitialized) {
      await init();
    }
    final notificationId = _getTodoNotificationId(todoId);
    try {
      const platform = MethodChannel('com.example.ozel_ders_takip/alarm');
      await platform.invokeMethod('cancelAlarm', {
        'notificationId': notificationId,
      });
    } catch (_) {}
    await _notifications.cancel(notificationId);
  }

  /// Tüm bildirimleri iptal eder
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Yaklaşan ders bildirimlerini kontrol eder ve gerekirse manuel olarak gösterir
  /// Bu fonksiyon periyodik olarak çağrılmalı (örneğin uygulama açıkken)
  /// Samsung cihazlarda scheduled notification'lar güvenilir olmadığı için fallback olarak kullanılır
  Future<void> checkAndTriggerUpcomingNotifications() async {
    if (!_isInitialized) return;

    try {
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      
      // Pending bildirimleri kontrol et
      for (final pending in pendingNotifications) {
        // Sadece ders hatırlatma bildirimlerini kontrol et (ID aralığı: 100000-899999)
        if (pending.id >= 100000 && pending.id < 900000) {
          // Bildirim zamanını kontrol et (pending notification'dan zaman bilgisi alınamaz)
          // Bu yüzden bu fonksiyon sadece yaklaşan dersler için çağrılmalı
          // Gerçek kontrol schedule_repo veya main.dart'ta yapılmalı
        }
      }
    } catch (e) {
      print('⚠️ Yaklaşan bildirimler kontrol edilirken hata: $e');
    }
  }

  /// Belirli bir bildirimi manuel olarak gösterir (fallback için)
  Future<void> triggerNotificationManually({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      await init();
    }

    // Önce pending bildirimi iptal et
    await _notifications.cancel(notificationId);

    // Manuel bildirim göster
    const androidDetails = AndroidNotificationDetails(
      'lesson_reminders',
      'Ders Hatırlatmaları',
      channelDescription: 'Planlanmış dersler için hatırlatma bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notificationId,
      title,
      body,
      notificationDetails,
    );

    print('✅ Manuel bildirim gösterildi: $title');
  }
}
