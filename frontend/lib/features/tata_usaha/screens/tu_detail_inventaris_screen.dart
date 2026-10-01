import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';

class TuDetailInventarisScreen extends StatelessWidget {
  final String nama;
  final String kode;
  final String status;
  final String jumlah;
  final Color statusColor;

  const TuDetailInventarisScreen({
    Key? key,
    required this.nama,
    required this.kode,
    required this.status,
    required this.jumlah,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                'Detail Inventaris',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Informasi Barang'),
                    Spacing.custom(context, 12),
                    _buildInfoRow(context, 'Nama Barang', nama),
                    _buildInfoRow(context, 'Kode/SKU', kode),
                    _buildInfoRow(context, 'Kategori', 'Elektronik & Multimedia'),
                    _buildInfoRow(context, 'Lokasi', 'Ruang Server / Gudang IT'),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Kondisi & Stok'),
                    Spacing.custom(context, 12),
                    _buildInfoRow(context, 'Sisa Stok', jumlah),
                    _buildInfoRow(context, 'Kondisi Baik', '4 Unit'),
                    _buildInfoRow(context, 'Kondisi Rusak', '1 Unit'),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Riwayat Peminjaman'),
                    Spacing.custom(context, 12),
                    _buildHistoryCard(context, 'Pak Budi (Guru Sejarah)', 'Kemarin, 08:00', 'Dipinjam'),
                    Spacing.custom(context, 8),
                    _buildHistoryCard(context, 'Bu Siti (Guru Fisika)', '25 Sep 2026', 'Dikembalikan'),
                    Spacing.custom(context, 40),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.archive(PhosphorIconsStyle.fill), color: statusColor, size: 32.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Ketersediaan', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
                SizedBox(height: 4.h(context)),
                Text(status, style: AppTextStyles.titleLarge(context, color: statusColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w(context),
            child: Text(label, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
          ),
          Text(':', style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
          SizedBox(width: 8.w(context)),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String peminjam, String waktu, String statusPinjam) {
    Color badgeColor = statusPinjam == 'Dipinjam' ? AppColors.menuPastelRed : AppColors.menuPastelGreen;
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.userCircle(PhosphorIconsStyle.light), color: AppColors.onBackground.withValues(alpha: 0.5), size: 24.w(context)),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(peminjam, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
                Text(waktu, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.w(context)),
            ),
            child: Text(statusPinjam, style: AppTextStyles.labelSmall(context, color: badgeColor).copyWith(fontSize: 10)),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h(context)),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.w(context)),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
            child: Text('Edit Data'),
          ),
        ),
        SizedBox(width: 16.w(context)),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h(context)),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
            ),
            child: Text('Scan QR'),
          ),
        ),
      ],
    );
  }
}
