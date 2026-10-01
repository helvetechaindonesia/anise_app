import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    IconData notifIcon;
    Color iconColor;
    Color bgColor;

    switch (notification['type']) {
      case 'task':
        notifIcon = PhosphorIcons.clipboardText(PhosphorIconsStyle.fill);
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'habit':
        notifIcon = PhosphorIcons.heart(PhosphorIconsStyle.fill);
        iconColor = AppColors.secondary;
        bgColor = AppColors.secondary.withValues(alpha: 0.1);
        break;
      case 'warning':
        notifIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
        iconColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.1);
        break;
      default:
        notifIcon = PhosphorIcons.info(PhosphorIconsStyle.fill);
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
    }

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
          'Detail Notifikasi',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(24.w(context)),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(notifIcon, color: iconColor, size: 64.w(context)),
              ),
            ),
            SizedBox(height: 32.h(context)),
            Center(
              child: Text(
                notification['time'] ?? '',
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
              ),
            ),
            SizedBox(height: 12.h(context)),
            Center(
              child: Text(
                notification['title'] ?? '',
                style: AppTextStyles.titleLarge(context, color: AppColors.onBackground),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              ),
              child: Text(
                notification['body'] ?? '',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 48.h(context)),
            // Tombol aksi dinamis berdasarkan tipe notifikasi
            if (notification['type'] == 'task')
              SizedBox(
                width: double.infinity,
                height: 56.h(context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Atau redirect ke halaman tugas
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.w(context)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lihat Tugas',
                    style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

