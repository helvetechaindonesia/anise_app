import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class TerbitJurnalSopBanner extends StatelessWidget {
  const TerbitJurnalSopBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w(context)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.w(context)),
            ),
            child: Icon(
              PhosphorIcons.info(PhosphorIconsStyle.fill),
              color: AppColors.primary,
              size: 20.w(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOP Penerbitan Jurnal',
                  style: AppTextStyles.labelLarge(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  'Terbitkan jurnal mengajar minimal H-24 jam sebelum KBM dimulai agar materi dan agenda pembelajaran dapat diakses oleh siswa terlebih dahulu.',
                  style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.8)).copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
