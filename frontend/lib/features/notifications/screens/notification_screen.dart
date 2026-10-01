import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy Data Notifikasi
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Tugas Baru: Matematika',
        'body': 'Pak Budi memberikan tugas baru untuk Bab 2. Kumpulkan sebelum besok jam 12:00.',
        'time': '2 jam yang lalu',
        'type': 'task',
        'isRead': false,
      },
      {
        'title': 'Validasi Pembiasaan Berhasil',
        'body': 'Laporan sholat Dhuha kamu telah diverifikasi oleh Wali Kelas.',
        'time': '4 jam yang lalu',
        'type': 'habit',
        'isRead': true,
      },
      {
        'title': 'Peringatan Kedisiplinan',
        'body': 'Kamu mendapat pengurangan 5 poin karena terlambat masuk kelas Sejarah.',
        'time': 'Kemarin',
        'type': 'warning',
        'isRead': true,
      },
      {
        'title': 'Pengumuman Sekolah',
        'body': 'Besok seluruh siswa diwajibkan menggunakan seragam batik untuk acara spesial.',
        'time': 'Kemarin',
        'type': 'info',
        'isRead': true,
      }
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 1,
            color: AppColors.primary,
          ),
        ),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          
          IconData notifIcon;
          Color iconColor = AppColors.onSecondary;
          Color bgColor = AppColors.secondary;

          switch (notif['type']) {
            case 'task':
              notifIcon = PhosphorIcons.clipboardText(PhosphorIconsStyle.fill);
              break;
            case 'habit':
              notifIcon = PhosphorIcons.heart(PhosphorIconsStyle.fill);
              break;
            case 'warning':
              notifIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
              break;
            default:
              notifIcon = PhosphorIcons.info(PhosphorIconsStyle.fill);
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailScreen(notification: notif),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.transparent,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(notifIcon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notif['title'],
                                style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                              ),
                            ),
                            if (!notif['isRead'])
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notif['body'],
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notif['time'],
                          style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

