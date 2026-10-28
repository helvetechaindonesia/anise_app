import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_action_link.dart';
import '../../../core/widgets/anise_schedule_card.dart';
import '../../bk/providers/counseling_provider.dart';
import '../../bk/screens/bk_bimbingan_screen.dart';

class BkBimbinganWidget extends ConsumerWidget {
  final Function(int)? onNavigateTab;
  const BkBimbinganWidget({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counselingOverviewAsync = ref.watch(bkAllCounselingOverviewProvider);

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
                  'Kelas & Bimbingan',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
              ],
            ),
            SectionActionLink(
              onTap: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(1);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BkBimbinganScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        SizedBox(height: 16.h(context)),
        counselingOverviewAsync.when(
          loading: () => Container(
            height: 145.h(context),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Container(
            height: 145.h(context),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 20.w(context)),
                SizedBox(width: 8.w(context)),
                Text('Gagal memuat jadwal bimbingan', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                SizedBox(width: 8.w(context)),
                IconButton(
                  icon: Icon(PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                  onPressed: () => ref.refresh(bkAllCounselingOverviewProvider),
                ),
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Container(
                height: 145.h(context),
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.4), size: 24.w(context)),
                    SizedBox(width: 10.w(context)),
                    Text(
                      'Belum ada agenda bimbingan aktif.',
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 145.h(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final type = item['type']?.toString().toUpperCase() ?? 'BIMBINGAN';
                  final className = item['class_name']?.toString() ?? '';
                  final studentName = item['student_name']?.toString() ?? 'Siswa';
                  final topic = item['topic']?.toString() ?? 'Konseling BK';
                  final dateStr = item['schedule_date']?.toString();
                  final DateTime? itemDate = (dateStr != null && dateStr.isNotEmpty) ? DateTime.tryParse(dateStr) : null;
                  final counselingId = item['id']?.toString();

                  // Penentuan judul: jika KLASIKAL pakai Kelas, jika INDIVIDU pakai Nama Siswa, jika KELOMPOK pakai Kelompok/Nama
                  String cardTitle;
                  if (type == 'KLASIKAL') {
                    cardTitle = className.isNotEmpty ? className : 'Kelas Bimbingan';
                  } else if (type == 'KELOMPOK') {
                    cardTitle = studentName.isNotEmpty ? studentName : (className.isNotEmpty ? className : 'Kelompok BK');
                  } else {
                    cardTitle = studentName.isNotEmpty ? studentName : 'Siswa BK';
                  }

                  // Icon dan warna badge jenis bimbingan
                  IconData badgeIcon;
                  Color badgeBg;
                  Color badgeText;
                  if (type == 'KLASIKAL') {
                    badgeIcon = PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.fill);
                    badgeBg = AppColors.primary;
                    badgeText = AppColors.onPrimary;
                  } else if (type == 'KELOMPOK') {
                    badgeIcon = PhosphorIcons.usersThree(PhosphorIconsStyle.fill);
                    badgeBg = const Color(0xFF0D9488); // Teal
                    badgeText = Colors.white;
                  } else {
                    badgeIcon = PhosphorIcons.user(PhosphorIconsStyle.fill);
                    badgeBg = const Color(0xFF3B82F6); // Blue
                    badgeText = Colors.white;
                  }

                  void navigateToSchedule() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BkBimbinganScreen(
                          initialDate: itemDate,
                          targetCounselingId: counselingId,
                        ),
                      ),
                    );
                  }

                  return AniseScheduleCard(
                    title: cardTitle,
                    subtitle: topic,
                    backgroundColor: AppColors.primaryContainer,
                    onTap: navigateToSchedule,
                    topWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Badge Jenis Bimbingan
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(10.w(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(badgeIcon, size: 12.w(context), color: badgeText),
                              SizedBox(width: 4.w(context)),
                              Text(
                                type,
                                style: AppTextStyles.labelSmall(context, color: badgeText).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tombol Lihat Jadwal mini ikon
                        GestureDetector(
                          onTap: navigateToSchedule,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 3.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.w(context)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Jadwal',
                                  style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9.sp(context),
                                  ),
                                ),
                                SizedBox(width: 2.w(context)),
                                Icon(
                                  PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                                  size: 10.w(context),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
