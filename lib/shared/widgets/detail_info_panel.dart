import 'package:flutter/material.dart';
import 'package:ozel_ders_takip/shared/theme/app_theme.dart';

/// Ayrıntı diyalog başlığı — ikon + kalın başlık.
class DetailDialogTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const DetailDialogTitle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bölüm başlığı (panel üstü etiket).
class DetailSectionLabel extends StatelessWidget {
  final String text;

  const DetailSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Etiket + değer satırı (ayrıntı pencereleri için).
class DetailInfoItem {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const DetailInfoItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });
}

/// Ayırıcılı bilgi paneli — her alan arasında çizgi.
class DetailInfoPanel extends StatelessWidget {
  final List<DetailInfoItem> items;

  const DetailInfoPanel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: _DetailInfoRow(item: items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  final DetailInfoItem item;

  const _DetailInfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                item.value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: item.valueColor ?? AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
            ),
            if (item.trailing != null) ...[
              const SizedBox(width: 8),
              item.trailing!,
            ],
          ],
        ),
      ],
    );
  }
}

/// Durum rozeti (kaynak / sebep türü vb.).
class DetailStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const DetailStatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
