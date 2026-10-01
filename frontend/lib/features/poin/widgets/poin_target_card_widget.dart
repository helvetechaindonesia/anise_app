import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class PoinTargetCardWidget extends StatelessWidget {
  const PoinTargetCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.onSecondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.graduationCap(PhosphorIconsStyle.bold), color: AppColors.onSecondary, size: 24.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Target Beasiswa Sekolah',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onSecondary),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Kurang 15 poin lagi menuju status Piagam Kehormatan Rektorat.',
                  style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

