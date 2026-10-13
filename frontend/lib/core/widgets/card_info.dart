import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// CardInfo - Standar kartu ringkasan metrik & statistik (Hadir, Terlambat, Poin, Tugas)
class CardInfo extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final Color? titleColor;
  final Color? valueColor;
  final VoidCallback? onTap;

  const CardInfo({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.titleColor,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconBg = iconBgColor ?? AppColors.primary;
    final effectiveIconColor = iconColor ?? AppColors.onPrimary;
    final effectiveTitleColor = titleColor ?? AppColors.onSurface.withValues(alpha: 0.7);
    final effectiveValueColor = valueColor ?? AppColors.onSurface;

    Widget cardContent = Container(
      padding: EdgeInsets.all(12.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Icon Container
          Container(
            width: 42.w(context),
            height: 42.w(context),
            decoration: BoxDecoration(
              color: effectiveIconBg,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Center(
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 22.w(context),
              ),
            ),
          ),
          SizedBox(width: 12.w(context)),

          // 2. Title & Value Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelSmall(context, color: effectiveTitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h(context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: AppTextStyles.titleLarge(context, color: effectiveValueColor).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit != null && unit!.isNotEmpty) ...[
                      SizedBox(width: 4.w(context)),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h(context)),
                        child: Text(
                          unit!,
                          style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.w(context)),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
