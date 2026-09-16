import 'package:flutter/material.dart';
import 'package:ozel_ders_takip/features/lessons/widgets/lesson_homework_fields.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

/// "Yapıldı" ders formu: konu / ödev / kaynak / ders notu.
/// DB işlemi yapmaz; form verisi döndürür.
class DoneLessonSheetResult {
  final String? topic;
  final String? homework;
  final String? homeworkResource;
  final String? note;

  const DoneLessonSheetResult({
    this.topic,
    this.homework,
    this.homeworkResource,
    this.note,
  });
}

class DoneLessonSheet extends StatefulWidget {
  const DoneLessonSheet({super.key, required this.studentId});

  final String studentId;

  @override
  State<DoneLessonSheet> createState() => _DoneLessonSheetState();
}

class _DoneLessonSheetState extends State<DoneLessonSheet> {
  late final TextEditingController _topicController;
  late final TextEditingController _homeworkController;
  late final TextEditingController _resourceController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
    _homeworkController = TextEditingController();
    _resourceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _homeworkController.dispose();
    _resourceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _formatController(TextEditingController controller) {
    final formatted = formatTurkishText(controller.text);
    if (formatted == controller.text) return;
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatAllFields() {
    _formatController(_topicController);
    _formatController(_homeworkController);
    _formatController(_notesController);
  }

  String? _nullIfEmpty(String text) {
    final t = formatTurkishText(text);
    return t.isEmpty ? null : t;
  }

  void _onSave() {
    if (!mounted) return;
    _formatAllFields();
    final result = DoneLessonSheetResult(
      topic: _nullIfEmpty(_topicController.text),
      homework: _nullIfEmpty(_homeworkController.text),
      homeworkResource: _nullIfEmpty(_resourceController.text),
      note: _nullIfEmpty(_notesController.text),
    );
    Navigator.of(context).pop<DoneLessonSheetResult>(result);
  }

  void _onCancel() {
    if (!mounted) return;
    Navigator.of(context).pop<DoneLessonSheetResult?>(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 28),
                const SizedBox(width: 12),
                Text(
                  StringsTr.done,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LessonHomeworkFields(
              studentId: widget.studentId,
              topicController: _topicController,
              homeworkController: _homeworkController,
              resourceController: _resourceController,
              compact: true,
              onFormatTopic: () => _formatController(_topicController),
              onFormatHomework: () => _formatController(_homeworkController),
              onFormatResource: () => _formatController(_resourceController),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: StringsTr.lessonNotesLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              minLines: 3,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              onEditingComplete: () => _formatController(_notesController),
              onTapOutside: (_) => _formatController(_notesController),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _onCancel,
                  child: Text(StringsTr.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _onSave,
                  child: Text(StringsTr.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
