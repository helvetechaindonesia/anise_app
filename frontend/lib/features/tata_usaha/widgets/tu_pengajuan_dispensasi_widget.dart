import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class TuPengajuanDispensasiWidget extends StatelessWidget {
  const TuPengajuanDispensasiWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Pengajuan Dispensasi',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.w(context)),
              ),
              child: Text(
                'Segera Hadir',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.fileText(PhosphorIconsStyle.bold),
                  color: AppColors.warning,
                  size: 20.w(context),
                ),
              ),
              SizedBox(width: 14.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Segera Hadir',
                      style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      'Fitur verifikasi dan tracking dispensasi siswa sedang disiapkan.',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
