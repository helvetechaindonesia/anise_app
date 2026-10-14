import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Komponen terstandarisasi untuk tampilan ketika halaman tidak memiliki data (Empty State).
/// Tanpa tombol aksi, menggunakan ikon seragam terstandarisasi untuk seluruh halaman,
/// judul utama berformat "Belum Ada Data X", dan keterangan tambahan di bawahnya.
class AniseEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const AniseEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.padding,
  });

  /// Standardized icon untuk seluruh halaman saat data kosong
  static final IconData standardIcon = PhosphorIcons.tray(PhosphorIconsStyle.bold);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 32.w(context), vertical: 40.h(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Terstandarisasi
            Container(
              width: 76.w(context),
              height: 76.w(context),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon ?? standardIcon,
                  size: 38.w(context),
                  color: AppColors.primary.withValues(alpha: 0.65),
                ),
              ),
            ),
            SizedBox(height: 18.h(context)),

            // Keterangan Utama: "Belum Ada Data X"
            Text(
              title,
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

            // Keterangan Tambahan
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: 8.h(context)),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
