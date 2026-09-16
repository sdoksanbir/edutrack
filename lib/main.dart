import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/repositories/app_settings_repo.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';
import 'package:ozel_ders_takip/features/auth/cloud_session_bootstrap.dart';
import 'package:ozel_ders_takip/services/notification_service.dart';
import 'package:ozel_ders_takip/services/supabase_client.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

String? get _currentDbUserId =>
    AppSupabase.isReady ? AppSupabase.client.auth.currentUser?.id : null;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Bulut (opsiyonel): --dart-define=SUPABASE_URL / SUPABASE_ANON_KEY
  await AppSupabase.init();
  AppRouter.init();

  // Koyu tema: sistem çubuğu ikonları açık renkte
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF151A22),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Bildirim servisini başlat
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissionIfNeeded();
  
  // Platform channel için notification handler'ı kaydet
  const notificationChannel = MethodChannel('com.example.ozel_ders_takip/notification');
  notificationChannel.setMethodCallHandler((call) async {
    if (call.method == 'showNotification') {
      final notificationId = call.arguments['notificationId'] as int;
      // Bildirimi göster (pending notification'dan bilgi al)
      // Şimdilik basit bir bildirim göster
      await notificationService.notifications.show(
        notificationId,
        'Ders Hatırlatması',
        'Dersiniz yakında başlayacak',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lesson_reminders',
            'Ders Hatırlatmaları',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });
  
  // İlk açılışta varsayılan bitiş tarihini kontrol et ve oluştur
  await _initializeDefaultScheduleEndDate();
  
  // Günlük özet bildirimini planla
  await _initializeDailySummaryNotification();
  
  // Gelecek dersler için bildirimleri planla
  await _scheduleAllUpcomingLessons();
  
  // WorkManager geçici olarak devre dışı (Flutter embedding uyumsuzluğu)
  // Şu an kullanılan çözüm:
  // 1. Scheduled notification'lar (Samsung'da bazen çalışmayabilir)
  // 2. Uygulama açıkken periyodik kontrol (her 1 dakikada bir)
  // 3. Uygulama açıldığında kontrol
  // 
  // Gelecekte WorkManager'ın yeni versiyonu veya alternatif paket kullanılabilir
  print('⚠️ WorkManager geçici olarak devre dışı - scheduled notification\'lar + foreground kontrol kullanılıyor');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Arka planda yaklaşan dersleri kontrol eder ve bildirim gösterir
/// Not: WorkManager geçici olarak devre dışı, bu fonksiyon şu an kullanılmıyor
/// Gelecekte WorkManager veya alternatif bir çözüm ile aktif edilebilir
// ignore: unused_element
Future<void> _checkUpcomingLessonsInBackground() async {
  try {
    final db = AppDatabase(userId: _currentDbUserId);
    final scheduleRepo = ScheduleRepository(db);
    final notificationService = NotificationService();
    await notificationService.init();
    
    final now = DateTime.now();
    final pendingNotifications = await notificationService.notifications.pendingNotificationRequests();
    
    // Bugün ve yarın için dersleri kontrol et
    for (int i = 0; i < 2; i++) {
      final targetDate = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final lessons = await scheduleRepo.getEffectiveSchedule(targetDate);
      
      for (final lesson in lessons) {
        if (lesson.status == 'planned' || lesson.status == null) {
          final timeParts = lesson.startTime.split(':');
          final lessonDateTime = DateTime(
            targetDate.year,
            targetDate.month,
            targetDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
          
          // Bildirim zamanı = ders zamanı - 10 dakika
          final notificationDateTime = lessonDateTime.subtract(const Duration(minutes: 10));
          
          // Eğer bildirim zamanı geçtiyse ama ders henüz gelmemişse bildirim göster
          if (notificationDateTime.isBefore(now) && lessonDateTime.isAfter(now)) {
            // Notification ID'yi hesapla (FNV-1a hash - notification_service ile aynı)
            final dateStr = '${targetDate.year}${targetDate.month.toString().padLeft(2, '0')}${targetDate.day.toString().padLeft(2, '0')}';
            final input = '${lesson.templateId}|$dateStr';
            int hash = 2166136261;
            const int fnvPrime = 16777619;
            for (int j = 0; j < input.length; j++) {
              hash ^= input.codeUnitAt(j);
              hash = (hash * fnvPrime) & 0xFFFFFFFF;
            }
            final notificationId = 100000 + (hash.abs() % 800000);
            
            // Eğer bu bildirim hala pending ise, manuel olarak göster
            final isPending = pendingNotifications.any((n) => n.id == notificationId);
            if (isPending) {
              print('🔄 [Background] Bildirim zamanı geçti, manuel olarak gösteriliyor: ${lesson.studentName} - ${lesson.startTime}');
              await notificationService.triggerNotificationManually(
                notificationId: notificationId,
                title: 'Ders Hatırlatması',
                body: '${lesson.studentName} ile dersiniz yakında başlayacak (${lesson.startTime})',
              );
            }
          }
        }
      }
    }
    
    print('✅ [Background] Yaklaşan dersler kontrol edildi');
  } catch (e) {
    print('❌ [Background] Yaklaşan bildirimler kontrol edilirken hata: $e');
  }
}

/// İlk açılışta varsayılan bitiş tarihini kontrol et ve oluştur
Future<void> _initializeDefaultScheduleEndDate() async {
  try {
    final db = AppDatabase(userId: _currentDbUserId);
    final settingsRepo = AppSettingsRepository(db);
    
    // getDefaultScheduleEndDate() zaten yoksa otomatik oluşturuyor (1 yıl sonrası)
    await settingsRepo.getDefaultScheduleEndDate();
    print('✅ Varsayılan bitiş tarihi kontrol edildi');
  } catch (e) {
    print('⚠️ Varsayılan bitiş tarihi kontrol edilirken hata: $e');
  }
}

Future<void> _initializeDailySummaryNotification() async {
  try {
    // Database ve repository'leri oluştur
    final db = AppDatabase(userId: _currentDbUserId);
    final settingsRepo = AppSettingsRepository(db);
    final scheduleRepo = ScheduleRepository(db);
    
    // Günlük özet saati al
    final timeStr = await settingsRepo.getDailySummaryTime();
    if (timeStr != null) {
      final parts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      
      // Bugünkü dersleri al
      final today = DateTime.now();
      final todayLessons = await scheduleRepo.getEffectiveSchedule(today);
      
      // Sadece planned olanları filtrele
      final plannedLessons = todayLessons
          .where((l) => l.status == 'planned' || l.status == null)
          .toList();
      
      // Bildirim içeriği için ders listesi
      final lessonsList = plannedLessons.map((l) => {
        'time': l.startTime,
        'studentName': l.studentName,
      }).toList();
      
      // Günlük özet bildirimini planla
      final notificationService = NotificationService();
      try {
        await notificationService.scheduleDailySummary(
          time: time,
          lessons: lessonsList,
        );
        print('✅ Günlük özet bildirimi başarıyla planlandı');
      } catch (e) {
        print('❌ Günlük özet bildirimi planlanırken hata: $e');
        // Hata durumunda sessizce devam et, uygulama çalışmaya devam etsin
      }
    }
  } catch (e) {
    // Hata durumunda sessizce devam et
    print('⚠️ Günlük özet bildirimi başlatılamadı: $e');
  }
}

/// Gelecek 7 gün için tüm derslerin bildirimlerini planlar
Future<void> _scheduleAllUpcomingLessons() async {
  try {
    final db = AppDatabase(userId: _currentDbUserId);
    final scheduleRepo = ScheduleRepository(db);
    final notificationService = NotificationService();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Önce mevcut ders bildirimlerini iptal et (yeniden kurmak için)
    // Tüm pending bildirimleri al ve ders bildirimlerini iptal et
    final pendingNotifications = await notificationService.notifications.pendingNotificationRequests();
    for (final notification in pendingNotifications) {
      // 100000-899999 aralığındaki ID'ler ders bildirimleri
      if (notification.id >= 100000 && notification.id < 900000) {
        await notificationService.notifications.cancel(notification.id);
      }
    }
    
    print('Mevcut ders bildirimleri iptal edildi. Yeni bildirimler kuruluyor...');
    
    // Gelecek 7 gün için bildirimleri kur
    int scheduledCount = 0;
    for (int i = 0; i < 7; i++) {
      final targetDate = today.add(Duration(days: i));
      final lessons = await scheduleRepo.getEffectiveSchedule(targetDate);
      
      // Sadece planned veya null status olanlar için bildirim kur
      for (final lesson in lessons) {
        if (lesson.status == 'planned' || lesson.status == null) {
          final timeParts = lesson.startTime.split(':');
          final startTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
          
          await notificationService.scheduleLessonReminder(
            templateId: lesson.templateId,
            date: targetDate,
            startTime: startTime,
            studentName: lesson.studentName,
            reminderMinutes: 10,
          );
          scheduledCount++;
        }
      }
    }
    
    // Final pending count
    final finalPending = await notificationService.notifications.pendingNotificationRequests();
    print('✅ Gelecek 7 gün için $scheduledCount bildirim planlandı');
    print('   Toplam pending bildirim: ${finalPending.length}');
  } catch (e) {
    print('❌ Bildirimler planlanırken hata: $e');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  Timer? _notificationCheckTimer;
  Timer? _backupCheckTimer;
  final _notificationService = NotificationService();
  bool _notificationCheckRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startNotificationCheck();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runScheduledBackupIfDue();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationCheckTimer?.cancel();
    _backupCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkUpcomingNotifications();
      _startNotificationCheck();
      _runScheduledBackupIfDue();
    } else if (state == AppLifecycleState.paused) {
      _notificationCheckTimer?.cancel();
      _backupCheckTimer?.cancel();
    }
  }

  void _startNotificationCheck() {
    _notificationCheckTimer?.cancel();
    _backupCheckTimer?.cancel();
    // Bildirim: 5 dakikada bir (paylaşılan DB)
    _notificationCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkUpcomingNotifications();
    });
    // Yedek: 15 dakikada bir due kontrolü (ucuz; push sadece due ise)
    _backupCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _runScheduledBackupIfDue();
    });
  }

  Future<void> _runScheduledBackupIfDue() async {
    try {
      await ref.read(cloudBackupSchedulerProvider).runIfDue();
    } catch (e) {
      debugPrint('Yedekleme zamanlayıcı: $e');
    }
  }

  Future<void> _checkUpcomingNotifications() async {
    if (_notificationCheckRunning) return;
    _notificationCheckRunning = true;
    try {
      final scheduleRepo = ref.read(scheduleRepoProvider);
      final now = DateTime.now();

      final pendingNotifications =
          await _notificationService.notifications.pendingNotificationRequests();

      for (int i = 0; i < 2; i++) {
        final targetDate =
            DateTime(now.year, now.month, now.day).add(Duration(days: i));
        final lessons = await scheduleRepo.getEffectiveSchedule(targetDate);

        for (final lesson in lessons) {
          if (lesson.status == 'planned' || lesson.status == null) {
            final timeParts = lesson.startTime.split(':');
            final lessonDateTime = DateTime(
              targetDate.year,
              targetDate.month,
              targetDate.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );

            final notificationDateTime =
                lessonDateTime.subtract(const Duration(minutes: 10));

            if (notificationDateTime.isBefore(now) &&
                lessonDateTime.isAfter(now)) {
              final dateStr =
                  '${targetDate.year}${targetDate.month.toString().padLeft(2, '0')}${targetDate.day.toString().padLeft(2, '0')}';
              final input = '${lesson.templateId}|$dateStr';
              int hash = 2166136261;
              const int fnvPrime = 16777619;
              for (int j = 0; j < input.length; j++) {
                hash ^= input.codeUnitAt(j);
                hash = (hash * fnvPrime) & 0xFFFFFFFF;
              }
              final notificationId = 100000 + (hash.abs() % 800000);

              final isPending =
                  pendingNotifications.any((n) => n.id == notificationId);
              if (isPending) {
                await _notificationService.triggerNotificationManually(
                  notificationId: notificationId,
                  title: 'Ders Hatırlatması',
                  body:
                      '${lesson.studentName} ile dersiniz yakında başlayacak (${lesson.startTime})',
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Yaklaşan bildirimler kontrol hatası: $e');
    } finally {
      _notificationCheckRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(cloudSessionBootstrapProvider);
    final appTheme = AppTheme.dark;
    return MaterialApp.router(
      title: 'Özel Ders Takip',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: appTheme,
      darkTheme: appTheme,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: Color(0xFF151A22),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Theme(
            data: appTheme,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}

