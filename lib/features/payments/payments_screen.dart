import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ozel_ders_takip/app/router.dart';
import 'package:ozel_ders_takip/data/providers/payment_providers.dart';
import 'package:ozel_ders_takip/data/repositories/lessons_repo.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';
import 'package:ozel_ders_takip/shared/i18n/strings_tr.dart';

final _dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(StringsTr.payments),
      ),
      body: _buildPaymentsTab(),
    );
  }

  Widget _buildPaymentsTab() {
    final globalSummaryAsync = ref.watch(globalPaymentSummaryProvider);
    final studentSummariesAsync = ref.watch(studentPaymentSummariesProvider);

    return Column(
      children: [
        // Global özet kartları
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: globalSummaryAsync.when(
            data: (summary) => Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    StringsTr.totalReceived,
                    '${summary.totalPaid} ₺',
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    StringsTr.totalDue,
                    '${summary.totalDue} ₺',
                    summary.totalDue > 0
                        ? AppColors.danger
                        : summary.totalDue < 0
                            ? AppColors.primary
                            : AppColors.muted,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    StringsTr.totalExpected,
                    '${summary.totalExpected} ₺',
                    AppColors.primary,
                    Icons.calculate,
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
                child: Text('${StringsTr.errorPrefix}$error'),
              ),
            ),
          ),
        ),

        // Arama kutusu (theme'den beslenir)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: StringsTr.searchStudentHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
        ),

        const SizedBox(height: 8),

        // Öğrenci listesi
        Expanded(
          child: studentSummariesAsync.when(
            data: (summaries) {
              // Arama filtresi
              final filteredSummaries = _searchQuery.isEmpty
                  ? summaries
                  : summaries
                      .where((s) =>
                          s.studentName.toLowerCase().contains(_searchQuery))
                      .toList();

              // Sıralama: totalDue DESC
              filteredSummaries.sort((a, b) => b.totalDue.compareTo(a.totalDue));

              if (filteredSummaries.isEmpty) {
                return Center(
                  child: Text(
                    _searchQuery.isEmpty
                        ? StringsTr.noPaymentRecords
                        : StringsTr.noSearchResults,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredSummaries.length,
                itemBuilder: (context, index) {
                  final summary = filteredSummaries[index];
                  return _buildStudentPaymentCard(context, summary);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('${StringsTr.errorPrefix}$error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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

  Widget _buildStudentPaymentCard(
    BuildContext context,
    StudentPaymentSummary summary,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          summary.studentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Kalan Borç: ',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${summary.totalDue} ₺',
                  style: TextStyle(
                    color: summary.totalDue == 0
                        ? AppColors.muted
                        : summary.totalDue > 0
                            ? AppColors.danger
                            : AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Toplam Tahsilat: ',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${summary.totalPaid} ₺',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (summary.lastPaymentDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Son ödeme: ${_dateFormat.format(summary.lastPaymentDate!)}',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: summary.totalDue > 0
            ? const Icon(Icons.warning, color: AppColors.danger)
            : summary.totalDue < 0
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.check_circle_outline, color: AppColors.muted),
        onTap: () {
          // Ödeme detay ekranına git
          context.push(
            '${AppRouter.payments}/${summary.studentId}',
          );
        },
      ),
    );
  }
}
