import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class AgendaFeaturedCardWidget extends StatelessWidget {
  const AgendaFeaturedCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Ujian Mendatang â€¢ 2 Hari Lagi',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary),
                ),
              ),
              Icon(PhosphorIcons.timer(PhosphorIconsStyle.bold), color: AppColors.secondary, size: 20.w(context)),
            ],
          ),
          SizedBox(height: 20.h(context)),
          Text(
            'MATA PELAJARAN WAJIB',
            style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'STS Matematika Wajib',
            style: AppTextStyles.titleLarge(context, color: AppColors.onPrimaryContainer),
          ),
          SizedBox(height: 20.h(context)),
          _buildFeaturedInfoRow(context, PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill), 'Senin, 27 Okt 2025 â€¢ 08:00 - 09:30 WIB'),
          SizedBox(height: 12.h(context)),
          _buildFeaturedInfoRow(context, PhosphorIcons.door(PhosphorIconsStyle.fill), 'Ruang Ujian: Lab Komputer 1 (Meja B-14)'),
          SizedBox(height: 20.h(context)),
          Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(PhosphorIcons.listChecks(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 16.w(context)),
                SizedBox(width: 8.w(context)),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary.withValues(alpha: 0.8)),
                      children: [
                        TextSpan(text: 'Perlengkapan: ', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                        const TextSpan(text: 'Bawa Kartu Peserta Ujian Digital, Pensil 2B, Kalkulator Saintifik disetujui.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h(context)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 16.w(context)),
                SizedBox(width: 8.w(context)),
                Text(
                  'Unduh Jadwal & Tata Tertib',
                  style: AppTextStyles.bodySmall(context, color: AppColors.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.secondary, size: 16.w(context)),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer),
          ),
        ),
      ],
    );
  }
}

