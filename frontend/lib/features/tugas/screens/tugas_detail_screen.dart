import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class TugasDetailScreen extends StatelessWidget {
  final String subject;
  final String teacher;
  final String title;
  final String timeInfo;

  const TugasDetailScreen({
    super.key,
    required this.subject,
    required this.teacher,
    required this.title,
    required this.timeInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Tugas',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Text(
                    subject,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Text(
                    'Oleh: $teacher',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h(context)),
            Text(
              title,
              style: AppTextStyles.titleLarge(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 24.h(context)),
            Container(
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.timer(PhosphorIconsStyle.bold), color: AppColors.error, size: 24.w(context)),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Text(
                      'Batas Waktu: $timeInfo',
                      style: AppTextStyles.bodyMedium(context, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h(context)),
            Text(
              'Instruksi Tugas',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 16.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              ),
              child: Text(
                'Silakan kerjakan tugas sesuai dengan materi yang telah diberikan di kelas. Buat laporan praktikum lengkap dengan pendahuluan, metodologi, hasil observasi, dan kesimpulan. Format file PDF dengan ukuran maksimal 5 MB. Jangan lupa cantumkan referensi atau daftar pustaka yang digunakan.',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 24.h(context)),
            Text(
              'Lampiran Materi',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 16.h(context)),
            Container(
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 28.w(context)),
                  ),
                  SizedBox(width: 16.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modul_Referensi_Tugas.pdf',
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h(context)),
                        Text(
                          '1.2 MB',
                          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 20.w(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(24.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outline.withValues(alpha: 0.1)),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56.h(context),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Membuka form pengumpulan tugas...'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(20.w(context)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.w(context)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Unggah Tugas Sekarang',
                style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

