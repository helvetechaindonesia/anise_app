import 'dart:io';

void main() {
  final content = '''
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
    final mentors = ref.watch(mentorsProvider);

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
                  style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold),
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
                    'Lihat\\nSemua',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold).copyWith(height: 1.1),
                  ),
                  SizedBox(width: 4.w(context)),
                  Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.textDark),
                ],
              ),
            ),
          ],
        ),
        Spacing.custom(context, 16),
        SizedBox(
          height: 180.h(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mentors.length + 1, // +1 for partial visibility of next item if we want, or just loop
            itemBuilder: (context, index) {
              if (index >= mentors.length) return SizedBox(width: 16.w(context));
              final mentor = mentors[index];
              return Container(
                width: 140.w(context),
                margin: EdgeInsets.only(right: 12.w(context)),
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textDark.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Spacing.custom(context, 8),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 56.w(context),
                          height: 56.w(context),
                          decoration: BoxDecoration(
                            color: mentor['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.textPrimary, size: 32.w(context)),
                        ),
                        Container(
                          width: 14.w(context),
                          height: 14.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.textPrimary, width: 2),
                          ),
                        ),
                      ],
                    ),
                    Spacing.custom(context, 8),
                    Text(
                      mentor['name'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mentor['subject'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.overline(context, color: AppColors.textDark.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
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
                        padding: EdgeInsets.symmetric(vertical: 6.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8.w(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(PhosphorIcons.calendar(PhosphorIconsStyle.bold), color: AppColors.textDark, size: 12.w(context)),
                            SizedBox(width: 4.w(context)),
                            Text(
                              'Jadwal',
                              style: AppTextStyles.overline(context, color: AppColors.textDark, fontWeight: FontWeight.bold),
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
        ),
      ],
    );
  }
}
''';
  File('f:/projek/anise_app/frontend/lib/features/home/widgets/bimbingan_mentor_widget.dart').writeAsStringSync(content);
}
