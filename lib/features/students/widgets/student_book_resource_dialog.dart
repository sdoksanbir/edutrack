import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

/// Yazarken anlık Türkçe büyük harf.
class _TurkishUpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = toTurkishUpperCaseLive(newValue.text);
    if (upper == newValue.text) return newValue;
    final base = newValue.selection.baseOffset.clamp(0, upper.length);
    final extent = newValue.selection.extentOffset.clamp(0, upper.length);
    return TextEditingValue(
      text: upper,
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }
}

enum StudentBookResourceKind {
  topic, // Konu anlatımlı
  practice, // Soru bankası / denemeler
}

List<String> parseStudentBookResources(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

String joinStudentBookResources(List<String> items) {
  return items.map((e) => e.trim()).where((e) => e.isNotEmpty).join('\n');
}

String? _rawForKind(Student student, StudentBookResourceKind kind) {
  return kind == StudentBookResourceKind.topic
      ? student.bookResource
      : student.bookResourcePractice;
}

/// Önce tür seçimi, sonra kaynak adı.
Future<void> showAddBookResourceDialog(
  BuildContext context,
  WidgetRef ref,
  Student student, {
  StudentBookResourceKind? initialKind,
}) async {
  final kind = initialKind ??
      await showDialog<StudentBookResourceKind>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Kaynak Türü',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book, color: AppColors.primary),
                ),
                title: const Text(StringsTr.bookResourceTopicLabel),
                subtitle: const Text('Konu anlatımlı soru bankaları'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                onTap: () =>
                    Navigator.pop(dialogContext, StudentBookResourceKind.topic),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.quiz_outlined, color: AppColors.warning),
                ),
                title: const Text(StringsTr.bookResourcePracticeLabel),
                subtitle: const Text('Deneme kitapları'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                onTap: () => Navigator.pop(
                  dialogContext,
                  StudentBookResourceKind.practice,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(StringsTr.cancel),
            ),
          ],
        ),
      );

  if (kind == null || !context.mounted) return;
  await _showNameDialog(context, ref, student, kind);
}

/// Kaynak adını düzenle.
Future<void> showEditBookResourceDialog(
  BuildContext context,
  WidgetRef ref,
  Student student, {
  required StudentBookResourceKind kind,
  required String currentName,
}) async {
  await _showNameDialog(
    context,
    ref,
    student,
    kind,
    editingName: currentName,
  );
}

Future<void> _showNameDialog(
  BuildContext context,
  WidgetRef ref,
  Student student,
  StudentBookResourceKind kind, {
  String? editingName,
}) async {
  final isEdit = editingName != null;
  final controller = TextEditingController(
    text: editingName != null ? toTurkishUpperCaseLive(editingName) : '',
  );
  final isTopic = kind == StudentBookResourceKind.topic;
  final categoryTitle = isTopic
      ? StringsTr.bookResourceTopicLabel
      : StringsTr.bookResourcePracticeLabel;
  final hint = isTopic
      ? StringsTr.bookResourceHint
      : StringsTr.bookResourcePracticeHint;
  final accent = isTopic ? AppColors.primary : AppColors.warning;
  final accentSoft = isTopic ? AppColors.primarySoft : AppColors.warningSoft;
  final icon = isEdit
      ? Icons.visibility_outlined
      : (isTopic ? Icons.menu_book : Icons.quiz_outlined);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Kaynağı Düzenle' : 'Kaynak Ekle',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoryTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Kaynak adı',
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [_TurkishUpperCaseFormatter()],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.pop(dialogContext, true),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(StringsTr.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isEdit ? StringsTr.save : StringsTr.add),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  final name = formatTurkishUpperCase(controller.text);
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kaynak adı boş olamaz')),
    );
    return;
  }

  final existing = parseStudentBookResources(_rawForKind(student, kind));

  if (isEdit) {
    final index = existing.indexWhere((e) => e == editingName);
    if (index < 0) return;
    final duplicate = existing.asMap().entries.any(
      (e) => e.key != index && e.value.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu kaynak zaten ekli')),
      );
      return;
    }
    existing[index] = name;
  } else {
    if (existing.any((e) => e.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu kaynak zaten ekli')),
      );
      return;
    }
    existing.add(name);
  }

  try {
    final repo = ref.read(studentsRepoProvider);
    final joined = joinStudentBookResources(existing);
    if (kind == StudentBookResourceKind.topic) {
      await repo.updateStudent(id: student.id, bookResource: joined);
    } else {
      await repo.updateStudent(id: student.id, bookResourcePractice: joined);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Kaynak güncellendi' : 'Kaynak eklendi')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${StringsTr.errorPrefix}$e')),
      );
    }
  }
}

Future<void> removeStudentBookResource(
  BuildContext context,
  WidgetRef ref,
  Student student,
  String resourceName,
  StudentBookResourceKind kind,
) async {
  final existing = parseStudentBookResources(_rawForKind(student, kind))
    ..removeWhere((e) => e == resourceName);

  try {
    final repo = ref.read(studentsRepoProvider);
    final joined = joinStudentBookResources(existing);
    if (kind == StudentBookResourceKind.topic) {
      await repo.updateStudent(id: student.id, bookResource: joined);
    } else {
      await repo.updateStudent(id: student.id, bookResourcePractice: joined);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${StringsTr.errorPrefix}$e')),
      );
    }
  }
}
