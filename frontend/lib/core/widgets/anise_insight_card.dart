import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Item data untuk AniseInsightCard
class AniseInsightItemData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const AniseInsightItemData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// Standarisasi Baku Card Insight Metrik (digunakan di Penugasan Guru, Tugas Siswa, dll)
class AniseInsightCard extends StatelessWidget {
  final List<AniseInsightItemData> items;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AniseInsightCard({
    super.key,
    required this.items,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(
              child: _buildItem(context, items[i]),
            ),
            if (i < items.length - 1)
              Container(
                width: 1,
                height: 32.h(context),
                color: AppColors.outline.withValues(alpha: 0.15),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, AniseInsightItemData item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color, size: 16.w(context)),
            SizedBox(width: 6.w(context)),
            Text(
              item.value,
              style: AppTextStyles.titleLarge(context, color: AppColors.onSurface).copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h(context)),
        Text(
          item.label,
          style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
