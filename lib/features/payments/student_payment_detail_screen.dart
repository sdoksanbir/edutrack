import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/data/providers/repositories_provider.dart';
import 'package:ozel_ders_takip/data/repositories/payments_repo.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/widgets/detail_info_panel.dart';

final _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');
final _dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

/// Öğrenci bazlı ödeme detay ekranı
class StudentPaymentDetailScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentPaymentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<StudentPaymentDetailScreen> createState() =>
      _StudentPaymentDetailScreenState();
}

class _StudentPaymentDetailScreenState
    extends ConsumerState<StudentPaymentDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _showPaidLessons = false; // Toggle: ödenmiş dersleri göster
  final Map<String, bool> _selectedLessons = {}; // lessonId -> isSelected
  final Map<String, int> _applyAmounts = {}; // lessonId -> applyAmount
  bool _isProcessing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentSummaryAsync = ref.watch(
      studentPaymentSummaryProvider(widget.studentId),
    );
    final unpaidLessonsAsync = ref.watch(
      studentUnpaidLessonsProvider(
        StudentUnpaidLessonsParams(
          studentId: widget.studentId,
          includePaid: _showPaidLessons,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Veliye ödeme raporu (WhatsApp)',
            onPressed: () => context.push('${AppRouter.payments}/${widget.studentId}/report'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dersler'),
            Tab(text: 'Ödeme Geçmişi'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Özet kartları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: paymentSummaryAsync.when(
              data: (summary) => Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Toplam Hakediş',
                      '${summary.totalExpected} ₺',
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Toplam Tahsilat',
                      '${summary.totalPaid} ₺',
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Kalan',
                      '${summary.totalDue} ₺',
                      summary.totalDue > 0
                          ? AppColors.danger
                          : summary.totalDue < 0
                              ? AppColors.primary
                              : AppColors.muted,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Hata: $error'),
                ),
              ),
            ),
          ),

          // Tab içeriği
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Dersler sekmesi
                _buildLessonsTab(context, unpaidLessonsAsync),
                // Ödeme geçmişi sekmesi
                _buildPaymentHistoryTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, UnpaidLesson lesson) {
    final isFullyPaid = lesson.remaining <= 0;
    final isSelected = _selectedLessons[lesson.lessonId] ?? false;
    final applyAmount = _applyAmounts[lesson.lessonId] ?? lesson.remaining;

    // Ödeme durumuna göre renk belirle
    Color? cardColor;
    if (isSelected) {
      cardColor = AppColors.primarySoft;
    } else if (lesson.remaining == 0) {
      cardColor = AppColors.successSoft;
    } else if (lesson.paidSoFar > 0) {
      cardColor = AppColors.warningSoft;
    } else {
      cardColor = AppColors.dangerSoft;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardColor,
      child: InkWell(
        onTap: () {
          if (isFullyPaid || lesson.paidSoFar > 0) {
            _showLessonPaymentDetailDialog(context, lesson);
            return;
          }
          // Ödenmemiş: seçimi aç/kapa
          setState(() {
            final next = !isSelected;
            if (next) {
              _selectedLessons[lesson.lessonId] = true;
              _applyAmounts[lesson.lessonId] = lesson.remaining;
            } else {
              _selectedLessons[lesson.lessonId] = false;
              _applyAmounts.remove(lesson.lessonId);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Tam ödenmişse checkbox yok, "Ödendi" badge; değilse checkbox
              if (isFullyPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(230),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ödendi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedLessons[lesson.lessonId] = true;
                        _applyAmounts[lesson.lessonId] = lesson.remaining;
                      } else {
                        _selectedLessons[lesson.lessonId] = false;
                        _applyAmounts.remove(lesson.lessonId);
                      }
                    });
                  },
                ),

              // Ders bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateTimeFormat.format(lesson.startDateTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildInfoChip('Beklenen', '${lesson.feeExpected} ₺', AppColors.primary),
                        _buildInfoChip('Ödenen', '${lesson.paidSoFar} ₺', AppColors.success),
                        _buildInfoChip('Kalan', '${lesson.remaining} ₺', 
                            lesson.remaining > 0 ? AppColors.danger : AppColors.muted),
                      ],
                    ),
                    if (isSelected && !isFullyPaid) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Uygulanan tutar: $applyAmount ₺',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isFullyPaid || lesson.paidSoFar > 0)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _buildLessonsTab(
    BuildContext context,
    AsyncValue<List<UnpaidLesson>> unpaidLessonsAsync,
  ) {
    return Column(
      children: [
        // Toggle: Ödenmiş dersleri göster
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            child: SwitchListTile(
              title: const Text('Ödenmiş dersleri göster'),
              value: _showPaidLessons,
              onChanged: (value) {
                setState(() {
                  _showPaidLessons = value;
                  // Toggle değişince seçimleri temizle
                  _selectedLessons.clear();
                  _applyAmounts.clear();
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Ders listesi
        Expanded(
          child: unpaidLessonsAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) {
                return Center(
                  child: Text(
                    _showPaidLessons
                        ? 'Henüz ders kaydı yok'
                        : 'Ödenmemiş ders yok',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return _buildLessonCard(context, lesson);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Hata: $error'),
            ),
          ),
        ),

        // Ödeme Al butonu: seçilebilir (remaining > 0) ders yoksa disabled
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (context) {
              final lessons = unpaidLessonsAsync.hasValue ? unpaidLessonsAsync.value! : <UnpaidLesson>[];
              final hasSelectable = lessons.any(
                (l) => (_selectedLessons[l.lessonId] ?? false) && l.remaining > 0,
              );
              final isDisabled = _isProcessing || !hasSelectable;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isDisabled ? null : _showPaymentDialog,
                  icon: const Icon(Icons.payment),
                  label: Text(
                    _selectedLessons.isEmpty
                        ? 'Ders Seçin'
                        : hasSelectable
                            ? 'Ödeme Al (${_getSelectableCount(lessons)} ders)'
                            : 'Seçili dersler zaten ödenmiş',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Seçili ve ödenmemiş (remaining > 0) ders sayısı
  int _getSelectableCount(List<UnpaidLesson> lessons) {
    return lessons
        .where((l) => (_selectedLessons[l.lessonId] ?? false) && l.remaining > 0)
        .length;
  }

  Widget _buildPaymentHistoryTab(BuildContext context) {
    final paymentsAsync = ref.watch(
      studentPaymentsProvider(widget.studentId),
    );

    return paymentsAsync.when(
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(
            child: Text('Henüz ödeme kaydı yok'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final payment = payments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  payment.method == 'cash' ? Icons.money : Icons.account_balance,
                  color: payment.method == 'cash' ? AppColors.success : AppColors.primary,
                ),
                title: Text(
                  _dateFormat.format(payment.paidAt),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${payment.method == 'cash' ? 'Nakit' : 'Havale'} - ${payment.amount} ₺',
                    ),
                    if (payment.note != null && payment.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        payment.note!,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'cancel') {
                      await _cancelPayment(context, payment);
                    } else if (value == 'detail') {
                      _showPaymentDetailDialog(context, payment);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Detay'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined, size: 20, color: AppColors.danger),
                          SizedBox(width: 8),
                          Text('Ödemeyi İptal Et', style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _showPaymentDetailDialog(context, payment);
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Future<void> _showLessonPaymentDetailDialog(
    BuildContext context,
    UnpaidLesson lesson,
  ) async {
    final paymentsRepo = ref.read(paymentsRepoProvider);
    final lessonPayments =
        await paymentsRepo.watchLessonPayments(lesson.lessonId).first;

    if (!context.mounted) return;

    final summaryItems = <DetailInfoItem>[
      DetailInfoItem(
        label: 'Ders Tarihi',
        value: _dateTimeFormat.format(lesson.startDateTime),
      ),
      DetailInfoItem(
        label: 'Beklenen',
        value: '${lesson.feeExpected} ₺',
      ),
      DetailInfoItem(
        label: 'Ödenen',
        value: '${lesson.paidSoFar} ₺',
        valueColor: AppColors.success,
      ),
      DetailInfoItem(
        label: 'Kalan',
        value: '${lesson.remaining} ₺',
        valueColor:
            lesson.remaining > 0 ? AppColors.danger : AppColors.success,
      ),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const DetailDialogTitle(
          icon: Icons.payments_outlined,
          iconColor: AppColors.success,
          title: 'Ders Ödeme Ayrıntısı',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailInfoPanel(items: summaryItems),
                const SizedBox(height: 20),
                const DetailSectionLabel('Bu derse uygulanan ödemeler'),
                if (lessonPayments.isEmpty)
                  Text(
                    'Bu derse bağlı ödeme kaydı bulunamadı.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  ...lessonPayments.map((info) {
                    final methodLabel =
                        info.method == 'cash' ? 'Nakit' : 'Havale';
                    final isCash = info.method == 'cash';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: AppColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          isCash ? Icons.money : Icons.account_balance,
                          color: isCash ? AppColors.success : AppColors.primary,
                        ),
                        title: Text(_dateFormat.format(info.paidAt)),
                        subtitle: Text(methodLabel),
                        trailing: Text(
                          '${info.appliedAmount} ₺',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          Navigator.pop(dialogContext);
                          final all = await paymentsRepo
                              .watchStudentPayments(widget.studentId)
                              .first;
                          StudentPayment? full;
                          for (final p in all) {
                            if (p.paymentId == info.paymentId) {
                              full = p;
                              break;
                            }
                          }
                          if (!context.mounted || full == null) return;
                          await _showPaymentDetailDialog(context, full);
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kapat'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDetailDialog(
    BuildContext context,
    StudentPayment payment,
  ) async {
    final paymentsRepo = ref.read(paymentsRepoProvider);
    final details = await paymentsRepo.getPaymentDetails(payment.paymentId);

    if (!context.mounted) return;

    final methodLabel = payment.method == 'cash' ? 'Nakit' : 'Havale';
    final isCash = payment.method == 'cash';

    final summaryItems = <DetailInfoItem>[
      DetailInfoItem(
        label: 'Tarih',
        value: _dateFormat.format(payment.paidAt),
      ),
      DetailInfoItem(
        label: 'Yöntem',
        value: methodLabel,
        valueColor: isCash ? AppColors.success : AppColors.primary,
        trailing: Icon(
          isCash ? Icons.money : Icons.account_balance,
          size: 20,
          color: isCash ? AppColors.success : AppColors.primary,
        ),
      ),
      DetailInfoItem(
        label: 'Toplam Tutar',
        value: '${payment.amount} ₺',
        valueColor: AppColors.success,
      ),
      if (payment.note != null && payment.note!.isNotEmpty)
        DetailInfoItem(
          label: 'Not',
          value: payment.note!,
        ),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const DetailDialogTitle(
          icon: Icons.receipt_long_outlined,
          iconColor: AppColors.primary,
          title: 'Ödeme Detayı',
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailInfoPanel(items: summaryItems),
                const SizedBox(height: 20),
                const DetailSectionLabel('Uygulanan dersler'),
                if (details.isEmpty)
                  Text(
                    'Bu ödemeye bağlı ders bulunamadı.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  ...details.map((detail) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: AppColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          _dateFormat.format(detail.lessonDate),
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          '${detail.appliedAmount} ₺',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Kapat'),
            ),
          ),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: dialogContext,
                builder: (context) => AlertDialog(
                  title: const Text('Ödemeyi Tamamen Sil'),
                  content: const Text(
                    'Bu ödeme kaydını tamamen silmek istediğinize emin misiniz?\n\n'
                    'Tüm uygulamalar silinecektir.\n\n'
                    'Bu işlem geri alınamaz.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  final paymentsRepo = ref.read(paymentsRepoProvider);
                  await paymentsRepo.deletePayment(paymentId: payment.paymentId);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ödeme kaydı silindi')),
                    );
                  }
                  // Dialog/route kapandıktan sonra invalidate ertelenir (_dependents.isEmpty önlemi)
                  final refPay = ref;
                  final studentIdPay = widget.studentId;
                  final showPaid = _showPaidLessons;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    refPay.invalidate(studentPaymentSummaryProvider(studentIdPay));
                    refPay.invalidate(globalPaymentSummaryProvider);
                    refPay.invalidate(studentPaymentSummariesProvider);
                    refPay.invalidate(studentPaymentsProvider(studentIdPay));
                    refPay.invalidate(studentUnpaidLessonsProvider(
                      StudentUnpaidLessonsParams(studentId: studentIdPay, includePaid: false),
                    ));
                    refPay.invalidate(studentUnpaidLessonsProvider(
                      StudentUnpaidLessonsParams(studentId: studentIdPay, includePaid: true),
                    ));
                  });
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Hata: $e')),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Ödemeyi Tamamen Sil'),
          ),
        ],
      ),
    );
  }


  int _getSelectedCount() {
    return _selectedLessons.values.where((v) => v).length;
  }

  Future<void> _cancelPayment(BuildContext context, StudentPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ödemeyi İptal Et'),
        content: const Text(
          'Bu ödemeyi iptal etmek istediğinize emin misiniz?\n\n'
          'Ödeme kaydı silinecek ve dersler "ödenmemiş" olarak işaretlenecektir.\n\n'
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('İptal Et'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final paymentsRepo = ref.read(paymentsRepoProvider);
        await paymentsRepo.deletePayment(paymentId: payment.paymentId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ödeme iptal edildi')),
          );
        }
        final refPay = ref;
        final studentIdPay = widget.studentId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          refPay.invalidate(studentPaymentSummaryProvider(studentIdPay));
          refPay.invalidate(globalPaymentSummaryProvider);
          refPay.invalidate(studentPaymentSummariesProvider);
          refPay.invalidate(studentPaymentsProvider(studentIdPay));
          refPay.invalidate(studentUnpaidLessonsProvider(
            StudentUnpaidLessonsParams(studentId: studentIdPay, includePaid: false),
          ));
          refPay.invalidate(studentUnpaidLessonsProvider(
            StudentUnpaidLessonsParams(studentId: studentIdPay, includePaid: true),
          ));
        });
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  Future<void> _showPaymentDialog() async {
    final selectedLessons = _selectedLessons.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedLessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir ders seçin'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Toplam applyAmount hesapla
    final totalApplied = selectedLessons.fold<int>(
      0,
      (sum, lessonId) => sum + (_applyAmounts[lessonId] ?? 0),
    );

    DateTime selectedDate = DateTime.now();
    int paymentAmount = totalApplied;
    String paymentMethod = 'cash';
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ödeme Al',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Ödeme tarihi (sadece tarih, saat yok)
                ListTile(
                  title: const Text('Ödeme Tarihi'),
                  subtitle: Text(
                    _dateFormat.format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      locale: const Locale('tr', 'TR'),
                    );
                    if (date != null) {
                      setModalState(() {
                        // Sadece tarih, saat 12:00:00 olarak sabitlenir (timezone sorunlarını önlemek için)
                        selectedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          12,
                          0,
                          0,
                        );
                      });
                    }
                  },
                ),

                const SizedBox(height: 8),

                // Ödeme miktarı
                TextField(
                  controller: TextEditingController(
                    text: paymentAmount.toString(),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Ödeme Miktarı (₺)',
                    prefixIcon: Icon(Icons.payment),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    paymentAmount = int.tryParse(value) ?? 0;
                  },
                ),

                const SizedBox(height: 16),

                // Ödeme şekli
                const Text(
                  'Ödeme Şekli',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Nakit'),
                        value: 'cash',
                        groupValue: paymentMethod,
                        onChanged: (value) {
                          setModalState(() {
                            paymentMethod = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Havale'),
                        value: 'transfer',
                        groupValue: paymentMethod,
                        onChanged: (value) {
                          setModalState(() {
                            paymentMethod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Not
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Not (Opsiyonel)',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Butonlar
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Kaydet'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!mounted) return;
    if (result == true) {
      await _createPayment(
        paidAt: selectedDate,
        amount: paymentAmount,
        method: paymentMethod,
        note: noteController.text.trim().isEmpty 
            ? null 
            : noteController.text.trim(),
      );
    }
  }

  Future<void> _createPayment({
    required DateTime paidAt,
    required int amount,
    required String method,
    String? note,
  }) async {
    // Seçili dersleri SelectedLessonPayment listesine çevir
    final selectedLessons = _selectedLessons.entries
        .where((e) => e.value)
        .map((e) => SelectedLessonPayment(
              lessonId: e.key,
              applyAmount: _applyAmounts[e.key] ?? 0,
            ))
        .toList();

    if (selectedLessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir ders seçin'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final paymentsRepo = ref.read(paymentsRepoProvider);
      await paymentsRepo.createPaymentWithLessons(
        studentId: widget.studentId,
        paidAt: paidAt,
        amount: amount,
        method: method,
        note: note,
        selectedLessons: selectedLessons,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ödeme kaydedildi'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {
          _selectedLessons.clear();
          _applyAmounts.clear();
        });
        // Modal kapandıktan sonra invalidate ertelenir (_dependents.isEmpty önlemi)
        final refPay = ref;
        final studentIdPay = widget.studentId;
        final showPaid = _showPaidLessons;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          refPay.invalidate(studentPaymentSummaryProvider(studentIdPay));
          refPay.invalidate(studentUnpaidLessonsProvider(
            StudentUnpaidLessonsParams(studentId: studentIdPay, includePaid: showPaid),
          ));
          refPay.invalidate(globalPaymentSummaryProvider);
          refPay.invalidate(studentPaymentSummariesProvider);
        });
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('zaten ödenmiş')
            ? 'Seçili dersler zaten ödenmiş.'
            : 'Hata: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

