import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

final openTodosProvider = StreamProvider.autoDispose<List<TeacherTodo>>((ref) {
  return ref.watch(todosRepoProvider).watchOpenTodos();
});

final allTodosProvider = StreamProvider.autoDispose<List<TeacherTodo>>((ref) {
  return ref.watch(todosRepoProvider).watchAllTodos();
});

class _TodoEditorResult {
  final String title;
  final DateTime? notifyAt;
  final bool clearNotifyAt;

  const _TodoEditorResult({
    required this.title,
    this.notifyAt,
    this.clearNotifyAt = false,
  });
}

class TodosScreen extends ConsumerStatefulWidget {
  const TodosScreen({super.key});

  @override
  ConsumerState<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends ConsumerState<TodosScreen> {
  bool _showDone = false;

  Future<void> _addManualTodo() async {
    final result = await showDialog<_TodoEditorResult>(
      context: context,
      builder: (ctx) => const TodoEditorDialog(
        dialogTitle: StringsTr.todosAdd,
      ),
    );
    if (result == null || result.title.isEmpty) return;
    await ref.read(todosRepoProvider).addTodo(
          title: result.title,
          notifyAt: result.notifyAt,
        );
  }

  Future<void> _editTodo(TeacherTodo todo) async {
    final result = await showDialog<_TodoEditorResult>(
      context: context,
      builder: (ctx) => TodoEditorDialog(
        dialogTitle: StringsTr.todosEdit,
        initialText: todo.title,
        initialNotifyAt: todo.notifyAt,
      ),
    );
    if (result == null || result.title.isEmpty) return;

    final unchanged = result.title == todo.title &&
        !result.clearNotifyAt &&
        result.notifyAt == todo.notifyAt;
    if (unchanged) return;

    await ref.read(todosRepoProvider).updateTodo(
          id: todo.id,
          title: result.title,
          notifyAt: result.notifyAt,
          clearNotifyAt: result.clearNotifyAt ||
              (todo.notifyAt != null && result.notifyAt == null),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.notifyAt != null
              ? StringsTr.todosNotifyScheduled
              : StringsTr.todosUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync =
        _showDone ? ref.watch(allTodosProvider) : ref.watch(openTodosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsTr.todosTitle),
        actions: [
          IconButton(
            tooltip:
                _showDone ? StringsTr.todosShowOpen : StringsTr.todosShowAll,
            onPressed: () => setState(() => _showDone = !_showDone),
            icon: Icon(_showDone ? Icons.filter_list : Icons.done_all),
          ),
        ],
      ),
      body: todosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('${StringsTr.errorPrefix}$error'),
        ),
        data: (todos) {
          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist_rtl, size: 64, color: AppColors.muted),
                  const SizedBox(height: 16),
                  Text(
                    StringsTr.todosEmpty,
                    style: TextStyle(fontSize: 16, color: AppColors.muted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return _TodoTile(
                todo: todo,
                onEdit: () => _editTodo(todo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addManualTodo,
        icon: const Icon(Icons.add),
        label: const Text(StringsTr.todosAdd),
      ),
    );
  }
}

class TodoEditorDialog extends StatefulWidget {
  final String dialogTitle;
  final String? initialText;
  final DateTime? initialNotifyAt;

  const TodoEditorDialog({
    super.key,
    this.dialogTitle = StringsTr.todosAdd,
    this.initialText,
    this.initialNotifyAt,
  });

  @override
  State<TodoEditorDialog> createState() => _TodoEditorDialogState();
}

class _TodoEditorDialogState extends State<TodoEditorDialog> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  DateTime? _notifyAt;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
    _notifyAt = widget.initialNotifyAt;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickNotifyAt() async {
    final now = DateTime.now();
    final initialDate = _notifyAt ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      helpText: StringsTr.todosNotifyAt,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: StringsTr.todosNotifyAt,
    );
    if (time == null || !mounted) return;

    setState(() {
      _notifyAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(
      context,
      _TodoEditorResult(
        title: text,
        notifyAt: _notifyAt,
        clearNotifyAt: widget.initialNotifyAt != null && _notifyAt == null,
      ),
    );
  }

  String _formatNotifyAt(DateTime dt) {
    return DateFormat('dd MMM yyyy HH:mm', 'tr_TR').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth,
          minWidth: screenWidth - 40,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.dialogTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                minLines: 1,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(fontSize: 15, height: 1.35),
                decoration: InputDecoration(
                  hintText: StringsTr.todosAddHint,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Material(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _pickNotifyAt,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 18,
                          color: _notifyAt != null
                              ? AppColors.primary
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StringsTr.todosNotifyAt,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _notifyAt != null
                                    ? _formatNotifyAt(_notifyAt!)
                                    : StringsTr.todosNotifyAtHint,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _notifyAt != null
                                      ? AppColors.textPrimary
                                      : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_notifyAt != null)
                          TextButton(
                            onPressed: () => setState(() => _notifyAt = null),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text(StringsTr.todosNotifyClear),
                          )
                        else
                          Text(
                            StringsTr.todosNotifySet,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(StringsTr.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        _controller.text.trim().isEmpty ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text(StringsTr.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoTile extends ConsumerWidget {
  final TeacherTodo todo;
  final VoidCallback onEdit;

  const _TodoTile({
    required this.todo,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasStudent =
        todo.studentName != null && todo.studentName!.trim().isNotEmpty;
    final hasTopic =
        todo.homeworkTopic != null && todo.homeworkTopic!.trim().isNotEmpty;
    final hasNotify = todo.notifyAt != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: onEdit,
        leading: Checkbox(
          value: todo.isDone,
          activeColor: AppColors.success,
          onChanged: (value) {
            ref.read(todosRepoProvider).toggleDone(todo.id, value ?? false);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasStudent) ...[
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      todo.studentName!.trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              todo.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
                color: todo.isDone ? AppColors.muted : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasTopic)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${StringsTr.homeworkLabel}: ${todo.homeworkTopic!.trim()}',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
            if (hasNotify)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      size: 13,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy HH:mm', 'tr_TR')
                          .format(todo.notifyAt!),
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.muted),
          onPressed: () => ref.read(todosRepoProvider).deleteTodo(todo.id),
        ),
      ),
    );
  }
}
