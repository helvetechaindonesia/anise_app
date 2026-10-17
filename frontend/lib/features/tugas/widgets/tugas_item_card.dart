import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../screens/tugas_detail_screen.dart';

class TugasItemCard extends StatelessWidget {
  final String? id;
  final String subject;
  final String teacher;
  final String title;
  final String timeInfo;
  final String statusText;
  final Color statusColor;
  final IconData statusIcon;
  final Color timeBgColor;
  final Color timeIconColor;
  final int? nilai;
  final bool isSelesai;
  final bool showDivider;
  final double? dividerThickness;
  final Color? dividerColor;
  final String? description;
  final Map<String, dynamic>? submission;
  final List<dynamic>? attachments;
  final VoidCallback? onTap;

  const TugasItemCard({
    super.key,
    this.id,
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
    this.showDivider = true,
    this.dividerThickness,
    this.dividerColor,
    this.description,
    this.submission,
    this.attachments,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Warna & efek border menyala sesuai status
    final Color cardBorderColor;
    final List<BoxShadow> cardShadow;

    if (isSelesai) {
      // Abu-abu / hitam muda untuk selesai
      cardBorderColor = AppColors.outlineVariant;
      cardShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (statusText.toLowerCase().contains('terlewat')) {
      // Merah untuk terlewat
      cardBorderColor = const Color(0xFFEF4444);
      cardShadow = [
        BoxShadow(
          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      // Hijau agak menyala untuk aktif / belum dikerjakan
      cardBorderColor = const Color(0xFF10B981);
      cardShadow = [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          blurRadius: 10,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: cardBorderColor, width: isSelesai ? 1.0 : 1.5),
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.w(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.w(context)),
          onTap: onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TugasDetailScreen(
                      taskId: id ?? '',
                      subject: subject,
                      teacher: teacher,
                      title: title,
                      timeInfo: timeInfo,
                      description: description ?? '',
                      status: statusText,
                      isSubmitted: isSelesai,
                      submission: submission,
                      attachments: attachments,
                    ),
                  ),
                );
              },
          child: Padding(
            padding: EdgeInsets.all(18.w(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Mata Pelajaran & Nilai (jika selesai)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        subject,
                        style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isSelesai && nilai != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10.w(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 2.h(context)),

                // 2. Guru Pengampu
                Text(
                  teacher,
                  style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Kasih jarak
                SizedBox(height: 12.h(context)),

                // 3. Judul Tugas
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // 4. Keterangan Tugas (tidak perlu full)
                if (description != null && description!.isNotEmpty) ...[
                  SizedBox(height: 4.h(context)),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                  ),
                ],

                SizedBox(height: 10.h(context)),

                // Waktu / Tenggat Info
                Row(
                  children: [
                    Icon(
                      isSelesai
                          ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)
                          : PhosphorIcons.clock(PhosphorIconsStyle.regular),
                      size: 14.w(context),
                      color: isSelesai
                          ? AppColors.secondary
                          : (statusText.toLowerCase().contains('terlewat') ? const Color(0xFFEF4444) : AppColors.onSurfaceVariant),
                    ),
                    SizedBox(width: 6.w(context)),
                    Text(
                      timeInfo,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
