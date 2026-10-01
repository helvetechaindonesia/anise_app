import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/models/user_model.dart';

class RoleDashboardPlaceholder extends StatelessWidget {
  final String title;
  final UserRole role;

  const RoleDashboardPlaceholder({
    Key? key,
    required this.title,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.squaresFour(PhosphorIconsStyle.fill),
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.headlineMedium(context, color: AppColors.onBackground),
          ),
          const SizedBox(height: 12),
          Text(
            'Role: ${role.name.toUpperCase()}',
            style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
