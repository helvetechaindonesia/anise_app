import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

enum AniseButtonVariant { primary, secondary, outline, danger }

/// Standard Button untuk seluruh aplikasi Anise
class AniseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AniseButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double? height;

  const AniseButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AniseButtonVariant.primary,
    this.icon,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? border;

    switch (variant) {
      case AniseButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = AppColors.onPrimary;
        border = null;
        break;
      case AniseButtonVariant.secondary:
        bgColor = AppColors.secondary;
        fgColor = AppColors.onSecondary;
        border = null;
        break;
      case AniseButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = AppColors.onPrimary;
        border = null;
        break;
      case AniseButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        border = BorderSide(color: AppColors.primary, width: 1.5);
        break;
    }

    final double btnHeight = height ?? 52.h(context);

    return SizedBox(
      width: width ?? double.infinity,
      height: btnHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.w(context)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w(context),
                height: 20.w(context),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20.w(context), color: fgColor),
                    SizedBox(width: 8.w(context)),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.labelMedium(context, color: fgColor).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp(context),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
