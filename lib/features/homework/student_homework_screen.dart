import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/homework_repo.dart';
import 'package:ozel_ders_takip/features/homework/homework_helpers.dart';
import 'package:ozel_ders_takip/features/homework/widgets/homework_item_tile.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

enum _HomeworkFilter { all, attention }

enum _DatePreset { all, week, month, custom }

final _longDateFormat = DateFormat('d MMMM yyyy, EEEE', 'tr_TR');

String _formatLongDate(DateTime date) => _longDateFormat.format(date);

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

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

class _StudentHomeworkScreenState extends ConsumerState<StudentHomeworkScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _allTabMounted = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChanged);
    // İlk kareden sonra arka planda hazırla; sekmeye geçince takılma azalır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (!mounted || _allTabMounted) return;
        setState(() => _allTabMounted = true);
      });
    });
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;
    if (_tabs.index == 1 && !_allTabMounted) {
      setState(() => _allTabMounted = true);
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: StringsTr.homeworkTabByLesson),
            Tab(text: StringsTr.homeworkTabAllItems),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        // Kaydırırken ağır ikinci sekmenin erken kurulumunu azaltır
        physics: const ClampingScrollPhysics(),
        children: [
          _LessonsHomeworkTab(
            studentId: widget.studentId,
            studentName: widget.studentName,
          ),
          _allTabMounted
              ? _AllHomeworkTab(
                  studentId: widget.studentId,
                  studentName: widget.studentName,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _LessonsHomeworkTab extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;

  const _LessonsHomeworkTab({
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<_LessonsHomeworkTab> createState() =>
      _LessonsHomeworkTabState();
}

class _LessonsHomeworkTabState extends ConsumerState<_LessonsHomeworkTab>
    with AutomaticKeepAliveClientMixin {
  _HomeworkFilter _filter = _HomeworkFilter.all;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final groupsStream = ref
        .watch(homeworkRepoProvider)
        .watchLessonGroupsByStudent(widget.studentId);

    return Column(
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
                  return const _EmptyHomeworkState(
                    message: 'Takip gereken ödev yok',
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
                return const _EmptyHomeworkState(
                  message: StringsTr.noHomeworksYet,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _LessonHomeworkCard(
                    group: group,
                    onTap: () => context.push(
                      '${AppRouter.homeworks}/student/${widget.studentId}/lesson/${group.lessonId}',
                      extra: {
                        'studentName': widget.studentName,
                        'assignedAt': group.assignedAt,
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
    );
  }
}

class _AllHomeworkTab extends ConsumerStatefulWidget {
  final String studentId;
  final String studentName;

  const _AllHomeworkTab({
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<_AllHomeworkTab> createState() => _AllHomeworkTabState();
}

class _AllHomeworkTabState extends ConsumerState<_AllHomeworkTab>
    with AutomaticKeepAliveClientMixin {
  _DatePreset _datePreset = _DatePreset.all;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  bool get wantKeepAlive => true;

  ({DateTime? start, DateTime? end}) _resolvedRange() {
    final today = _dayOnly(DateTime.now());
    switch (_datePreset) {
      case _DatePreset.all:
        return (start: null, end: null);
      case _DatePreset.week:
        return (start: today.subtract(const Duration(days: 6)), end: today);
      case _DatePreset.month:
        return (start: DateTime(today.year, today.month, 1), end: today);
      case _DatePreset.custom:
        return (start: _rangeStart, end: _rangeEnd);
    }
  }

  bool _inRange(HomeworkItem item) {
    final range = _resolvedRange();
    if (range.start == null && range.end == null) return true;
    final assigned = _dayOnly(item.assignedAt);
    if (range.start != null && assigned.isBefore(range.start!)) return false;
    if (range.end != null && assigned.isAfter(range.end!)) return false;
    return true;
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    DateTimeRange? initialRange;
    if (_rangeStart != null && _rangeEnd != null) {
      initialRange = DateTimeRange(start: _rangeStart!, end: _rangeEnd!);
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: initialRange,
      locale: const Locale('tr', 'TR'),
      helpText: StringsTr.homeworkDateFilterRangeHelp,
      saveText: StringsTr.homeworkDateFilterSave,
      cancelText: StringsTr.cancel,
      fieldStartHintText: StringsTr.homeworkDateFilterFrom,
      fieldEndHintText: StringsTr.homeworkDateFilterTo,
      fieldStartLabelText: StringsTr.homeworkDateFilterFrom,
      fieldEndLabelText: StringsTr.homeworkDateFilterTo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.surface,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.white,
              rangeSelectionBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.28),
              rangeSelectionOverlayColor: WidgetStateProperty.all(
                AppColors.primary.withValues(alpha: 0.12),
              ),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColors.textPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return null;
              }),
              todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
              todayBorder: const BorderSide(color: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;

    setState(() {
      _datePreset = _DatePreset.custom;
      _rangeStart = _dayOnly(picked.start);
      _rangeEnd = _dayOnly(picked.end);
    });
  }

  List<_AllListRow> _buildRows(List<HomeworkItem> filtered) {
    final rows = <_AllListRow>[];
    DateTime? lastDay;
    for (final item in filtered) {
      final day = _dayOnly(item.assignedAt);
      if (lastDay == null || lastDay != day) {
        rows.add(_AllListRow.header(day));
        lastDay = day;
      }
      rows.add(_AllListRow.item(item));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final itemsStream =
        ref.watch(homeworkRepoProvider).watchByStudent(widget.studentId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DateChip(
                  label: StringsTr.filterAllHomework,
                  selected: _datePreset == _DatePreset.all,
                  onTap: () => setState(() {
                    _datePreset = _DatePreset.all;
                    _rangeStart = null;
                    _rangeEnd = null;
                  }),
                ),
                _DateChip(
                  label: StringsTr.homeworkDateFilterWeek,
                  selected: _datePreset == _DatePreset.week,
                  onTap: () => setState(() => _datePreset = _DatePreset.week),
                ),
                _DateChip(
                  label: StringsTr.homeworkDateFilterMonth,
                  selected: _datePreset == _DatePreset.month,
                  onTap: () => setState(() => _datePreset = _DatePreset.month),
                ),
                _DateChip(
                  label: _datePreset == _DatePreset.custom &&
                          _rangeStart != null &&
                          _rangeEnd != null
                      ? '${formatHomeworkDate(_rangeStart!)} – ${formatHomeworkDate(_rangeEnd!)}'
                      : StringsTr.homeworkDateFilterCustom,
                  selected: _datePreset == _DatePreset.custom,
                  onTap: _pickCustomRange,
                ),
                if (_datePreset != _DatePreset.all)
                  _DateChip(
                    label: StringsTr.homeworkDateFilterClear,
                    selected: false,
                    onTap: () => setState(() {
                      _datePreset = _DatePreset.all;
                      _rangeStart = null;
                      _rangeEnd = null;
                    }),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<HomeworkItem>>(
            stream: itemsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('${StringsTr.errorPrefix}${snapshot.error}'),
                );
              }

              final all = snapshot.data ?? [];
              if (all.isEmpty) {
                return const _EmptyHomeworkState(
                  message: StringsTr.noHomeworksYet,
                );
              }

              final filtered = all.where(_inRange).toList();
              if (filtered.isEmpty) {
                return const _EmptyHomeworkState(
                  message: StringsTr.homeworkNoItemsInRange,
                );
              }

              final rows = _buildRows(filtered);

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  if (row.isHeader) {
                    return Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : 10,
                        bottom: 8,
                      ),
                      child: Text(
                        _formatLongDate(row.day!),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    );
                  }
                  final item = row.item!;
                  return HomeworkItemTile(
                    key: ValueKey(item.id),
                    item: item,
                    studentName: widget.studentName,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AllListRow {
  final DateTime? day;
  final HomeworkItem? item;

  const _AllListRow.header(this.day) : item = null;
  const _AllListRow.item(this.item) : day = null;

  bool get isHeader => day != null;
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primarySoft,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
        side: BorderSide(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
        ),
        backgroundColor: AppColors.surface,
      ),
    );
  }
}

class _EmptyHomeworkState extends StatelessWidget {
  final String message;

  const _EmptyHomeworkState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: AppColors.muted),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.muted),
            textAlign: TextAlign.center,
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
          _formatLongDate(group.assignedAt),
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
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            if (due != null) ...[
              const SizedBox(height: 2),
              Text(
                '${StringsTr.homeworkDueDate}: ${formatHomeworkDate(due)}',
                style: const TextStyle(
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
