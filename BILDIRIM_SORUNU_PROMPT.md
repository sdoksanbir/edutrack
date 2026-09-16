# Flutter Bildirim Sistemi Sorun Analizi

## SORUN
Flutter uygulamasında offline çalışan bildirim sistemi kuruldu ancak ders hatırlatma bildirimleri gelmiyor. Test bildirimi (anında gönderilen) çalışıyor ama scheduled (zamanlanmış) bildirimler gelmiyor.

## KULLANILAN TEKNOLOJİLER
- Flutter
- flutter_local_notifications: ^19.5.0
- timezone paketi
- Drift ORM (veritabanı)
- Android platform

## MİMARİ YAPISI

### 1. NotificationService (Singleton)
```dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;
  
  // init() - Timezone başlatma ve plugin initialize
  // requestPermissionIfNeeded() - Android 13+ izin kontrolü
  // scheduleLessonReminder() - Ders hatırlatma bildirimi planlama
  // scheduleDailySummary() - Günlük özet bildirimi planlama
}
```

### 2. Bildirim Planlama Stratejisi

**A) Uygulama Başlatıldığında (main.dart):**
- `_scheduleAllUpcomingLessons()` fonksiyonu gelecek 30 gün için tüm derslerin bildirimlerini kuruyor
- Her gün için `getEffectiveSchedule()` çağrılıyor
- Status 'planned' veya null olan dersler için bildirim kuruluyor

**B) Yeni Ders Planı Eklendiğinde:**
- `insertTemplate()` fonksiyonunda `_scheduleRemindersForNewTemplate()` çağrılıyor
- Gelecek 30 gün içinde ilgili weekday'e denk gelen tarihler için bildirim kuruluyor

**C) Ders Planı Güncellendiğinde:**
- `updateTemplate()` fonksiyonunda eski bildirimler iptal ediliyor
- Yeni plana göre bildirimler yeniden kuruluyor

**D) Takvim Ekranı Açıldığında:**
- `watchEffectiveScheduleForDate()` stream'i dinleniyor
- Her stream güncellemesinde `_scheduleRemindersForItems()` çağrılıyor

### 3. Bildirim Planlama Fonksiyonu

```dart
Future<void> scheduleLessonReminder({
  required String templateId,
  required DateTime date,
  required TimeOfDay startTime,
  required String studentName,
  required int reminderMinutes, // 10 dakika
}) async {
  // Ders zamanı oluşturuluyor
  final lessonDateTime = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
  
  // Bildirim zamanı = ders zamanı - 10 dakika
  final notificationDateTime = lessonDateTime.subtract(Duration(minutes: reminderMinutes));
  
  // Zaman geçmişse kurulmuyor
  if (notificationDateTime.isBefore(DateTime.now())) {
    return;
  }
  
  // zonedSchedule ile bildirim planlanıyor
  await _notifications.zonedSchedule(
    notificationId,
    'Ders Hatırlatması',
    '$studentName ile dersiniz $reminderMinutes dakika sonra başlayacak',
    tz.TZDateTime.from(notificationDateTime, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
```

### 4. Android İzinleri (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

### 5. Timezone Ayarları
- Timezone: Europe/Istanbul
- `tz.initializeTimeZones()` ve `tz.setLocalLocation()` init() içinde çağrılıyor

## YAPILAN İYİLEŞTİRMELER

1. ✅ Uygulama başlatıldığında gelecek 30 gün için bildirimler kuruluyor
2. ✅ Yeni ders planı eklendiğinde bildirimler otomatik kuruluyor
3. ✅ Ders planı güncellendiğinde bildirimler yeniden kuruluyor
4. ✅ Override eklendiğinde bildirimler güncelleniyor
5. ✅ Test bildirimi (anında) çalışıyor
6. ✅ Günlük özet bildirimi çalışıyor

## SORUN DETAYLARI

### Çalışan Özellikler:
- ✅ Test bildirimi (anında gönderilen) - `notifications.show()` çalışıyor
- ✅ Günlük özet bildirimi - `scheduleDailySummary()` çalışıyor
- ✅ Bildirim izinleri verilmiş
- ✅ Android ayarlarında bildirimler açık

### Çalışmayan Özellikler:
- ❌ Ders hatırlatma bildirimleri (10 dakika önce) gelmiyor
- ❌ Scheduled bildirimler (`zonedSchedule`) tetiklenmiyor

## POTANSİYEL SORUNLAR

### 1. Android Exact Alarm İzni
- Android 12+ için `SCHEDULE_EXACT_ALARM` izni runtime'da kontrol edilmiyor olabilir
- `AlarmManager.canScheduleExactAlarms()` kontrolü yapılmıyor

### 2. Bildirim Kanalı Sorunları
- Android bildirim kanalları (`lesson_reminders`) doğru oluşturulmamış olabilir
- Kanal importance ayarları yeterli olmayabilir

### 3. Timezone Sorunları
- `tz.TZDateTime.from()` kullanımı yanlış olabilir
- Timezone dönüşümünde hata olabilir

### 4. Bildirim ID Çakışmaları
- `_getLessonNotificationId()` hash fonksiyonu çakışma yaratıyor olabilir
- Aynı ID'ye sahip bildirimler birbirini iptal ediyor olabilir

### 5. Bildirim Zamanı Hesaplama
- `notificationDateTime` hesaplaması yanlış olabilir
- Timezone farkı nedeniyle zaman yanlış hesaplanıyor olabilir

### 6. Android Doze Mode
- `exactAllowWhileIdle` kullanılıyor ama yeterli olmayabilir
- Cihaz uyku modunda bildirimler tetiklenmiyor olabilir

### 7. Bildirim Kurulum Sırası
- Çok fazla bildirim aynı anda kuruluyor (30 gün x ders sayısı)
- Android rate limiting yapıyor olabilir

## KOD ÖRNEKLERİ

### NotificationService.init()
```dart
Future<void> init() async {
  if (_isInitialized) return;
  
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
  
  _isInitialized = true;
}
```

### scheduleLessonReminder() - Tam Kod
```dart
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

  final lessonDateTime = DateTime(
    date.year,
    date.month,
    date.day,
    startTime.hour,
    startTime.minute,
  );

  final notificationDateTime = lessonDateTime.subtract(
    Duration(minutes: reminderMinutes),
  );

  if (notificationDateTime.isBefore(DateTime.now())) {
    print('Bildirim zamanı geçmiş, kurulmadı: $notificationDateTime');
    return;
  }
  
  print('Bildirim planlanıyor: $notificationDateTime, Öğrenci: $studentName');

  final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  final notificationId = _getLessonNotificationId(templateId, dateStr);

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

  try {
    await _notifications.zonedSchedule(
      notificationId,
      'Ders Hatırlatması',
      '$studentName ile dersiniz $reminderMinutes dakika sonra başlayacak',
      tz.TZDateTime.from(notificationDateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    print('Bildirim başarıyla planlandı: ID=$notificationId, Zaman=$notificationDateTime');
  } catch (e) {
    print('Bildirim planlanırken hata: $e');
    rethrow;
  }
}
```

### Bildirim ID Hesaplama
```dart
int _getLessonNotificationId(String templateId, String date) {
  final hashString = '$templateId$date';
  return hashString.hashCode.abs() % 999998; // 999999 günlük özet için
}
```

## SORULAR

1. **Neden test bildirimi çalışıyor ama scheduled bildirimler çalışmıyor?**
   - `notifications.show()` çalışıyor
   - `notifications.zonedSchedule()` çalışmıyor

2. **Android Exact Alarm izni runtime'da kontrol edilmeli mi?**
   - Manifest'te izin var ama runtime kontrolü yok
   - Android 12+ için `AlarmManager.canScheduleExactAlarms()` kontrolü gerekli mi?

3. **Bildirim kanalları doğru oluşturuluyor mu?**
   - `AndroidNotificationDetails` ile kanal oluşturuluyor
   - Ama kanalın gerçekten oluşturulduğundan emin değiliz

4. **Timezone dönüşümü doğru mu?**
   - `tz.TZDateTime.from(notificationDateTime, tz.local)` kullanımı doğru mu?
   - `DateTime`'dan `TZDateTime`'a dönüşüm sorunlu olabilir mi?

5. **Çok fazla bildirim aynı anda kuruluyor mu?**
   - 30 gün x ders sayısı kadar bildirim kuruluyor
   - Android rate limiting yapıyor olabilir mi?

6. **Bildirim zamanı hesaplaması doğru mu?**
   - `DateTime` ile hesaplanan zaman timezone-aware değil
   - `TZDateTime` ile hesaplanmalı mı?

7. **Doze mode ve battery optimization sorunları var mı?**
   - `exactAllowWhileIdle` yeterli mi?
   - Battery optimization'dan muaf tutulmalı mı?

## İSTENEN ÇÖZÜM

1. Scheduled bildirimlerin neden gelmediğini tespit et
2. Mimari yapıda hata varsa belirt
3. Kod düzeltmeleri öner
4. Android-specific sorunlar varsa açıkla
5. Test edilebilir çözümler sun

## EK BİLGİLER

- Flutter SDK: En son stabil sürüm
- Android minSdkVersion: 21
- Android targetSdkVersion: 34
- Test cihazı: Android emulator veya gerçek cihaz
- Bildirim izinleri: Verilmiş
- Test bildirimi: Çalışıyor (anında gönderilen)
- Scheduled bildirimler: Çalışmıyor
