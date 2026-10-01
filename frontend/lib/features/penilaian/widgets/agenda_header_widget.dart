import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class AgendaHeaderWidget extends StatelessWidget {
  const AgendaHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 20.w(context)),
              ),
            ),
            SizedBox(width: 12.w(context)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agenda Penilaian',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                ),
                Text(
                  'Jadwal evaluasi akademik terintegrasi',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.bold), color: AppColors.onSecondary, size: 14.w(context)),
              SizedBox(width: 4.w(context)),
              Text(
                'Ganjil\n2024',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall(context, color: AppColors.onSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

