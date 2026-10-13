import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Standard Dropdown Filter/Selector untuk seluruh aplikasi Anise
class AniseDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? prefixText;
  final Widget? prefixIcon;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AniseDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.isExpanded = true,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16.w(context));
    final effectiveBorder = borderColor ?? AppColors.outlineVariant.withValues(alpha: 0.8);
    final effectiveBg = backgroundColor ?? AppColors.surface;

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: isExpanded,
          icon: Icon(
            PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
            color: AppColors.onSurfaceVariant,
            size: 16.w(context),
          ),
          dropdownColor: effectiveBg,
          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
          onChanged: onChanged,
          items: items,
          hint: hintText != null
              ? Text(
                  hintText!,
                  style: AppTextStyles.labelMedium(
                    context,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
