import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/widgets/detail_info_panel.dart';

final _dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');
final _timeFormat = DateFormat('HH:mm', 'tr_TR');
final _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');

class StudentLessonsScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;

  const StudentLessonsScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<StudentLessonsScreen> createState() => _StudentLessonsScreenState();
}

class _StudentLessonsScreenState extends ConsumerState<StudentLessonsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: StringsTr.back,
        ),
        title: Text(widget.studentName),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: StringsTr.tabDoneLessons),
            Tab(text: StringsTr.tabCancelledLessons),
            Tab(text: StringsTr.tabPostponedLessons),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LessonsList(studentId: widget.studentId, status: 'done'),
          _CancelledLessonsTab(studentId: widget.studentId),
          _PostponedLessonsTab(studentId: widget.studentId),
        ],
      ),
    );
  }
}

class _LessonsList extends ConsumerWidget {
  final String studentId;
  final String status;

  const _LessonsList({
    required this.studentId,
    required this.status,
  });

  Color _badgeColor() {
    switch (status) {
      case 'done':
        return AppColors.success;
      case 'missed':
        return AppColors.danger;
      case 'postponed':
        return AppColors.warning;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsRepo = ref.watch(lessonsRepoProvider);
    // Yapılmayan sekmesi: Lessons + SessionOccurrences (takvimden işaretlenen yapılmadılar) birleşik
    final stream = status == 'missed'
        ? lessonsRepo.watchLessonsByStudentIncludingMissedOccurrences(studentId)
        : lessonsRepo.watchLessonsByStudent(studentId, status: status);

    return StreamBuilder<List<Lesson>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${StringsTr.errorPrefix}${snapshot.error}'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Yenile'),
                ),
              ],
            ),
          );
        }
        final lessons = snapshot.data ?? [];
        if (lessons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'done' ? Icons.check_circle_outline : status == 'postponed' ? Icons.schedule : Icons.cancel_outlined,
                  size: 64,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  StringsTr.noLessonsInCategory,
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final badgeColor = _badgeColor();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final isDone = lesson.status == 'done';
            String? reasonShort;
            String? sourceText;
            if (!isDone) {
              if (lesson.statusReason != null && lesson.statusReason!.isNotEmpty) {
                reasonShort = lesson.statusReason!.length > 50
                    ? '${lesson.statusReason!.substring(0, 50)}...'
                    : lesson.statusReason;
              }
              if (lesson.statusReasonSource != null) {
                sourceText = lesson.statusReasonSource == 'TEACHER'
                    ? StringsTr.teacherSource
                    : StringsTr.studentSource;
              }
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.border, width: 1),
              ),
              child: InkWell(
                onTap: () {
                  if (isDone) {
                    context.push(
                      '${AppRouter.lessons}/${lesson.id}',
                      extra: lesson,
                    );
                  } else {
                    _showReasonSourceDialog(context, lesson);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_dateFormat.format(lesson.startDateTime)} ${_timeFormat.format(lesson.startDateTime)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (reasonShort != null || sourceText != null) ...[
                                  const SizedBox(height: 4),
                                  if (sourceText != null)
                                    Text(
                                      '${StringsTr.sourceLabel}: $sourceText',
                                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                                    ),
                                  if (reasonShort != null)
                                    Text(
                                      reasonShort,
                                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: badgeColor.withAlpha(100)),
                            ),
                            child: Text(
                              status == 'done'
                                  ? StringsTr.done
                                  : status == 'postponed'
                                      ? StringsTr.postponed
                                      : StringsTr.missed,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// İptal edilen dersler sekmesi (öğrenciye göre filtrelenir, ödemeler ekranıyla aynı kart tasarımı)
class _CancelledLessonsTab extends ConsumerWidget {
  final String studentId;

  const _CancelledLessonsTab({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelledAsync = ref.watch(cancelledLessonsProvider);
    return cancelledAsync.when(
      data: (list) {
        final forStudent = list.where((c) => c.studentId == studentId).toList();
        if (forStudent.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 64, color: AppColors.muted),
                const SizedBox(height: 16),
                Text(
                  StringsTr.noLessonsInCategory,
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forStudent.length,
          itemBuilder: (context, index) {
            final cancelled = forStudent[index];
            return _CancelledLessonCard(
              cancelled: cancelled,
              onTap: () => _showCancelledLessonDetailDialog(context, cancelled),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('${StringsTr.errorPrefix}$error')),
    );
  }
}

/// Ertelenen dersler sekmesi (öğrenciye göre filtrelenir, ödemeler ekranıyla aynı kart tasarımı)
class _PostponedLessonsTab extends ConsumerWidget {
  final String studentId;

  const _PostponedLessonsTab({required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postponedAsync = ref.watch(postponedLessonsProvider);
    return postponedAsync.when(
      data: (list) {
        final forStudent = list.where((p) => p.studentId == studentId).toList();
        if (forStudent.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: AppColors.muted),
                const SizedBox(height: 16),
                Text(
                  StringsTr.noLessonsInCategory,
                  style: TextStyle(fontSize: 16, color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forStudent.length,
          itemBuilder: (context, index) {
            final postponed = forStudent[index];
            return _PostponedLessonCard(
              postponed: postponed,
              onTap: () => _showPostponedLessonDetailDialog(context, postponed),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('${StringsTr.errorPrefix}$error')),
    );
  }
}

/// İptal kartı (ödemeler ekranıyla aynı tasarım)
class _CancelledLessonCard extends StatelessWidget {
  final CancelledLessonInfo cancelled;
  final VoidCallback onTap;

  const _CancelledLessonCard({required this.cancelled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String reasonText = '';
    Color reasonColor = AppColors.muted;
    switch (cancelled.reasonType) {
      case 'student_cancelled':
        reasonText = 'Öğrenci İptal';
        reasonColor = AppColors.warning;
        break;
      case 'teacher_cancelled':
        reasonText = 'Öğretmen İptal';
        reasonColor = AppColors.primary;
        break;
      case 'other':
        reasonText = 'Diğer';
        reasonColor = AppColors.muted;
        break;
      default:
        reasonText = 'Bilinmeyen';
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          cancelled.studentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _dateTimeFormat.format(cancelled.date),
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: reasonColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: reasonColor),
                  ),
                  child: Text(
                    reasonText,
                    style: TextStyle(
                      color: reasonColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if ((cancelled.reason != null && cancelled.reason!.isNotEmpty) ||
                (cancelled.reasonNote != null && cancelled.reasonNote!.isNotEmpty)) ...[
              const SizedBox(height: 4),
              Text(
                '${StringsTr.reasonLabel}: ${cancelled.reason ?? cancelled.reasonNote ?? ''}',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
            if (cancelled.note != null && cancelled.note!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${StringsTr.noteLabel}: ${cancelled.note!}',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Icon(Icons.cancel, color: AppColors.danger),
      ),
    );
  }
}

/// Erteleme kartı (ödemeler ekranıyla aynı tasarım)
class _PostponedLessonCard extends StatelessWidget {
  final PostponedLessonInfo postponed;
  final VoidCallback onTap;

  const _PostponedLessonCard({required this.postponed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          postponed.studentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${StringsTr.previousDateLabel}: ${_dateFormat.format(postponed.fromDate)}',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${StringsTr.newDateLabel}: ${_dateTimeFormat.format(postponed.toDateTime)}',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (postponed.reason != null && postponed.reason!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${StringsTr.reasonLabel}: ${postponed.reason!}',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.schedule, color: AppColors.primary),
      ),
    );
  }
}

void _showCancelledLessonDetailDialog(BuildContext context, CancelledLessonInfo cancelled) {
  String sourceText = 'Bilinmeyen';
  Color sourceColor = AppColors.muted;
  switch (cancelled.reasonType) {
    case 'student_cancelled':
      sourceText = StringsTr.studentSource;
      sourceColor = AppColors.warning;
      break;
    case 'teacher_cancelled':
      sourceText = StringsTr.teacherSource;
      sourceColor = AppColors.primary;
      break;
    case 'other':
      sourceText = 'Diğer';
      sourceColor = AppColors.muted;
      break;
  }

  final items = <DetailInfoItem>[
    DetailInfoItem(
      label: 'Öğrenci',
      value: cancelled.studentName,
    ),
    DetailInfoItem(
      label: 'Ders Tarihi',
      value: _dateTimeFormat.format(cancelled.date),
    ),
    DetailInfoItem(
      label: StringsTr.sourceLabel,
      value: sourceText,
      valueColor: sourceColor,
    ),
  ];

  final reason = cancelled.reason?.trim();
  if (reason != null && reason.isNotEmpty) {
    items.add(DetailInfoItem(
      label: StringsTr.reasonLabel,
      value: reason,
    ));
  }

  final note = cancelled.note?.trim();
  if (note != null && note.isNotEmpty) {
    items.add(DetailInfoItem(
      label: StringsTr.noteLabel,
      value: note,
    ));
  }

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const DetailDialogTitle(
        icon: Icons.cancel_outlined,
        iconColor: AppColors.danger,
        title: StringsTr.cancellationDetailsTitle,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: DetailInfoPanel(items: items),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(StringsTr.ok),
          ),
        ),
      ],
    ),
  );
}

void _showPostponedLessonDetailDialog(BuildContext context, PostponedLessonInfo postponed) {
  final items = <DetailInfoItem>[
    DetailInfoItem(
      label: 'Öğrenci',
      value: postponed.studentName,
    ),
    DetailInfoItem(
      label: StringsTr.previousDateLabel,
      value: _dateFormat.format(postponed.fromDate),
      valueColor: AppColors.muted,
    ),
    DetailInfoItem(
      label: StringsTr.newDateLabel,
      value: _dateTimeFormat.format(postponed.toDateTime),
      valueColor: AppColors.primary,
      trailing: const Icon(Icons.arrow_forward, size: 18, color: AppColors.primary),
    ),
  ];

  final reason = postponed.reason?.trim();
  if (reason != null && reason.isNotEmpty) {
    items.add(DetailInfoItem(
      label: StringsTr.reasonLabel,
      value: reason,
    ));
  }

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const DetailDialogTitle(
        icon: Icons.schedule,
        iconColor: AppColors.warning,
        title: StringsTr.postponementDetailsTitle,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: DetailInfoPanel(items: items),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(StringsTr.ok),
          ),
        ),
      ],
    ),
  );
}

void _showReasonSourceDialog(BuildContext context, Lesson lesson) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(StringsTr.reasonAndSource),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lesson.statusReasonSource != null) ...[
              Text(
                '${StringsTr.sourceLabel}: ${lesson.statusReasonSource == 'TEACHER' ? StringsTr.teacherSource : StringsTr.studentSource}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
            ],
            if (lesson.statusReason != null && lesson.statusReason!.isNotEmpty) ...[
              Text(StringsTr.reasonLabel),
              const SizedBox(height: 4),
              Text(lesson.statusReason!),
              const SizedBox(height: 8),
            ],
            if (lesson.note != null && lesson.note!.isNotEmpty) ...[
              Text(StringsTr.noteLabel),
              const SizedBox(height: 4),
              Text(lesson.note!),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(StringsTr.ok),
          ),
        ),
      ],
    ),
  );
}
