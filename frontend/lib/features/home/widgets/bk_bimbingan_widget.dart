import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../jadwal/screens/guru_jurnal_screen.dart';

import '../../bk/screens/bk_bimbingan_screen.dart';

class BkBimbinganWidget extends StatelessWidget {
  final Function(int)? onNavigateTab;
  const BkBimbinganWidget({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Classes handled by Wartono as an example
    final List<Map<String, dynamic>> classes = [
      {
        'className': 'X D',
        'subject': 'Bimbingan Klasikal',
        'students': '30 Siswa',
        'color': AppColors.menuPastelBlue,
      },
      {
        'className': 'X E',
        'subject': 'Bimbingan Klasikal',
        'students': '29 Siswa',
        'color': AppColors.menuPastelGreen,
      },
      {
        'className': 'XI IPS 1',
        'subject': 'Bimbingan Klasikal',
        'students': '31 Siswa',
        'color': AppColors.menuPastelPurple,
      },
    ];

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
                  'Kelas Bimbingan',
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
                    MaterialPageRoute(builder: (context) => const BkBimbinganScreen(className: 'Semua Kelas')),
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
        Spacing.custom(context, 16),
        SizedBox(
          height: 180.h(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: classes.length + 1,
            itemBuilder: (context, index) {
              if (index >= classes.length) return SizedBox(width: 16.w(context));
              final classData = classes[index];
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
                    Spacing.custom(context, 12),
                    // Texts
                    Text(
                      classData['className'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      classData['subject'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      classData['students'] as String,
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
                            builder: (context) => BkBimbinganScreen(className: classData['className'] as String),
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
                            Icon(PhosphorIcons.usersThree(PhosphorIconsStyle.bold), color: AppColors.primary, size: 14.w(context)),
                            SizedBox(width: 4.w(context)),
                            Text(
                              'Lihat Jadwal',
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
        ),
      ],
    );
  }
}



