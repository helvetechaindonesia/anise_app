import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Komponen terstandarisasi untuk Card Tugas Siswa di core/widgets
/// Menggunakan border menyala sesuai status (hijau menyala untuk aktif, merah menyala untuk terlewat, abu-abu untuk selesai),
/// informasi lengkap tugas, nilai (jika sudah dinilai), dan status pengumpulan.
class AniseSiswaTaskCard extends StatelessWidget {
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

  const AniseSiswaTaskCard({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.w(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w(context), vertical: 12.h(context)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Mapel paling atas
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subject.toUpperCase(),
                                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (nilai != null) ...[
                              SizedBox(width: 6.w(context)),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 2.h(context)),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8.w(context)),
                                ),
                                child: Text(
                                  'Nilai: $nilai',
                                  style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2.h(context)),

                        // 2. Nama Guru di bawah mapel
                        Text(
                          teacher,
                          style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)).copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h(context)), // Kasih jarak

                        // 3. Judul Tugas (Bold 700)
                        Text(
                          title,
                          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // 4. Deskripsi Tugas (bila ada)
                        if (description != null && description!.trim().isNotEmpty) ...[
                          SizedBox(height: 4.h(context)),
                          Text(
                            description!.trim(),
                            style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.75)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: 8.h(context)),

                        // 5. Status Tugas
                        Row(
                          children: [
                            Icon(
                              statusIcon,
                              size: 14.w(context),
                              color: statusColor,
                            ),
                            SizedBox(width: 6.w(context)),
                            Text(
                              statusText,
                              style: AppTextStyles.labelMedium(context, color: statusColor).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h(context)),

                        // 6. Deadline (DD/MM/YYYY, HH:MM)
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.clock(PhosphorIconsStyle.regular),
                              size: 14.w(context),
                              color: AppColors.onBackground.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: 6.w(context)),
                            Expanded(
                              child: Text(
                                timeInfo,
                                style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.75)).copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Trailing Chevron
                  Padding(
                    padding: EdgeInsets.only(top: 14.h(context), left: 8.w(context)),
                    child: Icon(
                      PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                      size: 18.w(context),
                      color: AppColors.onBackground.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Garis pemisah 80% width
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h(context)),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 1,
                color: dividerColor ?? AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
      ],
    );
  }
}
