import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/calendar_providers.dart';
import 'package:ozel_ders_takip/features/schedule/widgets/day_lessons_panel.dart';
import 'package:ozel_ders_takip/shared/models/lesson_status.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:table_calendar/table_calendar.dart';

/// Seçili gün provider'ı (takvim için)
final selectedCalendarDateProvider = StateProvider<DateTime?>((ref) => null);

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    // Takvim için tarih aralığı hesapla (ayın ilk ve son günü)
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final dateRange = DateTimeRange(start: firstDay, end: lastDay);

    // Stream provider - SessionOccurrences değişikliklerini otomatik yakalar
    final lessonsAsync = ref.watch(calendarLessonsProvider(dateRange));
    final selectedDate = ref.watch(selectedCalendarDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: StringsTr.back,
          onPressed: () => context.go(AppRouter.home),
        ),
        title: const Text(StringsTr.calendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            color: AppColors.primary,
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _focusedDay = DateTime(now.year, now.month, now.day);
                _selectedDay = DateTime(now.year, now.month, now.day);
              });
              ref.read(selectedCalendarDateProvider.notifier).state = _selectedDay;
            },
            tooltip: StringsTr.goToToday,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Takvim (beyaz kart içinde)
          Positioned.fill(
            // skipLoadingOnRefresh: false — ay değişince eski yeşil işaretler
            // bir an kalıp kaybolmasın; yüklenirken spinner göster.
            child: lessonsAsync.when(
              skipLoadingOnReload: false,
              skipLoadingOnRefresh: false,
              data: (lessonsMap) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildCalendar(context, lessonsMap),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Hata: $error'),
              ),
            ),
          ),

          // Seçili günün dersleri paneli (üstte overlay olarak)
          if (selectedDate != null)
            _buildDayLessonsPanel(context, ref, selectedDate, lessonsAsync),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    Map<DateTime, List<Lesson>> lessonsMap,
  ) {
    return TableCalendar<Lesson>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: _calendarFormat,
      locale: 'tr_TR',
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Ay',
        CalendarFormat.twoWeeks: '2 Hafta',
        CalendarFormat.week: 'Hafta',
      },
      eventLoader: (day) {
        // DateTime key'lerini normalize et (sadece tarih kısmı)
        final dateOnly = DateTime(day.year, day.month, day.day);
        
        // Önce direkt arama yap
        if (lessonsMap.containsKey(dateOnly)) {
          return lessonsMap[dateOnly] ?? <Lesson>[];
        }
        
        // Eğer bulunamazsa, tüm key'leri kontrol et (timezone farkı olabilir)
        for (final key in lessonsMap.keys) {
          final keyDateOnly = DateTime(key.year, key.month, key.day);
          if (keyDateOnly.year == dateOnly.year &&
              keyDateOnly.month == dateOnly.month &&
              keyDateOnly.day == dateOnly.day) {
            return lessonsMap[key] ?? <Lesson>[];
          }
        }
        
        return <Lesson>[];
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        defaultDecoration: const BoxDecoration(color: Colors.transparent),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        todayDecoration: const BoxDecoration(color: Colors.transparent),
        outsideDecoration: const BoxDecoration(color: Colors.transparent),
        disabledDecoration: const BoxDecoration(color: Colors.transparent),
        markerDecoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(10),
        ),
        canMarkersOverflow: true,
        isTodayHighlighted: false,
        defaultTextStyle: const TextStyle(
          color: AppColors.textPrimary,
        ),
        weekendTextStyle: const TextStyle(
          color: AppColors.textPrimary,
        ),
        outsideTextStyle: TextStyle(
          color: AppColors.muted.withValues(alpha: 0.55),
        ),
        disabledTextStyle: TextStyle(
          color: AppColors.muted.withValues(alpha: 0.4),
        ),
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        formatButtonDecoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBorder, width: 1),
        ),
        formatButtonTextStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
        weekendStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
      ),
      calendarBuilders: CalendarBuilders<Lesson>(
        defaultBuilder: (context, date, events) {
          return _buildDayCell(
            context,
            date,
            _focusedDay,
            lessonsMap,
            isOutside: false,
          );
        },
        todayBuilder: (context, date, events) {
          return _buildDayCell(
            context,
            date,
            _focusedDay,
            lessonsMap,
            forceToday: true,
            isOutside: false,
          );
        },
        selectedBuilder: (context, date, events) {
          return _buildDayCell(
            context,
            date,
            _focusedDay,
            lessonsMap,
            forceSelected: true,
            isOutside: false,
          );
        },
        outsideBuilder: (context, date, events) {
          return _buildDayCell(
            context,
            date,
            _focusedDay,
            lessonsMap,
            isOutside: true,
          );
        },
        markerBuilder: (context, date, events) {
          // Marker'ları custom builder'da gösteriyoruz
          return const SizedBox.shrink();
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        ref.read(selectedCalendarDateProvider.notifier).state = selectedDay;
      },
      onPageChanged: (focusedDay) {
        // Sadece focusedDay güncelle — yeni ay zaten farklı family key ile
        // izlenir. invalidate + eski AsyncData yeşil flaşa yol açıyordu.
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
    );
  }


  /// Gün için dersleri getirir (eventLoader ile aynı kaynak)
  List<Lesson> _getLessonsForDay(DateTime day, Map<DateTime, List<Lesson>> lessonsMap) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    
    // Önce direkt arama yap
    if (lessonsMap.containsKey(dateOnly)) {
      return lessonsMap[dateOnly] ?? <Lesson>[];
    }
    
    // Eğer bulunamazsa, tüm key'leri kontrol et
    for (final key in lessonsMap.keys) {
      final keyDateOnly = DateTime(key.year, key.month, key.day);
      if (keyDateOnly.year == dateOnly.year &&
          keyDateOnly.month == dateOnly.month &&
          keyDateOnly.day == dateOnly.day) {
        return lessonsMap[key] ?? <Lesson>[];
      }
    }
    
    return <Lesson>[];
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
    Map<DateTime, List<Lesson>> lessonsMap, {
    bool forceSelected = false,
    bool forceToday = false,
    bool isOutside = false,
  }) {
    // eventLoader ile aynı kaynaktan dersleri al
    final lessons = _getLessonsForDay(day, lessonsMap);
    final hasLessons = lessons.isNotEmpty;
    
    // Seçili gün kontrolü
    final isSelected = forceSelected || isSameDay(_selectedDay, day);
    // Bugün kontrolü
    final now = DateTime.now();
    final isToday = forceToday || (day.year == now.year && day.month == now.month && day.day == now.day);
    
    // Maksimum 3 event göster, kalanı "+N" olarak göster
    final visibleEvents = lessons.take(3).toList();
    final remainingCount = lessons.length - visibleEvents.length;
    
    // RENK BELİRLEME - Öncelik: Seçili > Ders var > Bugün > Normal
    // Stil: Primary bordo (seçili), success (ders), warning ring (bugün)
    Color backgroundColor;
    Color textColor;
    FontWeight fontWeight;
    Color? borderColor;
    double? borderWidth;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
      borderColor = null;
    } else if (hasLessons) {
      backgroundColor = AppColors.successSoft;
      textColor = AppColors.success;
      fontWeight = FontWeight.w600;
      borderColor = AppColors.success;
      borderWidth = 1.5;
    } else if (isToday) {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textPrimary;
      fontWeight = FontWeight.w600;
      borderColor = AppColors.accent;
      borderWidth = 2.0;
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.textPrimary;
      fontWeight = FontWeight.normal;
      borderColor = null;
    }
    
    // Outside günler için opacity azalt
    if (isOutside && !isSelected && !hasLessons) {
      textColor = textColor.withValues(alpha: 0.45);
    }
    
    final boxDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      border: borderColor != null
          ? Border.all(color: borderColor!, width: borderWidth ?? 1.5)
          : null,
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );

    return Padding(
      padding: const EdgeInsets.all(1),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
              });
              ref.read(selectedCalendarDateProvider.notifier).state = day;
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: boxDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Minimum yer kapla
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gün numarası
                  Text(
                    '${day.day}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: fontWeight,
                      fontSize: 12,
                      color: textColor,
                      height: 1.0, // Line height minimum
                    ),
                  ),

                  // Event noktaları - sadece varsa göster, yatay sıralı
                  // Her dersin status'üne göre renkli nokta göster
                  if (hasLessons)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...visibleEvents.take(3).map((lesson) {
                            final onColoredBg = textColor == Colors.white;
                            final dotColor = onColoredBg
                                ? Colors.white
                                : getLessonStatusColor(
                                    lessonDate: lesson.startDateTime,
                                    status: lesson.status,
                                    today: DateTime.now(),
                                  );
                            return Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                          if (remainingCount > 0 || visibleEvents.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                remainingCount > 0 ? '+$remainingCount' : '+${visibleEvents.length - 3}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 6,
                                  fontWeight: FontWeight.bold,
                                  color: textColor.withValues(alpha: 0.8),
                                  height: 1.0,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayLessonsPanel(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    AsyncValue<Map<DateTime, List<Lesson>>> lessonsAsync,
  ) {
    return lessonsAsync.when(
      skipLoadingOnReload: false,
      skipLoadingOnRefresh: false,
      data: (lessonsMap) {
        // DateTime key'lerini normalize et (sadece tarih kısmı)
        final dateOnly = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
        // Map'teki tüm key'leri kontrol et (referans eşitliği yerine değer eşitliği)
        List<Lesson> lessons = [];
        for (final key in lessonsMap.keys) {
          if (key.year == dateOnly.year &&
              key.month == dateOnly.month &&
              key.day == dateOnly.day) {
            lessons = lessonsMap[key] ?? [];
            break;
          }
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.2, 0.4, 0.9],
          builder: (context, scrollController) {
            return DayLessonsPanel(
              selectedDate: selectedDate,
              lessons: lessons,
              scrollController: scrollController,
              onDismiss: () {
                ref.read(selectedCalendarDateProvider.notifier).state = null;
              },
            );
          },
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }
}
