import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/homework/homework_helpers.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/models/homework_status.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

class HomeworkItemTile extends ConsumerStatefulWidget {
  final HomeworkItem item;
  final String? studentName;

  const HomeworkItemTile({
    super.key,
    required this.item,
    this.studentName,
  });

  @override
  ConsumerState<HomeworkItemTile> createState() => _HomeworkItemTileState();
}

class _HomeworkItemTileState extends ConsumerState<HomeworkItemTile> {
  late String _status;
  late bool _attentionCleared;
  final _noteController = TextEditingController();

  static const _options = [
    (
      status: HomeworkStatus.done,
      label: StringsTr.homeworkStatusDone,
      icon: Icons.check_rounded,
      color: AppColors.success,
    ),
    (
      status: HomeworkStatus.notDone,
      label: StringsTr.homeworkStatusNotDone,
      icon: Icons.close_rounded,
      color: AppColors.danger,
    ),
    (
      status: HomeworkStatus.partial,
      label: StringsTr.homeworkStatusPartial,
      icon: Icons.remove_rounded,
      color: AppColors.warning,
    ),
    (
      status: HomeworkStatus.notUnderstood,
      label: StringsTr.homeworkStatusNotUnderstood,
      icon: Icons.help_outline_rounded,
      color: Color(0xFFB07CFF),
    ),
    (
      status: HomeworkStatus.pending,
      label: StringsTr.homeworkStatusPending,
      icon: Icons.schedule_rounded,
      color: AppColors.muted,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _attentionCleared = widget.item.attentionCleared;
    _noteController.text = widget.item.statusNote ?? '';
  }

  @override
  void didUpdateWidget(covariant HomeworkItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.status != widget.item.status) {
      _status = widget.item.status;
    }
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.attentionCleared != widget.item.attentionCleared) {
      _attentionCleared = widget.item.attentionCleared;
    }
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.statusNote != widget.item.statusNote) {
      _noteController.text = widget.item.statusNote ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveStatus(String status) async {
    if (_status == status) return;
    setState(() {
      _status = status;
      if (status != HomeworkStatus.notUnderstood) {
        _attentionCleared = false;
      }
    });
    await ref.read(homeworkRepoProvider).updateStatus(
          itemId: widget.item.id,
          status: status,
          statusNote: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
  }

  Future<void> _setAttentionCleared(bool cleared) async {
    setState(() => _attentionCleared = cleared);
    await ref.read(homeworkRepoProvider).updateAttentionCleared(
          itemId: widget.item.id,
          cleared: cleared,
        );
  }

  Future<DateTime?> _pickDate({
    required DateTime initial,
    required String helpText,
  }) async {
    if (!mounted) return null;
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      helpText: helpText,
    );
  }

  Future<void> _pickDueDate() async {
    final item = widget.item;
    final initial = item.dueAt ?? item.assignedAt.add(const Duration(days: 7));
    final picked = await _pickDate(
      initial: initial.isBefore(DateTime.now()) ? DateTime.now() : initial,
      helpText: StringsTr.homeworkSetDueDate,
    );
    if (picked == null) return;
    await ref.read(homeworkRepoProvider).updateDueDate(
          itemId: item.id,
          dueAt: picked,
        );
  }

  Future<String?> _resolveStudentName() async {
    final passed = widget.studentName?.trim();
    if (passed != null && passed.isNotEmpty) return passed;
    final student = await ref
        .read(studentsRepoProvider)
        .getStudentById(widget.item.studentId);
    return student?.fullName;
  }

  Future<void> _addToTodoList() async {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringsTr.todosAddNoteFirst)),
      );
      return;
    }

    final studentName = await _resolveStudentName();
    final added = await ref.read(todosRepoProvider).addTodoFromHomework(
          title: note,
          studentId: widget.item.studentId,
          studentName: studentName,
          homeworkItemId: widget.item.id,
          homeworkTopic: widget.item.topic,
        );

    if (!mounted) return;

    if (!added) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 36,
          ),
          title: const Text(StringsTr.todosAlreadyAddedTitle),
          content: const Text(StringsTr.todosAlreadyAddedBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(StringsTr.ok),
            ),
          ],
        ),
      );
      return;
    }

    await _saveStatus(_status);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(StringsTr.todosAdded)),
    );
  }

  Future<void> _giveExtension() async {
    final item = widget.item;
    final base = item.dueAt ?? DateTime.now();
    final initial = base.isBefore(DateTime.now())
        ? DateTime.now().add(const Duration(days: 3))
        : base.add(const Duration(days: 3));

    final picked = await _pickDate(
      initial: initial,
      helpText: StringsTr.homeworkExtensionHelp,
    );
    if (picked == null) return;

    final repo = ref.read(homeworkRepoProvider);
    await repo.updateDueDate(itemId: item.id, dueAt: picked);
    await repo.updateStatus(
      itemId: item.id,
      status: HomeworkStatus.pending,
      statusNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _status = HomeworkStatus.pending);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${StringsTr.homeworkExtensionSaved}: ${formatHomeworkDate(picked)}',
        ),
      ),
    );
  }

  bool get _isOverdue =>
      HomeworkStatus.isOverdue(_status, widget.item.dueAt);

  String _dueLabel(HomeworkItem item) {
    if (item.dueAt == null) return StringsTr.homeworkDueNotSet;
    final due = formatHomeworkDate(item.dueAt!);
    if (_isOverdue) return '${StringsTr.homeworkDueOverdue}: $due';
    return '${StringsTr.homeworkDueDate}: $due';
  }

  Color _dueColor(HomeworkItem item) {
    if (item.dueAt == null) return AppColors.muted;
    if (_isOverdue) return AppColors.danger;
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

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final needsAttention = homeworkItemNeedsAttention(
      item,
      statusOverride: _status,
      attentionClearedOverride: _attentionCleared,
    );
    final statusColor = homeworkStatusColor(_status);
    final showExtension = _status == HomeworkStatus.partial ||
        _status == HomeworkStatus.notDone;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: needsAttention
              ? statusColor.withValues(alpha: 0.55)
              : AppColors.border,
          width: needsAttention ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.resource != null && item.resource!.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item.resource!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Text(
              item.topic,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (item.detail != null && item.detail!.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.detail!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: _dueColor(item),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _dueLabel(item),
                        style: TextStyle(
                          fontSize: 12,
                          color: _dueColor(item),
                          fontWeight:
                              _isOverdue ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(Icons.edit_outlined, size: 12, color: AppColors.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _StatusSegmentBar(
              options: _options,
              selected: _status,
              onSelected: _saveStatus,
            ),
            if (showExtension) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _giveExtension,
                  icon: const Icon(Icons.more_time, size: 16),
                  label: const Text(StringsTr.homeworkGiveExtension),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.warning,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
            if (_status != HomeworkStatus.done &&
                _status != HomeworkStatus.pending) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: StringsTr.homeworkStatusNoteHint,
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: _status == HomeworkStatus.notUnderstood
                      ? IconButton(
                          tooltip: StringsTr.todosAddToList,
                          icon: const Icon(Icons.check_circle_outline),
                          color: AppColors.success,
                          onPressed: _addToTodoList,
                        )
                      : null,
                ),
                maxLines: 2,
                onSubmitted: (_) => _saveStatus(_status),
                onTapOutside: (_) {
                  ref.read(homeworkRepoProvider).updateStatus(
                        itemId: widget.item.id,
                        status: _status,
                        statusNote: _noteController.text.trim().isEmpty
                            ? null
                            : _noteController.text.trim(),
                      );
                },
              ),
              if (_status == HomeworkStatus.notUnderstood)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _setAttentionCleared(!_attentionCleared),
                        borderRadius: BorderRadius.circular(8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: Checkbox(
                                value: _attentionCleared,
                                onChanged: (v) =>
                                    _setAttentionCleared(v ?? false),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Flexible(
                              child: Text(
                                StringsTr.homeworkAttentionCleared,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addToTodoList,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(StringsTr.todosAddToList),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusSegmentBar extends StatelessWidget {
  final List<
      ({
        String status,
        String label,
        IconData icon,
        Color color,
      })> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _StatusSegmentBar({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 44,
                color: AppColors.border,
              ),
            Expanded(
              child: _StatusSegment(
                label: options[i].label,
                icon: options[i].icon,
                color: options[i].color,
                selected: selected == options[i].status,
                onTap: () => onSelected(options[i].status),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusSegment({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? color : AppColors.textPrimary.withValues(alpha: 0.72);
    return Material(
      color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
