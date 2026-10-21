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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(
          color: cardBorderColor,
          width: isSelesai ? 1.0 : 1.5,
        ),
        boxShadow: cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.w(context)),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Leading Icon Avatar (Mata Pelajaran & Status Icon)
                Container(
                  width: 44.w(context),
                  height: 44.w(context),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Center(
                    child: Icon(
                      statusIcon,
                      size: 22.w(context),
                      color: statusColor,
                    ),
                  ),
                ),
                SizedBox(width: 14.w(context)),

                // 2. Middle Info (ListTile Content: Judul, Mapel, Tenggat, Status)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mapel & Badge Nilai (Jika ada)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subject,
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
                      SizedBox(height: 3.h(context)),

                      // Judul Tugas
                      Text(
                        title,
                        style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h(context)),

                      // Tenggat & Status Info
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.clock(PhosphorIconsStyle.regular),
                            size: 13.w(context),
                            color: AppColors.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w(context)),
                          Expanded(
                            child: Text(
                              timeInfo,
                              style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant).copyWith(
                                fontSize: 11.sp(context),
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
                SizedBox(width: 10.w(context)),

                // 3. Trailing Chevron
                Icon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                  size: 18.w(context),
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
