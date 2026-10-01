import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../bk/screens/bk_disiplin_screen.dart';

class BkDisiplinWidget extends StatelessWidget {
  const BkDisiplinWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  'Pantau Disiplin',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BkDisiplinScreen()),
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.onBackground.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 24.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'Perhatian Khusus (Poin Tinggi)',
                    style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Spacing.custom(context, 16),
              _buildStudentDisciplineRow(context, 'Aji Akbar', 'X CND', 85, AppColors.error),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                child: Divider(color: AppColors.outline.withValues(alpha: 0.2), height: 1),
              ),
              _buildStudentDisciplineRow(context, 'Sendi Aritanoga', 'XI JS', 60, AppColors.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentDisciplineRow(BuildContext context, String name, String className, int points, Color pointColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40.w(context),
              height: 40.w(context),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20.w(context)),
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: AppTextStyles.titleSmall(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(width: 12.w(context)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.labelLarge(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Kelas $className',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
          decoration: BoxDecoration(
            color: pointColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.w(context)),
          ),
          child: Text(
            '$points Poin',
            style: AppTextStyles.labelSmall(context, color: pointColor).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}



