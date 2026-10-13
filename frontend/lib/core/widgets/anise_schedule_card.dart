import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// AniseScheduleCard adalah kartu horizontal baku untuk jadwal, kelas, dan pengajar
/// dengan blok warna pekat (Deep Teal), sudut lengkung 24px, dan tipografi kontras tinggi.
class AniseScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? topWidget;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const AniseScheduleCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.topWidget,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 150.w(context),
        height: height ?? 145.h(context),
        margin: EdgeInsets.only(right: 16.w(context)),
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.w(context)),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?topWidget,
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium(context, color: AppColors.onPrimaryContainer).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.75)),
            ),
          ],
        ),
      ),
    );
  }
}
