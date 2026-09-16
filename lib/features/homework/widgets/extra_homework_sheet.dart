import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/features/lessons/widgets/lesson_homework_fields.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

Future<void> showExtraHomeworkSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExtraHomeworkSheet(),
  );
}

class _ExtraHomeworkSheet extends ConsumerStatefulWidget {
  const _ExtraHomeworkSheet();

  @override
  ConsumerState<_ExtraHomeworkSheet> createState() =>
      _ExtraHomeworkSheetState();
}

class _ExtraHomeworkSheetState extends ConsumerState<_ExtraHomeworkSheet> {
  final _taughtTopicCtrl = TextEditingController();
  final _homeworkCtrl = TextEditingController();
  final _resourceCtrl = TextEditingController();
  String? _studentId;
  DateTime? _dueAt;
  bool _saving = false;
  List<Student> _students = const [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final list = await ref.read(studentsRepoProvider).getAllStudents();
    if (!mounted) return;
    setState(() {
      _students = list.where((s) => s.isActive).toList();
      if (_students.length == 1) {
        _studentId = _students.first.id;
      }
    });
  }

  @override
  void dispose() {
    _taughtTopicCtrl.dispose();
    _homeworkCtrl.dispose();
    _resourceCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  void _onStudentChanged(String? id) {
    setState(() {
      _studentId = id;
      _taughtTopicCtrl.clear();
      _homeworkCtrl.clear();
      _resourceCtrl.clear();
    });
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueAt ?? now.add(const Duration(days: 7));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    setState(() {
      _dueAt = DateTime(date.year, date.month, date.day, 23, 59);
    });
  }

  Future<void> _submit() async {
    if (_students.isEmpty) {
      _snack('Önce aktif öğrenci ekleyin');
      return;
    }
    if (_studentId == null) {
      _snack('Öğrenci seçin');
      return;
    }

    final drafts = expandHomeworkItems(
      homeworkResource: _resourceCtrl.text,
      homework: _homeworkCtrl.text,
    );
    if (drafts.isEmpty) {
      _snack('Kaynaklardan konu seçin veya ödev yazın');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(homeworkRepoProvider).addExtraHomework(
            studentId: _studentId!,
            homework: _homeworkCtrl.text.trim().isEmpty
                ? null
                : _homeworkCtrl.text.trim(),
            homeworkResource: _resourceCtrl.text.trim().isEmpty
                ? null
                : _resourceCtrl.text.trim(),
            dueAt: _dueAt,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text(StringsTr.extraHomeworkAdded)),
      );
    } catch (e) {
      if (!mounted) return;
      _snack('Hata: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final dueLabel = _dueAt == null
        ? 'Varsayılan (7 gün)'
        : DateFormat('dd MMM yyyy', 'tr_TR').format(_dueAt!);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.note_add_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsTr.extraHomeworkTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Öğrenci kaynaklarından konu seçin',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                children: [
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _studentId,
                    isExpanded: true,
                    decoration: _dec(
                      label: 'Öğrenci *',
                      icon: Icons.person_outline,
                    ),
                    items: _students
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(
                              s.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged:
                        _students.isEmpty ? null : _onStudentChanged,
                  ),
                  if (_studentId != null) ...[
                    const SizedBox(height: 16),
                    LessonHomeworkFields(
                      key: ValueKey(_studentId),
                      studentId: _studentId!,
                      topicController: _taughtTopicCtrl,
                      homeworkController: _homeworkCtrl,
                      resourceController: _resourceCtrl,
                      compact: true,
                      showTaughtTopics: false,
                    ),
                    const SizedBox(height: 12),
                    Material(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _pickDueDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                color: AppColors.muted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      StringsTr.homeworkDueDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dueLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_dueAt != null)
                                IconButton(
                                  tooltip: 'Varsayılana dön',
                                  onPressed: () =>
                                      setState(() => _dueAt = null),
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.muted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Ödev seçmek için önce öğrenci seçin',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(StringsTr.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _saving || _studentId == null
                            ? null
                            : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(StringsTr.extraHomeworkAdd),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
