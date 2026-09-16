import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/providers/calendar_providers.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/payments_repo.dart';
import 'package:ozel_ders_takip/features/home/home_screen.dart';
import 'package:ozel_ders_takip/features/lessons/widgets/lesson_homework_fields.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/models/daily_lesson.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/name_format.dart';

enum _LessonCreateAction { done, notDone, postponed, cancelled }

class LessonCreateScreen extends ConsumerStatefulWidget {
  final DailyLesson dailyLesson;

  const LessonCreateScreen({
    super.key,
    required this.dailyLesson,
  });

  @override
  ConsumerState<LessonCreateScreen> createState() => _LessonCreateScreenState();
}

class _LessonCreateScreenState extends ConsumerState<LessonCreateScreen> {
  late TextEditingController _topicController;
  late TextEditingController _homeworkController;
  late TextEditingController _resourceController;
  late TextEditingController _feeExpectedController;
  late TextEditingController _noteController;
  late TextEditingController _reasonController;
  late TextEditingController _extraNoteController;

  int? _hourlyRate;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPaid = false; // varsayılan: ödenmedi
  String _paymentMethod = 'cash'; // cash | transfer

  _LessonCreateAction? _action;
  String? _missedSource; // TEACHER | STUDENT
  DateTime? _postponeDate;
  TimeOfDay? _postponeTime;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
    _homeworkController = TextEditingController();
    _resourceController = TextEditingController();
    _noteController = TextEditingController();
    _reasonController = TextEditingController();
    _extraNoteController = TextEditingController();
    _loadStudentData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _homeworkController.dispose();
    _resourceController.dispose();
    _feeExpectedController.dispose();
    _noteController.dispose();
    _reasonController.dispose();
    _extraNoteController.dispose();
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

  Future<void> _loadStudentData() async {
    try {
      final studentsRepo = ref.read(studentsRepoProvider);
      final student =
          await studentsRepo.getStudentById(widget.dailyLesson.studentId);

      if (student != null) {
        setState(() {
          _hourlyRate = student.hourlyRate;
          final feeExpected =
              ((_hourlyRate! * widget.dailyLesson.durationMin) / 60).round();
          _feeExpectedController =
              TextEditingController(text: feeExpected.toString());
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _selectAction(_LessonCreateAction action) {
    setState(() {
      _action = action;
      if (action != _LessonCreateAction.notDone &&
          action != _LessonCreateAction.cancelled) {
        _missedSource = null;
      }
      if (action == _LessonCreateAction.postponed) {
        final start = widget.dailyLesson.startDateTime;
        final tomorrow = DateTime(start.year, start.month, start.day)
            .add(const Duration(days: 1));
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        _postponeDate = tomorrow.isBefore(today) ? today : tomorrow;
        _postponeTime = TimeOfDay.fromDateTime(start);
      }
    });
  }

  String _formatDateYmd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _formatTimeHm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  Future<String> _ensureOccurrenceId() async {
    final existing = widget.dailyLesson.occurrenceId;
    if (existing != null && existing.isNotEmpty) return existing;

    final scheduleRepo = ref.read(scheduleRepoProvider);
    final start = widget.dailyLesson.startDateTime;
    return scheduleRepo.upsertOccurrenceForTemplateDate(
      templateId: widget.dailyLesson.templateId,
      date: _formatDateYmd(start),
      startTime: _formatTimeHm(start),
      durationMin: widget.dailyLesson.durationMin,
      status: 'planned',
      studentId: widget.dailyLesson.studentId,
    );
  }

  void _invalidateAfterChange({DateTime? alsoMonth}) {
    final now = DateTime.now();
    final months = <DateTime>{
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month - 1, 1),
      DateTime(now.year, now.month + 1, 1),
      DateTime(
        widget.dailyLesson.startDateTime.year,
        widget.dailyLesson.startDateTime.month,
        1,
      ),
      if (alsoMonth != null) DateTime(alsoMonth.year, alsoMonth.month, 1),
    };
    for (final m in months) {
      final start = DateTime(m.year, m.month, 1);
      final end = DateTime(m.year, m.month + 1, 0);
      ref.invalidate(calendarLessonsProvider(DateTimeRange(start: start, end: end)));
    }
    ref.invalidate(todayLessonsProvider);
    ref.invalidate(globalPaymentSummaryProvider);
    ref.invalidate(studentPaymentSummariesProvider);
    ref.invalidate(studentPaymentSummaryProvider(widget.dailyLesson.studentId));
    ref.invalidate(
      studentUnpaidLessonsProvider(
        StudentUnpaidLessonsParams(
          studentId: widget.dailyLesson.studentId,
          includePaid: false,
        ),
      ),
    );
  }

  Future<void> _pickPostponeDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final initial = _postponeDate ?? firstDate.add(const Duration(days: 1));
    final safeInitial = initial.isBefore(firstDate) ? firstDate : initial;
    final selected = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );
    if (selected != null && mounted) {
      setState(() => _postponeDate = selected);
    }
  }

  Future<void> _pickPostponeTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _postponeTime ??
          TimeOfDay.fromDateTime(widget.dailyLesson.startDateTime),
    );
    if (selected != null && mounted) {
      setState(() => _postponeTime = selected);
    }
  }

  Future<void> _submit() async {
    if (_action == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce ders durumunu seçin')),
      );
      return;
    }

    switch (_action!) {
      case _LessonCreateAction.done:
        await _saveDoneLesson();
      case _LessonCreateAction.notDone:
        await _saveMissed(requireSource: true, successMessage: 'Ders yapılmadı olarak işaretlendi');
      case _LessonCreateAction.cancelled:
        await _saveMissed(requireSource: false, successMessage: 'Ders iptal edildi');
      case _LessonCreateAction.postponed:
        await _savePostponed();
    }
  }

  Future<void> _saveDoneLesson() async {
    final feeExpected = int.tryParse(_feeExpectedController.text);

    if (feeExpected == null || feeExpected <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir beklenen ücret giriniz')),
      );
      return;
    }

    if (_hourlyRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğrenci bilgisi yüklenemedi')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      _formatController(_topicController);
      _formatController(_homeworkController);
      _formatController(_resourceController);
      _formatController(_noteController);

      final scheduleRepo = ref.read(scheduleRepoProvider);
      final occurrenceId = await _ensureOccurrenceId();
      final feePaidAmount = _isPaid ? feeExpected : 0;

      await scheduleRepo.createLessonForOccurrence(
        occurrenceId: occurrenceId,
        studentId: widget.dailyLesson.studentId,
        startDateTime: widget.dailyLesson.startDateTime,
        durationMin: widget.dailyLesson.durationMin,
        hourlyRate: _hourlyRate!,
        topic: _nullIfEmpty(_topicController.text),
        homework: _nullIfEmpty(_homeworkController.text),
        homeworkResource: _nullIfEmpty(_resourceController.text),
        feePaidAmount: feePaidAmount,
        note: _nullIfEmpty(_noteController.text),
      );

      if (_isPaid) {
        final now = DateTime.now();
        final paidAt = DateTime(now.year, now.month, now.day, 12);
        await ref.read(paymentsRepoProvider).createPaymentWithLessons(
              studentId: widget.dailyLesson.studentId,
              paidAt: paidAt,
              amount: feeExpected,
              method: _paymentMethod,
              selectedLessons: [
                SelectedLessonPayment(
                  lessonId: occurrenceId,
                  applyAmount: feeExpected,
                ),
              ],
            );
      }

      if (!mounted) return;
      _invalidateAfterChange();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPaid
                ? 'Ders kaydedildi ve ödeme alındı'
                : 'Ders yapıldı olarak kaydedildi',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        final errorMessage = e.toString().contains('zaten kayıt var')
            ? 'Bu ders için zaten kayıt var'
            : 'Hata: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _saveMissed({
    required bool requireSource,
    required String successMessage,
  }) async {
    final source = requireSource ? _missedSource : (_missedSource ?? 'TEACHER');
    if (requireSource && source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaynak seçiniz (öğretmen / öğrenci)')),
      );
      return;
    }

    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(StringsTr.reasonRequired)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final note = _extraNoteController.text.trim();
      final occurrenceId = await _ensureOccurrenceId();
      await ref.read(scheduleRepoProvider).markMissedWithReason(
            occurrenceId: occurrenceId,
            source: source!,
            reason: reason,
            note: note.isEmpty ? null : note,
          );

      if (!mounted) return;
      _invalidateAfterChange();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${StringsTr.errorPrefix}$e')),
        );
      }
    }
  }

  Future<void> _savePostponed() async {
    if (_postponeDate == null || _postponeTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erteleme tarih ve saatini seçiniz')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final occurrenceId = await _ensureOccurrenceId();
      final reason = _reasonController.text.trim();
      final success = await ref.read(scheduleRepoProvider).postponeByMove(
            oldOccurrenceId: occurrenceId,
            newDate: _postponeDate!,
            newStartTime: _postponeTime!,
            postponementReason: reason.isEmpty ? null : reason,
          );

      if (!mounted) return;

      if (!success) {
        setState(() => _isSaving = false);
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Çakışma Uyarısı'),
            content: const Text(
              'Seçilen tarih ve saatte başka bir ders bulunmaktadır. '
              'Lütfen farklı bir tarih veya saat seçiniz.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(StringsTr.ok),
              ),
            ],
          ),
        );
        return;
      }

      _invalidateAfterChange(alsoMonth: _postponeDate);
      final selDate = _postponeDate!;
      final selTime = _postponeTime!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ders ${selDate.day}.${selDate.month}.${selDate.year} '
            '${selTime.hour.toString().padLeft(2, '0')}:'
            '${selTime.minute.toString().padLeft(2, '0')} '
            'tarihine taşındı',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${StringsTr.errorPrefix}$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ders Kaydı')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders Kaydı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        widget.dailyLesson.studentName[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.dailyLesson.studentName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_dateTimeFormat.format(widget.dailyLesson.startDateTime)} - ${_formatDuration(widget.dailyLesson.durationMin)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.muted,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              StringsTr.changeStatus,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: StringsTr.done,
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  selected: _action == _LessonCreateAction.done,
                  onTap: () => _selectAction(_LessonCreateAction.done),
                ),
                _StatusChip(
                  label: StringsTr.missed,
                  icon: Icons.cancel_outlined,
                  color: AppColors.danger,
                  selected: _action == _LessonCreateAction.notDone,
                  onTap: () => _selectAction(_LessonCreateAction.notDone),
                ),
                _StatusChip(
                  label: StringsTr.postponed,
                  icon: Icons.schedule,
                  color: AppColors.warning,
                  selected: _action == _LessonCreateAction.postponed,
                  onTap: () => _selectAction(_LessonCreateAction.postponed),
                ),
                _StatusChip(
                  label: StringsTr.cancel,
                  icon: Icons.block,
                  color: AppColors.accent,
                  selected: _action == _LessonCreateAction.cancelled,
                  onTap: () => _selectAction(_LessonCreateAction.cancelled),
                ),
              ],
            ),
            if (_action != null) ...[
              const SizedBox(height: 24),
              _buildActionForm(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_submitLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _submitLabel {
    switch (_action) {
      case _LessonCreateAction.done:
        return StringsTr.save;
      case _LessonCreateAction.notDone:
        return 'Yapılmadı Kaydet';
      case _LessonCreateAction.postponed:
        return 'Ertelemeyi Kaydet';
      case _LessonCreateAction.cancelled:
        return 'İptali Kaydet';
      case null:
        return StringsTr.save;
    }
  }

  Widget _buildActionForm() {
    switch (_action!) {
      case _LessonCreateAction.done:
        return _buildDoneForm();
      case _LessonCreateAction.notDone:
        return _buildMissedForm(showSource: true);
      case _LessonCreateAction.cancelled:
        return _buildMissedForm(showSource: false);
      case _LessonCreateAction.postponed:
        return _buildPostponeForm();
    }
  }

  Widget _buildDoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LessonHomeworkFields(
          studentId: widget.dailyLesson.studentId,
          topicController: _topicController,
          homeworkController: _homeworkController,
          resourceController: _resourceController,
          onFormatTopic: () => _formatController(_topicController),
          onFormatHomework: () => _formatController(_homeworkController),
          onFormatResource: () => _formatController(_resourceController),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _feeExpectedController,
          decoration: const InputDecoration(
            labelText: 'Beklenen Ücret (TL)',
            border: OutlineInputBorder(),
            helperText: 'Otomatik hesaplanır, değiştirilebilir',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Text(
          'Ödeme durumu',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SourceChoice(
                label: 'Ödenmedi',
                selected: !_isPaid,
                onTap: () => setState(() => _isPaid = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SourceChoice(
                label: 'Ödendi',
                selected: _isPaid,
                onTap: () => setState(() => _isPaid = true),
              ),
            ),
          ],
        ),
        if (_isPaid) ...[
          const SizedBox(height: 16),
          Text(
            'Ödeme Şekli',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SourceChoice(
                  label: 'Nakit',
                  selected: _paymentMethod == 'cash',
                  onTap: () => setState(() => _paymentMethod = 'cash'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SourceChoice(
                  label: 'Havale',
                  selected: _paymentMethod == 'transfer',
                  onTap: () => setState(() => _paymentMethod = 'transfer'),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Not (Opsiyonel)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          onEditingComplete: () => _formatController(_noteController),
          onTapOutside: (_) => _formatController(_noteController),
        ),
      ],
    );
  }

  Widget _buildMissedForm({required bool showSource}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSource) ...[
          Text(
            StringsTr.sourceLabel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SourceChoice(
                  label: StringsTr.teacherSource,
                  selected: _missedSource == 'TEACHER',
                  onTap: () => setState(() => _missedSource = 'TEACHER'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SourceChoice(
                  label: StringsTr.studentSource,
                  selected: _missedSource == 'STUDENT',
                  onTap: () => setState(() => _missedSource = 'STUDENT'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: '${StringsTr.reasonLabel} *',
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _extraNoteController,
          decoration: InputDecoration(
            labelText: StringsTr.noteLabel,
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildPostponeForm() {
    final dateLabel = _postponeDate == null
        ? 'Tarih seç'
        : DateFormat('dd MMMM yyyy', 'tr_TR').format(_postponeDate!);
    final timeLabel = _postponeTime == null
        ? 'Saat seç'
        : '${_postponeTime!.hour.toString().padLeft(2, '0')}:'
            '${_postponeTime!.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today, color: AppColors.warning),
          title: const Text('Yeni tarih'),
          subtitle: Text(dateLabel),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickPostponeDate,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.access_time, color: AppColors.warning),
          title: const Text('Yeni saat'),
          subtitle: Text(timeLabel),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickPostponeTime,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          decoration: InputDecoration(
            labelText: '${StringsTr.reasonLabel} (isteğe bağlı)',
            border: const OutlineInputBorder(),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return mins > 0 ? '${hours}s ${mins}dk' : '${hours}s';
    }
    return '${mins}dk';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color.withValues(alpha: 0.18) : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SourceChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

final _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');
