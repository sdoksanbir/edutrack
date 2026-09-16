import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:ozel_ders_takip/features/homework/homework_helpers.dart';
import 'package:ozel_ders_takip/features/homework/widgets/homework_item_tile.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

enum _HomeworkFilter { all, attention }

class StudentHomeworkScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;

  const StudentHomeworkScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<StudentHomeworkScreen> createState() =>
      _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends ConsumerState<StudentHomeworkScreen> {
  _HomeworkFilter _filter = _HomeworkFilter.all;

  @override
  Widget build(BuildContext context) {
    final groupsStream = ref
        .watch(homeworkRepoProvider)
        .watchLessonGroupsByStudent(widget.studentId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<_HomeworkFilter>(
              segments: const [
                ButtonSegment(
                  value: _HomeworkFilter.all,
                  label: Text(StringsTr.filterAllHomework),
                ),
                ButtonSegment(
                  value: _HomeworkFilter.attention,
                  label: Text(StringsTr.filterAttentionHomework),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (value) {
                setState(() => _filter = value.first);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<LessonHomeworkGroup>>(
              stream: groupsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('${StringsTr.errorPrefix}${snapshot.error}'),
                  );
                }

                final groups = snapshot.data ?? [];

                if (_filter == _HomeworkFilter.attention) {
                  final attentionItems = groups
                      .expand((group) => group.items)
                      .where(homeworkItemNeedsAttention)
                      .toList()
                    ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));

                  if (attentionItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 64, color: AppColors.muted),
                          const SizedBox(height: 16),
                          Text(
                            'Takip gereken ödev yok',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.muted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: attentionItems.length,
                    itemBuilder: (context, index) {
                      final item = attentionItems[index];
                      return HomeworkItemTile(
                        key: ValueKey(item.id),
                        item: item,
                        studentName: widget.studentName,
                      );
                    },
                  );
                }

                if (groups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 64, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          StringsTr.noHomeworksYet,
                          style:
                              TextStyle(fontSize: 16, color: AppColors.muted),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return _LessonHomeworkCard(
                      group: groups[index],
                      onTap: () => context.push(
                        '${AppRouter.homeworks}/student/${widget.studentId}/lesson/${groups[index].lessonId}',
                        extra: {
                          'studentName': widget.studentName,
                          'assignedAt': groups[index].assignedAt,
                          'attentionOnly': false,
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonHomeworkCard extends StatelessWidget {
  final LessonHomeworkGroup group;
  final VoidCallback onTap;

  const _LessonHomeworkCard({
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final alerts = group.alertCount;
    final due = group.earliestDue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alerts > 0
              ? AppColors.warning.withValues(alpha: 0.6)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySoft,
          child: Text(
            '${group.assignedAt.day}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          formatHomeworkDateLong(group.assignedAt),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${group.itemCount} ödev',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            if (due != null) ...[
              const SizedBox(height: 2),
              Text(
                '${StringsTr.homeworkDueDate}: ${formatHomeworkDate(due)}',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: alerts > 0
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$alerts ${StringsTr.homeworkAlertCount}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }
}
