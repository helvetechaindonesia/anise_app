import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../screens/tugas_detail_screen.dart';

class TugasItemCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String title;
  final String timeInfo;
  final String statusText;
  final Color
  statusColor; // Keep for interface, but won't use it directly if they want onBackground
  final IconData statusIcon;
  final Color timeBgColor; // Keep for interface
  final Color timeIconColor; // Keep for interface
  final int? nilai;
  final bool isSelesai;

  final VoidCallback? onTap;

  const TugasItemCard({
    Key? key,
    required this.subject,
    required this.teacher,
    required this.title,
    required this.timeInfo,
    required this.statusText,
    required this.statusColor,
    required this.statusIcon,
    required this.timeBgColor,
    required this.timeIconColor,
    this.nilai,
    this.isSelesai = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(16.w(context)),
      ),
      child: GestureDetector(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TugasDetailScreen(
                subject: subject,
                teacher: teacher,
                title: title,
                timeInfo: timeInfo,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Mata Pelajaran
            Text(
              subject,
              style: AppTextStyles.labelSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 2.h(context)),
            // 2. Nama Guru Pengampu
            Text(
              teacher,
              style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)).copyWith(fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 10.h(context)),
            // 3. Judul Tugas (Bold 700)
            Text(
              title,
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h(context)),
            // 4. Waktu / Deadline
            Row(
              children: [
                Icon(
                  isSelesai ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold) : PhosphorIcons.timer(PhosphorIconsStyle.bold),
                  size: 14.w(context),
                  color: AppColors.onBackground,
                ),
                SizedBox(width: 6.w(context)),
                Text(
                  timeInfo,
                  style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w400),
                ),
              ],
            ),
            SizedBox(height: 6.h(context)),
            // 5. Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, size: 14.w(context), color: AppColors.onBackground),
                    SizedBox(width: 6.w(context)),
                    Text(
                      'Status: ',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w400),
                    ),
                    Text(
                      statusText,
                      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                // Jika sudah dinilai
                if (isSelesai && nilai != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill), color: AppColors.onSecondary, size: 12.w(context)),
                        SizedBox(width: 4.w(context)),
                        Text(
                          nilai.toString(),
                          style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

