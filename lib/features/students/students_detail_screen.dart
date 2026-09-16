import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/local/app_database.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_book_resource_dialog.dart';
import 'package:ozel_ders_takip/features/students/widgets/student_edit_dialog.dart';
import 'package:ozel_ders_takip/data/repositories/schedule_repo.dart';
import 'package:ozel_ders_takip/shared/constants/student_grade_levels.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/utils/phone_format.dart';

final _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');

class StudentsDetailScreen extends ConsumerWidget {
  final Student student;

  const StudentsDetailScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Öğrenci bilgisini stream olarak izle
    final studentsRepo = ref.read(studentsRepoProvider);
    final studentStream = studentsRepo.watchStudentById(student.id);

    return StreamBuilder<Student?>(
      stream: studentStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(student.fullName)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final currentStudent = snapshot.data ?? student;

        return _StudentsDetailContent(
          student: currentStudent,
          ref: ref,
        );
      },
    );
  }
}

class _StudentsDetailContent extends ConsumerStatefulWidget {
  final Student student;

  const _StudentsDetailContent({
    required this.student,
    required this.ref,
  });

  final WidgetRef ref;

  @override
  ConsumerState<_StudentsDetailContent> createState() =>
      _StudentsDetailContentState();
}

class _StudentsDetailContentState
    extends ConsumerState<_StudentsDetailContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.fullName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Center(
              child: Transform.scale(
                scale: 0.72,
                child: Switch(
                  value: widget.student.isActive,
                  onChanged: _toggleStudentActive,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  thumbColor: WidgetStateProperty.all(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.success;
                    }
                    return AppColors.danger;
                  }),
                  trackOutlineColor:
                      WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Haftalık program',
            onPressed: widget.student.isActive
                ? () {
                    context.push(
                      '${AppRouter.students}/${widget.student.id}/schedule',
                      extra: widget.student.id,
                    );
                  }
                : null,
            icon: SizedBox(
              width: 26,
              height: 26,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: widget.student.isActive
                        ? AppColors.primary
                        : AppColors.muted,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_circle,
                        size: 14,
                        color: widget.student.isActive
                            ? AppColors.success
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                showStudentEditDialog(context, ref, widget.student),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Öğrenci Bilgileri
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.45),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.student.fullName.trim().isEmpty
                              ? '?'
                              : widget.student.fullName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.student.fullName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Avatar (40) + boşluk (12) ile isim solu; biraz daha iç
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.student.phone != null &&
                            widget.student.phone!.trim().isNotEmpty) ...[
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            value: formatTurkishPhoneDisplay(widget.student.phone!),
                          ),
                          const SizedBox(height: 10),
                        ],
                        _buildInfoRow(
                          icon: Icons.payments_outlined,
                          value: '${widget.student.hourlyRate} ₺/saat',
                        ),
                        if (widget.student.gradeLevel != null &&
                            widget.student.gradeLevel!.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            icon: Icons.school_outlined,
                            value: StudentGradeLevels.labelFor(
                                  widget.student.gradeLevel,
                                ) ??
                                widget.student.gradeLevel!,
                          ),
                        ],
                        if (widget.student.notes != null &&
                            widget.student.notes!.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            icon: Icons.sticky_note_2_outlined,
                            value: widget.student.notes!,
                            multiline: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kaynaklar
            _buildCollapseCard(
              title: StringsTr.bookResourceLabel,
              icon: Icons.menu_book_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookResourceSection(
                    context,
                    title: StringsTr.bookResourceTopicLabel,
                    icon: Icons.menu_book,
                    accent: AppColors.primary,
                    kind: StudentBookResourceKind.topic,
                    raw: widget.student.bookResource,
                  ),
                  const SizedBox(height: 14),
                  _buildBookResourceSection(
                    context,
                    title: StringsTr.bookResourcePracticeLabel,
                    icon: Icons.quiz_outlined,
                    accent: AppColors.warning,
                    kind: StudentBookResourceKind.practice,
                    raw: widget.student.bookResourcePractice,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Veli Bilgileri
            _buildCollapseCard(
              title: StringsTr.guardianSectionTitle,
              icon: Icons.family_restroom_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 20, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (widget.student.guardianFullName ?? '').trim().isEmpty
                              ? StringsTr.notEntered
                              : widget.student.guardianFullName!,
                          style: TextStyle(
                            color: (widget.student.guardianFullName ?? '')
                                    .trim()
                                    .isEmpty
                                ? AppColors.muted
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 20, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (widget.student.guardianPhone ?? '').trim().isEmpty
                              ? StringsTr.notEntered
                              : formatTurkishPhoneDisplay(
                                  widget.student.guardianPhone!,
                                ),
                          style: TextStyle(
                            color: (widget.student.guardianPhone ?? '')
                                    .trim()
                                    .isEmpty
                                ? AppColors.muted
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ödeme Özeti
            _buildCollapseCard(
              title: 'Ödeme Özeti',
              icon: Icons.payments_outlined,
              child: widget.ref
                  .watch(studentPaymentSummaryProvider(widget.student.id))
                  .when(
                    data: (summary) => Column(
                      children: [
                        _buildSummaryRow(
                          'Toplam Beklenen',
                          '${summary.totalExpected} ₺',
                          AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Toplam Ödenen',
                          '${summary.totalPaid} ₺',
                          AppColors.success,
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Kalan Borç',
                          '${summary.totalDue} ₺',
                          summary.totalDue > 0
                              ? AppColors.danger
                              : summary.totalDue < 0
                                  ? AppColors.primary
                                  : AppColors.muted,
                        ),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Hata: $error'),
                  ),
            ),
            const SizedBox(height: 16),

            // Geçmiş Dersler
            _buildCollapseCard(
              title: 'Geçmiş Dersler',
              icon: Icons.history,
              child: StreamBuilder<List<SessionOccurrenceWithStudent>>(
                stream: widget.ref.read(scheduleRepoProvider).watchDoneOccurrences(
                  studentId: widget.student.id,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Hata: ${snapshot.error}');
                  }

                  final occurrences = snapshot.data ?? [];
                  final studentOccurrences = occurrences
                    ..sort((a, b) {
                      final dateA = DateTime.parse(a.occurrence.date);
                      final dateB = DateTime.parse(b.occurrence.date);
                      return dateB.compareTo(dateA);
                    });

                  if (studentOccurrences.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Henüz tamamlanmış ders yok',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: studentOccurrences.length,
                    itemBuilder: (context, index) {
                      final item = studentOccurrences[index];
                      final dateParts = item.occurrence.date.split('-');
                      final timeParts = item.occurrence.startTime.split(':');
                      final dateTime = DateTime(
                        int.parse(dateParts[0]),
                        int.parse(dateParts[1]),
                        int.parse(dateParts[2]),
                        int.parse(timeParts[0]),
                        int.parse(timeParts[1]),
                      );

                      final feeExpected =
                          ((item.student.hourlyRate * item.occurrence.durationMin) /
                                  60)
                              .round();
                      final isPaid = item.occurrence.paymentId != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isPaid
                            ? AppColors.successSoft
                            : AppColors.dangerSoft,
                        child: ListTile(
                          title: Text(
                            _dateTimeFormat.format(dateTime),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Süre: ${item.occurrence.durationMin} dakika',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPaid
                                    ? 'Ödendi: $feeExpected ₺'
                                    : 'Ödenmedi: $feeExpected ₺',
                                style: TextStyle(
                                  color: isPaid
                                      ? AppColors.success
                                      : AppColors.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            isPaid ? Icons.check_circle : Icons.pending,
                            color: isPaid
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: const Icon(
                  Icons.task_alt_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
                title: const Text(
                  StringsTr.completedTopicsTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  StringsTr.completedTopicsSubtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                ),
                onTap: () {
                  context.push(
                    '${AppRouter.students}/${widget.student.id}/completed-topics',
                    extra: widget.student,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String value,
    bool multiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.textPrimary),
        const SizedBox(width: 4),
        Text(
          ':',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.3,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapseCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Icon(icon, color: AppColors.primary, size: 20),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          children: [child],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleStudentActive(bool isActive) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isActive ? 'Öğrenciyi Aktif Et' : 'Öğrenciyi Pasif Et'),
        content: Text(
          isActive
              ? 'Bu öğrenciyi aktif hale getirmek istediğinizden emin misiniz?'
              : 'Bu öğrenciyi pasif yapmak istediğinizden emin misiniz?\n\nİlerideki tüm planlanmış dersler kaldırılacaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? AppColors.success : AppColors.warning,
            ),
            child: Text(isActive ? 'Aktif Et' : 'Pasif Et'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final studentsRepo = widget.ref.read(studentsRepoProvider);
      await studentsRepo.setStudentActive(
        id: widget.student.id,
        isActive: isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isActive
                ? 'Öğrenci aktif hale getirildi'
                : 'Öğrenci pasif hale getirildi - İlerideki dersler kaldırıldı'),
            backgroundColor: isActive ? AppColors.success : AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Widget _buildBookResourceSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accent,
    required StudentBookResourceKind kind,
    required String? raw,
  }) {
    final books = parseStudentBookResources(raw);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: accent,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: accent, size: 22),
              tooltip: 'Ekle',
              visualDensity: VisualDensity.compact,
              onPressed: () => showAddBookResourceDialog(
                context,
                ref,
                widget.student,
                initialKind: kind,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (books.isEmpty)
          Text(
            StringsTr.notEntered,
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          )
        else
          ...books.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => showEditBookResourceDialog(
                    context,
                    ref,
                    widget.student,
                    kind: kind,
                    currentName: book,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 18, color: accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            book,
                            style: const TextStyle(height: 1.3),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.visibility_outlined,
                            size: 18,
                            color: accent,
                          ),
                          tooltip: 'Görüntüle / Düzenle',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => showEditBookResourceDialog(
                            context,
                            ref,
                            widget.student,
                            kind: kind,
                            currentName: book,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.muted,
                          ),
                          tooltip: StringsTr.delete,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => removeStudentBookResource(
                            context,
                            ref,
                            widget.student,
                            book,
                            kind,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
