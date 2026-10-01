import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class SiswaStatsRowWidget extends StatelessWidget {
  const SiswaStatsRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Presensi',
            value: '98.4%',
            subtitle: 'Sangat Baik',
            subtitleColor: AppColors.onSurface,
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Poin Siswa',
            value: '100 / 100',
            subtitle: 'Tanpa Catatan',
            subtitleColor: AppColors.onSurface,
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Rerata Nilai',
            value: '91.6',
            subtitle: 'Peringkat 3',
            subtitleColor: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        /* border removed */
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelSmall(
              context,
              color: AppColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h(context)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
          ),
          SizedBox(height: 8.h(context)),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: AppTextStyles.labelSmall(
                context,
                color: subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

