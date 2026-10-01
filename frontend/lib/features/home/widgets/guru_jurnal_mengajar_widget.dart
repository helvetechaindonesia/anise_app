import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../jadwal/screens/guru_jurnal_screen.dart';
import '../../jadwal/screens/guru_jurnal_detail_screen.dart';
import '../../jadwal/screens/jadwal_guru_detail_screen.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../../auth/providers/auth_provider.dart';

class GuruJurnalMengajarWidget extends ConsumerWidget {
  final Function(int)? onNavigateTab;
  const GuruJurnalMengajarWidget({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kelasJadwalAsync = ref.watch(kelasJadwalProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.fullName ?? 'Guru';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelas & Jadwal',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuruJurnalScreen()),
                  );
                }
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
        SizedBox(height: 16.h(context)),
        kelasJadwalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Gagal memuat jadwal: $err', style: TextStyle(color: AppColors.error)),
          data: (classes) {
            if (classes.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.h(context)),
                  child: Text('Belum ada jadwal KBM.', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                ),
              );
            }

            return SizedBox(
              height: 140.h(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: classes.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final cls = classes[index];
                  final color = AppColors.primaryContainer;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JadwalGuruDetailScreen(
                            teacherName: userName,
                            subject: cls['subject_name'] ?? 'Mata Pelajaran',
                            themeColor: color,
                            className: cls['class_name'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150.w(context),
                      margin: EdgeInsets.only(right: 16.w(context)),
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(24.w(context)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12.w(context)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIcons.student(PhosphorIconsStyle.fill), size: 14.w(context), color: AppColors.onPrimary),
                                SizedBox(width: 4.w(context)),
                                Text(
                                  '${cls['student_count']} Siswa',
                                  style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            cls['class_name'] ?? 'Unknown',
                            style: AppTextStyles.titleMedium(context, color: AppColors.onPrimaryContainer),
                          ),
                          SizedBox(height: 4.h(context)),
                          Text(
                            cls['subject_name'] ?? 'Unknown',
                            style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
