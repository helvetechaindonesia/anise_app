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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  'Pengajuan Dispensasi',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
                SizedBox(width: 8.w(context)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                  child: Text(
                    '2',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'Lihat\nSemua',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(width: 4.w(context)),
                  Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),
                ],
              ),
            ),
          ],
        ),
        Spacing.custom(context, 16),
        _buildDispensasiCard(
          context,
          name: 'Muhammad Fadlan',
          grade: 'XII RPL 1',
          reason: 'Lomba FLS2N Tingkat Provinsi',
          date: '28 Sep - 30 Sep 2026',
        ),
        Spacing.custom(context, 12),
        _buildDispensasiCard(
          context,
          name: 'Rina Wijayanti',
          grade: 'X DKV 2',
          reason: 'Dispensasi Sakit (Rawat Inap)',
          date: '27 Sep - 29 Sep 2026',
        ),
      ],
    );
  }

  Widget _buildDispensasiCard(BuildContext context, {required String name, required String grade, required String reason, required String date}) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.menuPastelGreen.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16.w(context)),
            ),
            child: Icon(PhosphorIcons.ticket(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: AppTextStyles.titleSmall(context, color: AppColors.onSurface)),
                    Text(grade, style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                SizedBox(height: 4.h(context)),
                Text(reason, style: AppTextStyles.bodySmall(context, color: AppColors.onSurface)),
                SizedBox(height: 4.h(context)),
                Row(
                  children: [
                    Icon(PhosphorIcons.calendarBlank(), size: 14.w(context), color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4.w(context)),
                    Text(date, style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
