import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class TuRingkasanSuratWidget extends StatelessWidget {
  const TuRingkasanSuratWidget({Key? key}) : super(key: key);

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
                  'Ringkasan Persuratan',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
                SizedBox(width: 8.w(context)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                  child: Text(
                    '5',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to Surat Tab
              },
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
        _buildSuratCard(
          context,
          title: '3 Surat Masuk Baru',
          subtitle: 'Belum dibaca / didisposisikan',
          icon: PhosphorIcons.envelopeOpen(PhosphorIconsStyle.bold),
          color: AppColors.menuPastelBlue,
        ),
        Spacing.custom(context, 12),
        _buildSuratCard(
          context,
          title: '2 Surat Keluar Menunggu',
          subtitle: 'Menunggu TTD Kepala Sekolah',
          icon: PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold),
          color: AppColors.menuPastelPurple,
        ),
      ],
    );
  }

  Widget _buildSuratCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color}) {
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
              color: color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16.w(context)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onSurface)),
                SizedBox(height: 4.h(context)),
                Text(subtitle, style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}
