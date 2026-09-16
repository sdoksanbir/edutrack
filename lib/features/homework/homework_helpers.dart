import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/models/homework_status.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

String homeworkStatusLabel(String status) {
  switch (status) {
    case HomeworkStatus.done:
      return StringsTr.homeworkStatusDone;
    case HomeworkStatus.notDone:
      return StringsTr.homeworkStatusNotDone;
    case HomeworkStatus.partial:
      return StringsTr.homeworkStatusPartial;
    case HomeworkStatus.notUnderstood:
      return StringsTr.homeworkStatusNotUnderstood;
    default:
      return StringsTr.homeworkStatusPending;
  }
}

Color homeworkStatusColor(String status) {
  switch (status) {
    case HomeworkStatus.done:
      return AppColors.success;
    case HomeworkStatus.notDone:
      return AppColors.danger;
    case HomeworkStatus.partial:
      return AppColors.warning;
    case HomeworkStatus.notUnderstood:
      return const Color(0xFFB07CFF);
    default:
      return AppColors.muted;
  }
}

bool homeworkItemNeedsAttention(HomeworkItem item, {String? statusOverride}) =>
    HomeworkStatus.needsAttention(
      statusOverride ?? item.status,
      item.dueAt,
    );

bool homeworkItemIsOverdue(HomeworkItem item) =>
    HomeworkStatus.isOverdue(item.status, item.dueAt);

String formatHomeworkDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}

String formatHomeworkDateLong(DateTime date) {
  return DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date);
}

String formatHomeworkDueLabel(HomeworkItem item) {
  if (item.dueAt == null) return StringsTr.homeworkDueNotSet;
  final due = formatHomeworkDate(item.dueAt!);
  if (homeworkItemIsOverdue(item)) {
    return '${StringsTr.homeworkDueOverdue}: $due';
  }
  return '${StringsTr.homeworkDueDate}: $due';
}

Color homeworkDueColor(HomeworkItem item) {
  if (item.dueAt == null) return AppColors.muted;
  if (homeworkItemIsOverdue(item)) return AppColors.danger;
  final daysLeft = item.dueAt!
      .difference(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ))
      .inDays;
  if (daysLeft <= 2) return AppColors.warning;
  return AppColors.muted;
}

List<LessonHomeworkGroup> filterLessonGroups(
  List<LessonHomeworkGroup> groups,
  bool attentionOnly,
) {
  if (!attentionOnly) return groups;
  return groups
      .map((group) {
        final filtered = group.items.where(homeworkItemNeedsAttention).toList();
        if (filtered.isEmpty) return null;
        return LessonHomeworkGroup(
          lessonId: group.lessonId,
          assignedAt: group.assignedAt,
          items: filtered,
        );
      })
      .whereType<LessonHomeworkGroup>()
      .toList();
}
