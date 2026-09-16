import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/schedule/schedule_screen.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/models/daily_lesson.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

class _TodayLessonRow {
  final Lesson lesson;
  final String studentName;

  const _TodayLessonRow({
    required this.lesson,
    required this.studentName,
  });
}

/// Takvim ile aynı kaynak: SessionOccurrences (şablon penceresi + prune sonrası).
final todayLessonsProvider =
    FutureProvider.autoDispose<List<_TodayLessonRow>>((ref) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final scheduleRepo = ref.watch(scheduleRepoProvider);
  final lessonsRepo = ref.watch(lessonsRepoProvider);
  final studentsRepo = ref.watch(studentsRepoProvider);

  await scheduleRepo.prunePlannedOutsideActiveTemplateWindows();
  await scheduleRepo.upsertOccurrencesForRange(
    startDate: today,
    endDate: today,
  );

  final byDate = await lessonsRepo
      .watchLessonsByDateRange(startDate: today, endDate: today)
      .first;

  final lessons = <Lesson>[];
  for (final entry in byDate.entries) {
    final key = DateTime(entry.key.year, entry.key.month, entry.key.day);
    if (key.year == today.year &&
        key.month == today.month &&
        key.day == today.day) {
      lessons.addAll(entry.value);
    }
  }

  lessons.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

  final students = await studentsRepo.getAllStudents();
  final names = {for (final s in students) s.id: s.fullName};

  return lessons
      .map(
        (lesson) => _TodayLessonRow(
          lesson: lesson,
          studentName: names[lesson.studentId] ?? 'Öğrenci',
        ),
      )
      .toList();
});

final _activeStudentCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(studentsRepoProvider)
      .watchAllStudents(includeInactive: false)
      .map((list) => list.length);
});

final _openTodosCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(todosRepoProvider).watchOpenCount();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLabel =
        DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(DateTime.now());
    final todayLessons =
        ref.watch(todayLessonsProvider).asData?.value ?? [];
    final plannedToday = todayLessons
        .where((row) =>
            row.lesson.status == null ||
            row.lesson.status == 'planned')
        .length;
    final homeworkAlerts = ref.watch(homeworkAlertCountProvider);
    final studentCount =
        ref.watch(_activeStudentCountProvider).asData?.value ?? 0;
    final openTodos = ref.watch(_openTodosCountProvider).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Text(
              _greeting(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              todayLabel,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            _SummaryRow(
              items: [
                _SummaryData(
                  label: 'Bugün',
                  value: '$plannedToday',
                  subtitle: 'ders',
                  color: AppColors.primary,
                  onTap: () => context.go(AppRouter.schedule),
                ),
                _SummaryData(
                  label: 'Ödev',
                  value: '$homeworkAlerts',
                  subtitle: 'uyarı',
                  color: AppColors.warning,
                  onTap: () => context.go(AppRouter.homeworks),
                ),
                _SummaryData(
                  label: 'Görev',
                  value: '$openTodos',
                  subtitle: 'açık',
                  color: AppColors.accent,
                  onTap: () => context.push(AppRouter.todos),
                ),
                _SummaryData(
                  label: 'Öğrenci',
                  value: '$studentCount',
                  subtitle: 'aktif',
                  color: AppColors.success,
                  onTap: () => context.push(AppRouter.students),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              StringsTr.homeShortcuts,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.55,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ShortcutTile(
                  icon: Icons.people_outline,
                  label: 'Öğrenciler',
                  subtitle: 'Kayıt ve bilgiler',
                  color: AppColors.primary,
                  onTap: () => context.push(AppRouter.students),
                ),
                _ShortcutTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Takvim',
                  subtitle: 'Günlük program',
                  color: AppColors.accent,
                  onTap: () => context.go(AppRouter.schedule),
                ),
                _ShortcutTile(
                  icon: Icons.book_outlined,
                  label: 'Dersler',
                  subtitle: 'Yapılan dersler',
                  color: const Color(0xFF6EC6FF),
                  onTap: () => context.go(AppRouter.lessons),
                ),
                _ShortcutTile(
                  icon: Icons.assignment_outlined,
                  label: 'Ödevler',
                  subtitle: homeworkAlerts > 0
                      ? '$homeworkAlerts takip gereken'
                      : 'Ödev takibi',
                  color: AppColors.warning,
                  badge: homeworkAlerts > 0 ? homeworkAlerts : null,
                  onTap: () => context.go(AppRouter.homeworks),
                ),
                _ShortcutTile(
                  icon: Icons.payment_outlined,
                  label: 'Ödemeler',
                  subtitle: 'Tahsilat durumu',
                  color: AppColors.success,
                  onTap: () => context.go(AppRouter.payments),
                ),
                _ShortcutTile(
                  icon: Icons.checklist_rtl_outlined,
                  label: 'Yapılacaklar',
                  subtitle:
                      openTodos > 0 ? '$openTodos açık görev' : 'Görev listesi',
                  color: const Color(0xFFB07CFF),
                  badge: openTodos > 0 ? openTodos : null,
                  onTap: () => context.push(AppRouter.todos),
                ),
                _ShortcutTile(
                  icon: Icons.account_tree_outlined,
                  label: 'Parametreler',
                  subtitle: 'Müfredat konuları',
                  color: const Color(0xFF4DB6A0),
                  onTap: () => context.push(AppRouter.settingsParameters),
                ),
                _ShortcutTile(
                  icon: Icons.settings_outlined,
                  label: 'Ayarlar',
                  subtitle: 'Bildirim ve tercih',
                  color: AppColors.muted,
                  onTap: () => context.push(AppRouter.settings),
                ),
              ],
            ),
            if (todayLessons.isNotEmpty) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      StringsTr.homeTodayLessons,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRouter.schedule),
                    child: const Text('Takvime git'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...todayLessons.take(5).map(
                    (row) => _TodayLessonTile(
                      lesson: row.lesson,
                      studentName: row.studentName,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SummaryData({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _SummaryRow extends StatelessWidget {
  final List<_SummaryData> items;

  const _SummaryRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _SummaryCard(data: items[i])),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: data.color.withValues(alpha: 0.28)),
          ),
          child: Column(
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: data.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                data.subtitle,
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badge',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayLessonTile extends ConsumerWidget {
  final Lesson lesson;
  final String studentName;

  const _TodayLessonTile({
    required this.lesson,
    required this.studentName,
  });

  Future<void> _openLesson(BuildContext context, WidgetRef ref) async {
    final day = DateTime(
      lesson.startDateTime.year,
      lesson.startDateTime.month,
      lesson.startDateTime.day,
    );
    ref.read(selectedCalendarDateProvider.notifier).state = day;

    final status = lesson.status;
    final isDone = status == 'done';

    if (isDone) {
      Lesson? saved = lesson.id.startsWith('occurrence_')
          ? null
          : lesson;
      if (saved == null && lesson.occurrenceId != null) {
        saved = await ref
            .read(lessonsRepoProvider)
            .getLessonByOccurrenceId(lesson.occurrenceId!);
      }
      if (saved != null &&
          !saved.id.startsWith('occurrence_') &&
          context.mounted) {
        context.push('${AppRouter.lessons}/${saved.id}', extra: saved);
        return;
      }
    }

    if (!context.mounted) return;
    context.push(
      '${AppRouter.lessons}/create',
      extra: DailyLesson(
        studentId: lesson.studentId,
        studentName: studentName,
        startDateTime: lesson.startDateTime,
        durationMin: lesson.durationMin,
        occurrenceId: lesson.occurrenceId,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = lesson.status ?? 'planned';
    final statusColor = switch (status) {
      'done' => AppColors.success,
      'missed' || 'not_done' => AppColors.danger,
      'postponed' => AppColors.warning,
      _ => AppColors.primary,
    };
    final timeLabel = DateFormat('HH:mm').format(lesson.startDateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => _openLesson(context, ref),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.15),
          child: Text(
            timeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ),
        title: Text(
          studentName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${lesson.durationMin} dk',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
