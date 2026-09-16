import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/services/notification_service.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  TimeOfDay? _dailySummaryTime;
  DateTime? _defaultScheduleEndDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsRepo = ref.read(appSettingsRepoProvider);

      final timeStr = await settingsRepo.getDailySummaryTime();
      TimeOfDay? dailySummaryTime;
      if (timeStr != null) {
        final parts = timeStr.split(':');
        dailySummaryTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } else {
        dailySummaryTime = const TimeOfDay(hour: 20, minute: 0);
      }

      final defaultEndDate = await settingsRepo.getDefaultScheduleEndDate();

      if (mounted) {
        setState(() {
          _dailySummaryTime = dailySummaryTime;
          _defaultScheduleEndDate = defaultEndDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dailySummaryTime = const TimeOfDay(hour: 20, minute: 0);
          final now = DateTime.now();
          _defaultScheduleEndDate = DateTime(now.year + 1, now.month, now.day);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDailySummaryTime(TimeOfDay time) async {
    try {
      final settingsRepo = ref.read(appSettingsRepoProvider);
      final timeStr =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      await settingsRepo.setDailySummaryTime(timeStr);

      final notificationService = NotificationService();
      final scheduleRepo = ref.read(scheduleRepoProvider);
      final today = DateTime.now();
      final todayLessons = await scheduleRepo.getEffectiveSchedule(today);

      final plannedLessons = todayLessons
          .where((l) => l.status == 'planned' || l.status == null)
          .toList();

      final lessonsList = plannedLessons
          .map((l) => {
                'time': l.startTime,
                'studentName': l.studentName,
              })
          .toList();

      await notificationService.scheduleDailySummary(
        time: time,
        lessons: lessonsList,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Günlük özet saati kaydedildi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  String get _timeLabel {
    if (_dailySummaryTime == null) return 'Ayarlanmamış';
    return '${_dailySummaryTime!.hour.toString().padLeft(2, '0')}:'
        '${_dailySummaryTime!.minute.toString().padLeft(2, '0')}';
  }

  String get _dateLabel {
    if (_defaultScheduleEndDate == null) return 'Ayarlanmamış';
    final d = _defaultScheduleEndDate!;
    return '${d.day.toString().padLeft(2, '0')}.'
        '${d.month.toString().padLeft(2, '0')}.'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              'Ayarlar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bildirim ve ders programı tercihlerinizi yönetin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 20),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.primary,
              iconBg: AppColors.primarySoft,
              title: 'Günlük Özet Saati',
              subtitle: '$_timeLabel · Her gün ders özeti gönderilir',
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime:
                      _dailySummaryTime ?? const TimeOfDay(hour: 20, minute: 0),
                );
                if (picked != null) {
                  setState(() => _dailySummaryTime = picked);
                  await _saveDailySummaryTime(picked);
                }
              },
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.calendar_month_outlined,
              iconColor: AppColors.accent,
              iconBg: AppColors.accentSoft,
              title: 'Varsayılan Bitiş Tarihi',
              subtitle: '$_dateLabel · Haftalık ders bitiş tarihi',
              onTap: () async {
                final now = DateTime.now();
                final initial = _defaultScheduleEndDate ??
                    DateTime(now.year + 1, now.month, now.day);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(now.year),
                  lastDate: DateTime(now.year + 10),
                );
                if (picked != null) {
                  try {
                    final settingsRepo = ref.read(appSettingsRepoProvider);
                    await settingsRepo.setDefaultScheduleEndDate(picked);

                    if (mounted) {
                      setState(() {
                        _defaultScheduleEndDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Varsayılan bitiş tarihi kaydedildi'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.checklist_rtl_outlined,
              iconColor: AppColors.primary,
              iconBg: AppColors.primarySoft,
              title: StringsTr.todosTitle,
              subtitle: 'Ödev takibi ve anlatılacak konular',
              onTap: () => context.push(AppRouter.todos),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.account_tree_outlined,
              iconColor: AppColors.warning,
              iconBg: AppColors.warningSoft,
              title: StringsTr.parameters,
              subtitle: StringsTr.parametersSubtitle,
              onTap: () => context.push(AppRouter.settingsParameters),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline,
              iconColor: AppColors.success,
              iconBg: AppColors.successSoft,
              title: 'Uygulama',
              subtitle: 'Özel Ders Takip · Yerel veri',
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AccentIconBox(
                icon: icon,
                color: iconColor,
                background: iconBg,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
