import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Standard App Bar untuk semua Sub-Page di aplikasi Anise
class AniseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? bottom;
  final double? bottomHeight;

  const AniseAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.bottom,
    this.bottomHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                color: AppColors.onBackground,
                size: 24.w(context),
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: subtitle == null
          ? Text(
              title,
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.w700,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle!,
                  style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
              ],
            ),
      actions: actions != null
          ? [
              ...actions!,
              SizedBox(width: 12.w(context)),
            ]
          : null,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 48.0),
              child: bottom!,
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottomHeight ?? 0.0));
}
