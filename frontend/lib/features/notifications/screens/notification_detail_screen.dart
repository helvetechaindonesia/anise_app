import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tugas/screens/guru_tugas_penilaian_screen.dart';
import '../../tugas/screens/tugas_detail_screen.dart';

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
      appBar: const AniseAppBar(
        title: 'Detail Notifikasi',
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
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: 48.h(context)),
            // Tombol aksi dinamis berdasarkan tipe notifikasi (tidak ditampilkan jika tugas telah dihapus atau taskId kosong)
            if ((notification['type'] == 'task' || notification['type'] == 'late_request') &&
                !notification['title'].toString().toLowerCase().contains('dihapus') &&
                !notification['body'].toString().toLowerCase().contains('telah dihapus') &&
                ((notification['data'] as Map<String, dynamic>?)?['task_id']?.toString().isNotEmpty ?? false))
              SizedBox(
                width: double.infinity,
                height: 56.h(context),
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentUser = ref.watch(authProvider).user;
                    final isSiswa = currentUser?.role == UserRole.siswa;

                    final data = notification['data'] as Map<String, dynamic>? ?? {};
                    final taskId = data['task_id']?.toString() ?? '';
                    final studentId = data['student_id']?.toString();
                    final taskTitle = data['task_title']?.toString() ?? notification['title'] ?? 'Tugas';
                    final subjectName = data['subject_name']?.toString() ?? 'Mata Pelajaran';
                    final className = data['class_name']?.toString() ?? '';
                    final teacherName = data['teacher_name']?.toString() ?? 'Guru';
                    final dueDateFormatted = data['due_date_formatted']?.toString() ?? '';

                    String buttonLabel = 'Lihat Tugas';
                    if (!isSiswa && notification['type'] == 'late_request') {
                      buttonLabel = 'Lihat Permohonan & Beri Nilai';
                    }

                    return ElevatedButton(
                      onPressed: () {
                        if (taskId.isEmpty) {
                          Navigator.pop(context);
                          return;
                        }

                        if (isSiswa) {
                          // Siswa diarahkan ke detail tugas siswa
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TugasDetailScreen(
                                taskId: taskId,
                                subject: subjectName,
                                teacher: teacherName,
                                title: taskTitle,
                                timeInfo: dueDateFormatted,
                              ),
                            ),
                          );
                        } else {
                          // Guru diarahkan ke halaman penilaian tugas
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GuruTugasPenilaianScreen(
                                taskId: taskId,
                                title: taskTitle,
                                subject: subjectName,
                                className: className,
                                highlightStudentId: studentId,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonLabel,
                        style: AppTextStyles.bodyLarge(context, color: AppColors.onPrimary),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

