import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/data/repositories/lessons_repo.dart';
import 'package:ozel_ders_takip/data/repositories/payments_repo.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final _dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
final _dateTimeFormat = DateFormat('dd MMMM yyyy HH:mm', 'tr_TR');

String _escapeHtml(String s) {
  return s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

/// Veliye WhatsApp ile gönderilmek üzere ödeme raporu oluşturur ve paylaşır.
class GuardianPaymentReportScreen extends ConsumerStatefulWidget {
  final String studentId;

  const GuardianPaymentReportScreen({
    super.key,
    required this.studentId,
  });

  @override
  ConsumerState<GuardianPaymentReportScreen> createState() =>
      _GuardianPaymentReportScreenState();
}

enum _ReportFilterType { all, unpaidOnly, dateRange }

class _GuardianPaymentReportScreenState
    extends ConsumerState<GuardianPaymentReportScreen> {
  _ReportFilterType _filterType = _ReportFilterType.all;
  DateTime _rangeFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _rangeTo = DateTime.now();
  bool _includePaidInRange = true;
  bool _includeUnpaidInRange = true;

  List<UnpaidLesson> _applyUnpaidFilter(
    List<UnpaidLesson> unpaid,
  ) {
    switch (_filterType) {
      case _ReportFilterType.all:
        return unpaid;
      case _ReportFilterType.unpaidOnly:
        return unpaid;
      case _ReportFilterType.dateRange:
        if (!_includeUnpaidInRange) return [];
        final from = DateTime(_rangeFrom.year, _rangeFrom.month, _rangeFrom.day);
        final to = DateTime(_rangeTo.year, _rangeTo.month, _rangeTo.day, 23, 59, 59);
        return unpaid.where((u) {
          final d = u.startDateTime;
          return !d.isBefore(from) && !d.isAfter(to);
        }).toList();
    }
  }

  List<StudentPayment> _applyPaymentsFilter(
    List<StudentPayment> payments,
  ) {
    switch (_filterType) {
      case _ReportFilterType.all:
        return payments;
      case _ReportFilterType.unpaidOnly:
        return [];
      case _ReportFilterType.dateRange:
        if (!_includePaidInRange) return [];
        final from = DateTime(_rangeFrom.year, _rangeFrom.month, _rangeFrom.day);
        final to = DateTime(_rangeTo.year, _rangeTo.month, _rangeTo.day, 23, 59, 59);
        return payments.where((p) {
          final d = p.paidAt;
          return !d.isBefore(from) && !d.isAfter(to);
        }).toList();
    }
  }

  String? _filterDescription() {
    switch (_filterType) {
      case _ReportFilterType.all:
        return null;
      case _ReportFilterType.unpaidOnly:
        return 'Sadece ödenecek dersler';
      case _ReportFilterType.dateRange:
        final parts = <String>[
          '${_dateFormat.format(_rangeFrom)} – ${_dateFormat.format(_rangeTo)}',
        ];
        if (_includeUnpaidInRange && _includePaidInRange) {
          parts.add('(ödenmiş + ödenmemiş)');
        } else if (_includeUnpaidInRange) {
          parts.add('(sadece ödenmemiş)');
        } else if (_includePaidInRange) {
          parts.add('(sadece ödenmiş)');
        }
        return parts.join(' ');
    }
  }

  /// HTML raporu (açılabilir dosya; ödenecek = kırmızı, ödenmiş = yeşil)
  String _buildReportHtml({
    required StudentPaymentSummary summary,
    required List<StudentPayment> payments,
    required List<UnpaidLesson> unpaid,
    String? filterDescription,
  }) {
    final sb = StringBuffer();
    sb.writeln('<!DOCTYPE html><html lang="tr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ödeme Raporu - ${_escapeHtml(summary.studentName)}</title></head><body style="font-family:sans-serif;padding:16px;max-width:480px;">');
    sb.writeln('<h2 style="color:#1a1a1a;">📋 Ödeme Raporu</h2>');
    sb.writeln('<p><strong>Öğrenci:</strong> ${_escapeHtml(summary.studentName)}<br><strong>Tarih:</strong> ${_escapeHtml(_dateFormat.format(DateTime.now()))}</p>');
    if (filterDescription != null && filterDescription.isNotEmpty) {
      sb.writeln('<p style="color:#666;font-size:0.9em;"><strong>Filtre:</strong> ${_escapeHtml(filterDescription)}</p>');
    }
    sb.writeln('<p><strong>Kalan borç:</strong> <span style="color:${summary.totalDue > 0 ? "#c62828" : "#2e7d32"};font-weight:bold;">${summary.totalDue} ₺</span></p>');
    if (summary.lastPaymentDate != null) {
      sb.writeln('<p><strong>Son ödeme:</strong> ${_escapeHtml(_dateFormat.format(summary.lastPaymentDate!))}</p>');
    }
    if (unpaid.isNotEmpty) {
      sb.writeln('<h3 style="color:#c62828;">⏳ Ödenecek dersler</h3><ul style="color:#c62828;">');
      for (final u in unpaid) {
        sb.writeln('<li>${_escapeHtml(_dateTimeFormat.format(u.startDateTime))} — ${u.remaining} ₺</li>');
      }
      sb.writeln('</ul>');
    }
    if (payments.isNotEmpty) {
      sb.writeln('<h3 style="color:#2e7d32;">✓ Ödenmiş dersler / Ödeme geçmişi</h3><ul style="color:#2e7d32;">');
      for (final p in payments) {
        final method = p.method == 'transfer' ? 'Havale' : 'Nakit';
        sb.writeln('<li>${_escapeHtml(_dateFormat.format(p.paidAt))} — ${p.amount} ₺ ($method)</li>');
      }
      sb.writeln('</ul>');
    }
    sb.writeln('</body></html>');
    return sb.toString();
  }

  Future<void> _shareReport() async {
    final summaryAsync = ref.read(studentPaymentSummaryProvider(widget.studentId));
    final paymentsAsync = ref.read(studentPaymentsProvider(widget.studentId));
    final unpaidAsync = ref.read(studentUnpaidLessonsProvider(
      StudentUnpaidLessonsParams(studentId: widget.studentId, includePaid: false),
    ));

    final summary = summaryAsync.value;
    if (summary == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Özet yüklenene kadar bekleyin')),
        );
      }
      return;
    }

    final paymentsRaw = paymentsAsync.value ?? [];
    final unpaidRaw = unpaidAsync.value ?? [];
    final payments = _applyPaymentsFilter(paymentsRaw);
    final unpaid = _applyUnpaidFilter(unpaidRaw);
    final filterDesc = _filterDescription();
    final html = _buildReportHtml(
      summary: summary,
      payments: payments,
      unpaid: unpaid,
      filterDescription: filterDesc,
    );

    try {
      final dir = await getTemporaryDirectory();
      final safeName = summary.studentName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final file = File('${dir.path}/odeme_raporu_$safeName.html');
      await file.writeAsString(html, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Ödeme Raporu - ${summary.studentName}',
        text: 'Öğrenci ödeme raporu ekteki HTML dosyasında. Dosyayı açarak görüntüleyebilirsiniz.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paylaşım hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(studentPaymentSummaryProvider(widget.studentId));
    final paymentsAsync = ref.watch(studentPaymentsProvider(widget.studentId));
    final unpaidAsync = ref.watch(studentUnpaidLessonsProvider(
      StudentUnpaidLessonsParams(studentId: widget.studentId, includePaid: false),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veliye Ödeme Raporu'),
      ),
      body: summaryAsync.when(
        data: (summary) {
          final paymentsRaw = paymentsAsync.value ?? [];
          final unpaidRaw = unpaidAsync.value ?? [];
          final payments = _applyPaymentsFilter(paymentsRaw);
          final unpaid = _applyUnpaidFilter(unpaidRaw);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filtre bölümü
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtreleme',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.muted,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_ReportFilterType>(
                      segments: const [
                        ButtonSegment(value: _ReportFilterType.all, label: Text('Tümü'), icon: Icon(Icons.list)),
                        ButtonSegment(value: _ReportFilterType.unpaidOnly, label: Text('Ödenecek'), icon: Icon(Icons.pending)),
                        ButtonSegment(value: _ReportFilterType.dateRange, label: Text('Tarih aralığı'), icon: Icon(Icons.date_range)),
                      ],
                      selected: {_filterType},
                      onSelectionChanged: (Set<_ReportFilterType> s) {
                        setState(() => _filterType = s.first);
                      },
                    ),
                    if (_filterType == _ReportFilterType.dateRange) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _rangeFrom,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  locale: const Locale('tr', 'TR'),
                                );
                                if (d != null) setState(() => _rangeFrom = d);
                              },
                              child: Text(_dateFormat.format(_rangeFrom)),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('–'),
                          ),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _rangeTo,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  locale: const Locale('tr', 'TR'),
                                );
                                if (d != null) setState(() => _rangeTo = d);
                              },
                              child: Text(_dateFormat.format(_rangeTo)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _includeUnpaidInRange,
                        onChanged: (v) => setState(() => _includeUnpaidInRange = v ?? true),
                        title: const Text('Ödenmemiş dersleri dahil et'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                      CheckboxListTile(
                        value: _includePaidInRange,
                        onChanged: (v) => setState(() => _includePaidInRange = v ?? true),
                        title: const Text('Ödenmiş dersleri dahil et'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ödeme Raporu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Öğrenci: ${summary.studentName}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Text(
                        'Tarih: ${_dateFormat.format(DateTime.now())}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                            ),
                      ),
                      if (_filterDescription() != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Filtre: ${_filterDescription()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        'Kalan borç: ${summary.totalDue} ₺',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: summary.totalDue > 0
                                  ? AppColors.danger
                                  : summary.totalDue < 0
                                      ? AppColors.success
                                      : AppColors.muted,
                            ),
                      ),
                      if (summary.lastPaymentDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Son ödeme: ${_dateFormat.format(summary.lastPaymentDate!)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                      ],
                      if (unpaid.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Ödenecek dersler',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                        ),
                        const SizedBox(height: 6),
                        ...unpaid.map((u) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                '• ${_dateTimeFormat.format(u.startDateTime)} — ${u.remaining} ₺',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.danger,
                                    ),
                              ),
                            )),
                      ],
                      if (payments.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Ödenmiş dersler / Ödeme geçmişi',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                        ),
                        const SizedBox(height: 6),
                        ...payments.map((p) {
                          final method = p.method == 'transfer' ? 'Havale' : 'Nakit';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${_dateFormat.format(p.paidAt)} — ${p.amount} ₺ ($method)',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.success,
                                  ),
                            ),
                          );
                        }),
                      ],
                      if (unpaid.isEmpty && payments.isEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _filterType == _ReportFilterType.unpaidOnly
                              ? 'Ödenecek ders bulunmuyor.'
                              : 'Bu filtreye uyan kayıt yok.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _shareReport,
                  icon: const Icon(Icons.share),
                  label: const Text('WhatsApp ile Paylaş'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Rapor yüklenemedi: $err'),
          ),
        ),
      ),
    );
  }
}
