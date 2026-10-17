import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Komponen terstandarisasi untuk Card Tugas Guru (Aktif & Selesai)
/// Menggunakan border menyala, hamburger menu (edit & hapus) HANYA untuk penerbit tugas,
/// progres pengumpulan siswa, dan tombol aksi "Penilaian".
class AniseGuruTaskCard extends StatelessWidget {
  final String taskId;
  final String subject;
  final String className;
  final String title;
  final String description;
  final String dueDateFormatted;
  final List<dynamic>? attachments;
  final int submittedCount;
  final int gradedCount;
  final int totalStudents;
  final bool isActive;
  final bool isPublisher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPenilaian;
  final Function(String url, String name)? onDownloadAttachment;

  const AniseGuruTaskCard({
    super.key,
    required this.taskId,
    required this.subject,
    required this.className,
    required this.title,
    required this.description,
    required this.dueDateFormatted,
    this.attachments,
    required this.submittedCount,
    required this.gradedCount,
    required this.totalStudents,
    required this.isActive,
    this.isPublisher = true,
    required this.onEdit,
    required this.onDelete,
    required this.onPenilaian,
    this.onDownloadAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalStudents > 0 ? (submittedCount / totalStudents).clamp(0.0, 1.0) : 0.0;

    // Warna & efek border menyala sesuai status
    final Color cardBorderColor;
    final List<BoxShadow> cardShadow;

    if (isActive) {
      // Hijau agak menyala untuk aktif
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
    } else {
      // Abu-abu / hitam muda untuk selesai
      cardBorderColor = AppColors.outlineVariant;
      cardShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: cardBorderColor, width: isActive ? 1.5 : 1.0),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Baris 1: Mata Pelajaran & Hamburger Menu (hanya jika penerbit)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  subject,
                  style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isPublisher)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                    color: AppColors.onSurfaceVariant,
                    size: 22.w(context),
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      onEdit();
                    } else if (val == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onSurface),
                          SizedBox(width: 8.w(context)),
                          const Text('Edit Tugas'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.error),
                          SizedBox(width: 8.w(context)),
                          Text('Hapus Tugas', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Header Baris 2: Kelas (tepat di bawah mata pelajaran)
          Text(
            className,
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Kasih jarak
          SizedBox(height: 12.h(context)),

          // 3. Judul Tugas (Bukan judul jurnal)
          Text(
            title,
            style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // 4. Keterangan Tugas (tidak perlu full, maxLines 2)
          if (description.isNotEmpty) ...[
            SizedBox(height: 4.h(context)),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
            ),
          ],

          SizedBox(height: 8.h(context)),
          Row(
            children: [
              Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), size: 14.w(context), color: AppColors.onSurfaceVariant),
              SizedBox(width: 4.w(context)),
              Text(
                'Tenggat: $dueDateFormatted',
                style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),

          // Lampiran Materi / Soal (bila ada)
          if (attachments != null && attachments!.isNotEmpty) ...[
            SizedBox(height: 10.h(context)),
            ...attachments!.map((att) {
              final attMap = att is Map ? att : {};
              final attName = attMap['name']?.toString() ?? 'Lampiran_Tugas.pdf';
              final attUrl = attMap['url']?.toString() ?? '';

              return Container(
                margin: EdgeInsets.only(bottom: 6.h(context)),
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.fileText(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
                    SizedBox(width: 8.w(context)),
                    Expanded(
                      child: Text(
                        attName,
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (attUrl.isNotEmpty)
                      InkWell(
                        onTap: () {
                          if (onDownloadAttachment != null) {
                            final attId = attMap['id']?.toString();
                            final effectiveUrl = (attId != null && attId.isNotEmpty)
                                ? '/assignments/attachments/$attId/download'
                                : attUrl;
                            onDownloadAttachment!(effectiveUrl, attName);
                          }
                        },
                        borderRadius: BorderRadius.circular(6.w(context)),
                        child: Padding(
                          padding: EdgeInsets.all(4.w(context)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.primary),
                              SizedBox(width: 4.w(context)),
                              Text(
                                'Unduh',
                                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],

          Spacing.custom(context, 12),

          // Progress Pengumpulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengumpulan Siswa',
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
              ),
              Row(
                children: [
                  Text(
                    '$submittedCount / $totalStudents Siswa',
                    style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (submittedCount > 0) ...[
                    Text(' • ', style: TextStyle(color: AppColors.onSurfaceVariant)),
                    Text(
                      '$gradedCount Dinilai',
                      style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ]
                ],
              ),
            ],
          ),
          SizedBox(height: 6.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.w(context)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h(context),
              backgroundColor: AppColors.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(isActive ? const Color(0xFF10B981) : AppColors.outline),
            ),
          ),
          Spacing.custom(context, 14),

          // 5. Tombol Penilaian
          SizedBox(
            width: double.infinity,
            height: 42.h(context),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
              ),
              onPressed: onPenilaian,
              icon: Icon(PhosphorIcons.checks(PhosphorIconsStyle.bold), size: 18.w(context)),
              label: Text(
                'Penilaian',
                style: AppTextStyles.labelLarge(context).copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
