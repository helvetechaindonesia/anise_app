import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';
import 'anise_button.dart';

/// Standard Feedback State Widget (Empty, Error, atau Not Found)
class AniseStateFeedback extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final bool isError;

  const AniseStateFeedback({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionButtonText,
    this.onActionPressed,
    this.isError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconData defaultIcon = isError
        ? PhosphorIcons.warningCircle(PhosphorIconsStyle.fill)
        : PhosphorIcons.tray(PhosphorIconsStyle.fill);

    final Color iconColor = isError ? AppColors.error : AppColors.onBackground.withValues(alpha: 0.3);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w(context), vertical: 24.h(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w(context),
              height: 72.w(context),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon ?? defaultIcon,
                  size: 36.w(context),
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(height: 16.h(context)),
            Text(
              title,
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h(context)),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButtonText != null && onActionPressed != null) ...[
              SizedBox(height: 20.h(context)),
              AniseButton(
                text: actionButtonText!,
                onPressed: onActionPressed,
                variant: isError ? AniseButtonVariant.primary : AniseButtonVariant.outline,
                width: 160.w(context),
                height: 44.h(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
