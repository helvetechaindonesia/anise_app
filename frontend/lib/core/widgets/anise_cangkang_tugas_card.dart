import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Komponen terstandarisasi untuk Card Cangkang Tugas (Guru: Tab Belum Terbit)
/// Format informasi:
/// 1. Mata Pelajaran
/// 2. Kelas (tepat di bawah mata pelajaran)
/// 3. Jarak -> Judul Jurnal
/// 4. Deskripsi Jurnal
/// 5. Jarak -> Tombol "Buat Tugas"
/// Border: Kuning tua menyala dengan glowing box-shadow.
class AniseCangkangTugasCard extends StatelessWidget {
  final String subject;
  final String className;
  final String journalTitle;
  final String journalDescription;
  final VoidCallback onBuatTugas;

  const AniseCangkangTugasCard({
    super.key,
    required this.subject,
    required this.className,
    required this.journalTitle,
    required this.journalDescription,
    required this.onBuatTugas,
  });

  @override
  Widget build(BuildContext context) {
    const cardBorderColor = Color(0xFFF59E0B);
    final cardShadow = [
      BoxShadow(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        blurRadius: 10,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: cardBorderColor, width: 1.5),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Mata Pelajaran
          Text(
            subject,
            style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h(context)),

          // 2. Kelas (tepat di bawah mata pelajaran)
          Text(
            className,
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Kasih jarak
          SizedBox(height: 12.h(context)),

          // 3. Judul Jurnal
          Text(
            journalTitle,
            style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          // 4. Deskripsi Jurnal
          if (journalDescription.isNotEmpty) ...[
            SizedBox(height: 4.h(context)),
            Text(
              journalDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
            ),
          ],

          SizedBox(height: 16.h(context)),

          // 5. Tombol Buat Tugas
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
              onPressed: onBuatTugas,
              icon: Icon(PhosphorIcons.plusCircle(PhosphorIconsStyle.bold), size: 18.w(context)),
              label: Text(
                'Buat Tugas',
                style: AppTextStyles.labelLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
