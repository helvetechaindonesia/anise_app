import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// MenuIconButton adalah tombol kotak berlekuk halus (squircle 56x56, radius 20px)
/// digunakan sebagai gerbang aksi cepat pada grid Layanan Cepat (Siswa, Guru, BK, TU).
class MenuIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final int maxLines;

  const MenuIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryContainer;
    final fgColor = iconColor ?? AppColors.onPrimaryContainer;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.w(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w(context),
            height: 56.w(context),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20.w(context)),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: fgColor,
                size: 24.w(context),
              ),
            ),
          ),
          Spacing.custom(context, 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
