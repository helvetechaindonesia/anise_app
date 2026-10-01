import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import 'tu_detail_inventaris_screen.dart';

class TuInventarisScreen extends StatelessWidget {
  const TuInventarisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), color: AppColors.surface, size: 20.w(context)),
        label: Text('Tambah Barang', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary)),
      ),
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Inventaris Sekolah',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(context),
                    Spacing.custom(context, 24),
                    Text('Daftar Barang', style: AppTextStyles.titleLarge(context, color: AppColors.onBackground)),
                    Spacing.custom(context, 16),
                    _buildInventoryItem(context, 'Proyektor Epson EB-X05', 'INV/ELK/2026/001', 'Tersedia', '5 Unit', AppColors.menuPastelGreen),
                    Spacing.custom(context, 12),
                    _buildInventoryItem(context, 'Speaker Aktif Polytron', 'INV/ELK/2026/002', 'Dipinjam', '0 Unit', AppColors.menuPastelRed),
                    Spacing.custom(context, 12),
                    _buildInventoryItem(context, 'Buku Panduan Guru Merdeka', 'INV/BKR/2026/014', 'Tersedia', '120 Buku', AppColors.menuPastelGreen),
                    Spacing.custom(context, 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: TextField(
        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
        decoration: InputDecoration(
          hintText: 'Cari nama atau kode barang...',
          hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
          prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
        ),
      ),
    );
  }

  Widget _buildInventoryItem(BuildContext context, String nama, String kode, String status, String jumlah, Color statusColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TuDetailInventarisScreen(
              nama: nama,
              kode: kode,
              status: status,
              jumlah: jumlah,
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.menuPastelGreyish.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.w(context)),
              ),
              child: Icon(PhosphorIcons.archive(PhosphorIconsStyle.bold), color: AppColors.menuPastelGreyish, size: 24.w(context)),
            ),
            SizedBox(width: 16.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                  SizedBox(height: 4.h(context)),
                  Text(kode, style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
                  SizedBox(height: 8.h(context)),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.w(context)),
                        ),
                        child: Text(status, style: AppTextStyles.labelSmall(context, color: statusColor).copyWith(fontSize: 10)),
                      ),
                      SizedBox(width: 8.w(context)),
                      Text(jumlah, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7))),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
