import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// ItemListTile adalah komponen baku baris data vertikal (Model B: Minimal Flat Tile with Divider).
/// Digunakan pada daftar tugas, riwayat presensi, pengumuman, dan surat.
class ItemListTile extends StatelessWidget {
  final String? category;
  final String? subcategory;
  final String title;
  final String? metadataText;
  final IconData? metadataIcon;
  final String? statusText;
  final IconData? statusIcon;
  final Color? statusColor;
  final Widget? trailing;
  final Widget? bottomWidget;
  final VoidCallback? onTap;
  final bool showDivider;
  final double? dividerThickness;
  final Color? dividerColor;
  final EdgeInsetsGeometry? padding;

  const ItemListTile({
    super.key,
    this.category,
    this.subcategory,
    required this.title,
    this.metadataText,
    this.metadataIcon,
    this.statusText,
    this.statusIcon,
    this.statusColor,
    this.trailing,
    this.bottomWidget,
    this.onTap,
    this.showDivider = true,
    this.dividerThickness,
    this.dividerColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.w(context)),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(horizontal: 4.w(context), vertical: 14.h(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kategori / Mapel
                if (category != null && category!.isNotEmpty) ...[
                  Text(
                    category!,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground).copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 2.h(context)),
                ],

                // 2. Subkategori / Guru
                if (subcategory != null && subcategory!.isNotEmpty) ...[
                  Text(
                    subcategory!,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)).copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8.h(context)),
                ],

                // 3. Judul Utama (Bold 700)
                Text(
                  title,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // 4. Metadata (Waktu / Tenggat / Tanggal)
                if (metadataText != null && metadataText!.isNotEmpty) ...[
                  SizedBox(height: 8.h(context)),
                  Row(
                    children: [
                      if (metadataIcon != null) ...[
                        Icon(metadataIcon, size: 14.w(context), color: AppColors.onBackground),
                        SizedBox(width: 6.w(context)),
                      ],
                      Text(
                        metadataText!,
                        style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],

                // 5. Status & Trailing
                if (statusText != null || trailing != null) ...[
                  SizedBox(height: 8.h(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (statusText != null)
                        Row(
                          children: [
                            if (statusIcon != null) ...[
                              Icon(statusIcon, size: 14.w(context), color: statusColor ?? AppColors.onBackground),
                              SizedBox(width: 6.w(context)),
                            ],
                            Text(
                              statusText!,
                              style: AppTextStyles.labelMedium(context, color: statusColor ?? AppColors.onBackground).copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ],

                // 6. Bottom Widget (misal: badge validator tepat di bawah status)
                if (bottomWidget != null) ...[
                  SizedBox(height: 8.h(context)),
                  bottomWidget!,
                ],
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w(context), vertical: 2.h(context)),
            child: Container(
              height: dividerThickness ?? 2.0.h(context),
              decoration: BoxDecoration(
                color: dividerColor ?? AppColors.onBackground.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(1.w(context)),
              ),
            ),
          ),
      ],
    );
  }
}
