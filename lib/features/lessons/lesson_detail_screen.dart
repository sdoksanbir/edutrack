import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';
import 'package:ozel_ders_takip/shared/utils/whatsapp_share.dart';
import 'package:ozel_ders_takip/shared/widgets/detail_info_panel.dart';
import 'package:ozel_ders_takip/features/lessons/widgets/lesson_homework_fields.dart';

final _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');

/// Ders detayı: Sadece Konu, Ödev, Ders Notu. Ücret/ödeme ve bir önceki ders yok.
class LessonDetailScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  final bool? scrollToPayments;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    this.scrollToPayments,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late TextEditingController _topicController;
  late TextEditingController _homeworkController;
  late TextEditingController _resourceController;
  late TextEditingController _lessonNotesController;

  String? _studentName;
  String? _studentPhone;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(
      text: formatTurkishText(widget.lesson.topic ?? ''),
    );
    _homeworkController = TextEditingController(
      text: formatTurkishText(widget.lesson.homework ?? ''),
    );
    _resourceController = TextEditingController(
      text: widget.lesson.homeworkResource ?? '',
    );
    _lessonNotesController = TextEditingController(
      text: formatTurkishText(widget.lesson.lessonNotes ?? ''),
    );
    _loadStudentName();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _homeworkController.dispose();
    _resourceController.dispose();
    _lessonNotesController.dispose();
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

  String? _nullIfEmpty(String text) {
    final t = formatTurkishText(text);
    return t.isEmpty ? null : t;
  }

  Future<void> _loadStudentName() async {
    try {
      final studentsRepo = ref.read(studentsRepoProvider);
      final student = await studentsRepo.getStudentById(widget.lesson.studentId);
      if (mounted) {
        setState(() {
          _studentName = student?.fullName;
          _studentPhone = student?.phone;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendWhatsApp() async {
    final message = buildLessonWhatsAppMessage(
      studentName: _studentName ?? 'Öğrenci',
      lessonDateTime: widget.lesson.startDateTime,
      topic: _nullIfEmpty(_topicController.text) ?? widget.lesson.topic,
      homework: _nullIfEmpty(_homeworkController.text) ?? widget.lesson.homework,
      homeworkResource: _resourceController.text.trim().isEmpty
          ? widget.lesson.homeworkResource
          : _resourceController.text.trim(),
      lessonNotes:
          _nullIfEmpty(_lessonNotesController.text) ?? widget.lesson.lessonNotes,
    );

    await sendWhatsAppMessage(
      context: context,
      message: message,
      phone: _studentPhone,
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required Color accent,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: TextStyle(color: AppColors.muted.withValues(alpha: 0.55)),
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
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
      // Yazı üst kenardan rahat dursun
      contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
    );
  }

  Widget _fieldHeader({
    required IconData icon,
    required Color accent,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text(StringsTr.lessonDetailTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final initial = (_studentName ?? '?').trim().isEmpty
        ? '?'
        : (_studentName!)[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          StringsTr.lessonDetailTitle,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Color(0xFF25D366)),
            onPressed: _sendWhatsApp,
            tooltip: StringsTr.sendWhatsApp,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: _showDeleteDialog,
            tooltip: StringsTr.delete,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Öğrenci + tarih kartı (mavi ton)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _studentName ?? 'Bilinmeyen Öğrenci',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 15,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _dateTimeFormat
                                          .format(widget.lesson.startDateTime),
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const DetailStatusBadge(
                                label: StringsTr.done,
                                color: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Ders içeriği',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Form alanları paneli (nötr yükseltilmiş zemin)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        LessonHomeworkFields(
                          studentId: widget.lesson.studentId,
                          topicController: _topicController,
                          homeworkController: _homeworkController,
                          resourceController: _resourceController,
                          onFormatTopic: () =>
                              _formatController(_topicController),
                          onFormatHomework: () =>
                              _formatController(_homeworkController),
                          onFormatResource: () =>
                              _formatController(_resourceController),
                        ),
                        const SizedBox(height: 20),
                        _fieldHeader(
                          icon: Icons.sticky_note_2_outlined,
                          accent: AppColors.accent,
                          title: StringsTr.lessonNotesLabel,
                        ),
                        TextField(
                          controller: _lessonNotesController,
                          decoration: _fieldDecoration(
                            hint: 'Ders notları...',
                            accent: AppColors.accent,
                          ),
                          minLines: 3,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          textCapitalization: TextCapitalization.sentences,
                          onEditingComplete: () =>
                              _formatController(_lessonNotesController),
                          onTapOutside: (_) =>
                              _formatController(_lessonNotesController),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kaydet — altta sabit
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveLesson,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    _isSaving ? 'Kaydediliyor...' : StringsTr.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLesson() async {
    setState(() => _isSaving = true);
    try {
      _formatController(_topicController);
      _formatController(_homeworkController);
      _formatController(_lessonNotesController);

      final lessonsRepo = ref.read(lessonsRepoProvider);
      await lessonsRepo.updateLessonNotes(
        lessonId: widget.lesson.id,
        topic: _nullIfEmpty(_topicController.text),
        homework: _nullIfEmpty(_homeworkController.text),
        homeworkResource: _nullIfEmpty(_resourceController.text),
        lessonNotes: _nullIfEmpty(_lessonNotesController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Güncellendi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${StringsTr.errorPrefix}$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showDeleteDialog() async {
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const DetailDialogTitle(
          icon: Icons.delete_outline,
          iconColor: AppColors.danger,
          title: 'Ders Kaydını Sil',
        ),
        content: const Text('Bu ders kaydını silmek istediğinize emin misiniz?'),
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
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(StringsTr.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final lessonsRepo = ref.read(lessonsRepoProvider);
      await lessonsRepo.deleteLesson(widget.lesson.id);
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ders kaydı silindi')),
        );
        context.go(AppRouter.lessons);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${StringsTr.errorPrefix}$e')),
        );
      }
    }
  }
}
