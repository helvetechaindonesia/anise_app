import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class PoinHeaderWidget extends StatelessWidget {
  const PoinHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poin & Prestasi',
              style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              'Semester Ganjil 2024/2025',
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(12.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            PhosphorIcons.medal(PhosphorIconsStyle.bold),
            color: AppColors.onPrimaryContainer,
            size: 24.w(context),
          ),
        ),
      ],
    );
  }
}

