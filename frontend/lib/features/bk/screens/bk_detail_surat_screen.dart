import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class BkDetailSuratScreen extends StatelessWidget {
  final String subject;
  final String teacher;
  final String title;
  final String timeInfo;
  final String statusText;
  final Color statusColor;

  const BkDetailSuratScreen({
    Key? key,
    required this.subject,
    required this.teacher,
    required this.title,
    required this.timeInfo,
    required this.statusText,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Surat',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onBackground.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.w(context)),
                        ),
                        child: Text(
                          statusText,
                          style: AppTextStyles.labelSmall(context, color: statusColor).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onSurface.withValues(alpha: 0.6)),
                          SizedBox(width: 6.w(context)),
                          Text(
                            timeInfo,
                            style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacing.custom(context, 20),
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall(context, color: AppColors.onSurface),
                  ),
                  Spacing.custom(context, 12),
                  _buildInfoRow(context, PhosphorIcons.user(PhosphorIconsStyle.bold), subject),
                  Spacing.custom(context, 8),
                  _buildInfoRow(context, PhosphorIcons.warning(PhosphorIconsStyle.bold), teacher, color: AppColors.error),
                ],
              ),
            ),
            Spacing.custom(context, 24),
            Text('Isi Keterangan', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
            Spacing.custom(context, 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Telah dilakukan pemanggilan orang tua / wali murid untuk mendiskusikan masalah kedisiplinan siswa yang bersangkutan. Mohon hadir sesuai jadwal yang tertera pada surat ini. Terima kasih.',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8)).copyWith(height: 1.5),
              ),
            ),
            Spacing.custom(context, 40),
            SizedBox(
              width: double.infinity,
              height: 56.h(context),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w(context)),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Surat sedang diunduh...', style: AppTextStyles.bodyMedium(context)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 20.w(context)),
                label: Text(
                  'Unduh Surat (PDF)',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, {Color? color}) {
    final c = color ?? AppColors.onSurface.withValues(alpha: 0.7);
    return Row(
      children: [
        Icon(icon, size: 18.w(context), color: c),
        SizedBox(width: 8.w(context)),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium(context, color: c),
          ),
        ),
      ],
    );
  }
}
