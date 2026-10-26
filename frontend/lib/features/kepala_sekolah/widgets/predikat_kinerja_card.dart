import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class PredikatKinerjaCard extends StatelessWidget {
  final String praktikKinerja; // DI_BAWAH_EKSPEKTASI, SESUAI_EKSPEKTASI, DI_ATAS_EKSPEKTASI
  final String perilakuKerja;
  final String predikatKinerja; // SANGAT_KURANG, KURANG, CUKUP, BAIK, SANGAT_BAIK
  final String periodLabel;
  final String? notes;

  const PredikatKinerjaCard({
    super.key,
    required this.praktikKinerja,
    required this.perilakuKerja,
    required this.predikatKinerja,
    required this.periodLabel,
    this.notes,
  });

  String _formatEkspektasi(String value) {
    switch (value.toUpperCase()) {
      case 'DI_BAWAH_EKSPEKTASI':
        return 'Di Bawah Ekspektasi';
      case 'DI_ATAS_EKSPEKTASI':
        return 'Di Atas Ekspektasi';
      case 'SESUAI_EKSPEKTASI':
      default:
        return 'Sesuai Ekspektasi';
    }
  }

  String _formatPredikat(String value) {
    switch (value.toUpperCase()) {
      case 'SANGAT_BAIK':
        return 'Sangat Baik';
      case 'BAIK':
        return 'Baik';
      case 'CUKUP':
        return 'Cukup';
      case 'KURANG':
        return 'Kurang';
      case 'SANGAT_KURANG':
        return 'Sangat Kurang';
      default:
        return value.replaceAll('_', ' ');
    }
  }

  Color _getPredikatColor(String value) {
    switch (value.toUpperCase()) {
      case 'SANGAT_BAIK':
        return const Color(0xFF0D9488); // Teal
      case 'BAIK':
        return AppColors.secondary; // Green
      case 'CUKUP':
        return AppColors.warning;
      case 'KURANG':
      case 'SANGAT_KURANG':
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: Predikat Kinerja + Badge Periode
        Row(
          children: [
            Text(
              'Predikat Kinerja',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 10.w(context)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(16.w(context)),
              ),
              child: Text(
                periodLabel,
                style: AppTextStyles.labelSmall(context, color: const Color(0xFF4338CA)).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),

        // Main Card persis seperti referensi user
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              // 1. Praktik Kinerja
              Padding(
                padding: EdgeInsets.all(20.w(context)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Praktik Kinerja',
                            style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h(context)),
                          Text(
                            'Berdasarkan dokumen Tindak Lanjut dan Refleksi Tindak Lanjut.',
                            style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w(context)),
                    Text(
                      _formatEkspektasi(praktikKinerja),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.outline.withValues(alpha: 0.12), height: 1),

              // 2. Perilaku Kerja
              Padding(
                padding: EdgeInsets.all(20.w(context)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perilaku Kerja',
                            style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h(context)),
                          Text(
                            'Berdasarkan penilaian terhadap 7 aspek Perilaku Kerja.',
                            style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w(context)),
                    Text(
                      _formatEkspektasi(perilakuKerja),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Predikat Kinerja* (Row Berlatar Biru Muda Halus)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.w(context)),
                    bottomRight: Radius.circular(15.w(context)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Predikat Kinerja*',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _formatPredikat(predikatKinerja),
                      style: AppTextStyles.titleMedium(context, color: _getPredikatColor(predikatKinerja)).copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Catatan Kepsek (jika ada)
        if (notes != null && notes!.trim().isNotEmpty) ...[
          SizedBox(height: 12.h(context)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(PhosphorIcons.chatTeardropText(PhosphorIconsStyle.fill), color: AppColors.primary, size: 18.w(context)),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan Kepala Sekolah:',
                        style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2.h(context)),
                      Text(
                        notes!,
                        style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: 10.h(context)),

        // Footnote biru bintang sesuai referensi gambar
        Text(
          '*Predikat Kinerja untuk bulan $periodLabel hanya digunakan sebagai bahan diskusi bersama atasan untuk peningkatan kinerja berikutnya.',
          style: AppTextStyles.labelSmall(context, color: const Color(0xFF2563EB)).copyWith(
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
