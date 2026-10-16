import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_action_link.dart';
import '../../../core/widgets/anise_schedule_card.dart';
import '../providers/home_provider.dart';
import '../../jadwal/screens/semua_pengajar_screen.dart';
import '../../jadwal/screens/jadwal_guru_detail_screen.dart';

class BimbinganMentorWidget extends ConsumerWidget {
  const BimbinganMentorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorsAsync = ref.watch(mentorsProvider);

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
                  'Jadwal & Pengajar',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
              ],
            ),
            SectionActionLink(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SemuaPengajarScreen()),
                );
              },
            ),
          ],
        ),
        Spacing.custom(context, 16),
        mentorsAsync.when(
          data: (mentors) {
            if (mentors.isEmpty) {
              return Container(
                height: 145.h(context),
                alignment: Alignment.center,
                child: Text('Tidak ada pengajar', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)),
              );
            }
            return SizedBox(
              height: 145.h(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mentors.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final mentor = mentors[index];
                  final teacherName = mentor['name'] as String;
                  final subject = mentor['subject'] as String;

                  return AniseScheduleCard(
                    title: subject,
                    subtitle: teacherName,
                    topWidget: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 44.w(context),
                          height: 44.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16.w(context)),
                            border: Border.all(
                              color: AppColors.onPrimaryContainer.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            PhosphorIcons.user(PhosphorIconsStyle.fill),
                            color: AppColors.onPrimaryContainer,
                            size: 22.w(context),
                          ),
                        ),
                        Container(
                          width: 12.w(context),
                          height: 12.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryContainer, width: 2),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JadwalGuruDetailScreen(
                            teacherName: teacherName,
                            subject: subject,
                            themeColor: AppColors.primaryContainer,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => Container(
            height: 145.h(context),
            alignment: Alignment.center,
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, st) => Container(
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
                Text('Gagal memuat pengajar', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                SizedBox(width: 8.w(context)),
                IconButton(
                  icon: Icon(PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                  onPressed: () => ref.refresh(mentorsProvider),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}




