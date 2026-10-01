import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/home_provider.dart';
import '../../jadwal/screens/semua_pengajar_screen.dart';
import '../../jadwal/screens/jadwal_guru_detail_screen.dart';

class BimbinganMentorWidget extends ConsumerWidget {
  const BimbinganMentorWidget({Key? key}) : super(key: key);

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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SemuaPengajarScreen()),
                );
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
        Spacing.custom(context, 16),
        mentorsAsync.when(
          data: (mentors) {
            if (mentors.isEmpty) {
              return Container(
                height: 195.h(context),
                alignment: Alignment.center,
                child: Text('Tidak ada pengajar', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)),
              );
            }
            return SizedBox(
              height: 195.h(context),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mentors.length + 1, // +1 for partial visibility of next item if we want, or just loop
                itemBuilder: (context, index) {
                  if (index >= mentors.length) return SizedBox(width: 16.w(context));
                  final mentor = mentors[index];
              return Container(
                width: 140.w(context),
                margin: EdgeInsets.only(right: 16.w(context), bottom: 10.h(context), top: 4.h(context)),
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface, // Clean white/surface
                  borderRadius: BorderRadius.circular(20.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onBackground.withValues(alpha: 0.04), // Super soft shadow
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Spacing.custom(context, 4),
                    // Avatar Premium
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 56.w(context),
                          height: 56.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20.w(context)),
                            border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.1), width: 2),
                          ),
                          child: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), color: AppColors.primary, size: 28.w(context)),
                        ),
                        Container(
                          width: 16.w(context),
                          height: 16.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.success, // Indikator Aktif / Centang
                            borderRadius: BorderRadius.circular(20.w(context)),
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                        ),
                      ],
                    ),
                    Spacing.custom(context, 12),
                    // Texts
                    Text(
                      mentor['name'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      mentor['subject'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    const Spacer(),
                    // Pill Shaped Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JadwalGuruDetailScreen(
                              teacherName: mentor['name'] as String,
                              subject: mentor['subject'] as String,
                              themeColor: mentor['color'] as Color,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.w(context)), // Pill shape
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.calendar(PhosphorIconsStyle.bold), color: AppColors.primary, size: 14.w(context)),
                            SizedBox(width: 4.w(context)),
                            Text(
                              'Jadwal',
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
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
      loading: () => Container(
        height: 195.h(context),
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, st) => Container(
        height: 195.h(context),
        alignment: Alignment.center,
        child: Text('Gagal memuat pengajar', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
      ),
    ),
      ],
    );
  }
}




