import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';

class TuDetailDispensasiScreen extends StatelessWidget {
  final String nama;
  final String kelas;
  final String alasan;
  final String status;
  final Color statusColor;

  const TuDetailDispensasiScreen({
    Key? key,
    required this.nama,
    required this.kelas,
    required this.alasan,
    required this.status,
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
                'Detail Dispensasi',
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
                    _buildSectionTitle(context, 'Informasi Pemohon'),
                    Spacing.custom(context, 12),
                    _buildInfoRow(context, 'Nama Siswa', nama),
                    _buildInfoRow(context, 'Kelas', kelas),
                    _buildInfoRow(context, 'NISN', '0051234567'),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Detail Permintaan'),
                    Spacing.custom(context, 12),
                    _buildInfoRow(context, 'Tanggal', '28 September 2026'),
                    _buildInfoRow(context, 'Durasi', '1 Hari'),
                    _buildInfoRow(context, 'Alasan', alasan),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Dokumen Pendukung'),
                    Spacing.custom(context, 12),
                    _buildAttachmentFile(context, 'Surat_Keterangan_RS.pdf', '1.2 MB'),
                    Spacing.custom(context, 32),
                    if (status == 'Menunggu') _buildActionButtons(context),
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
            child: Icon(PhosphorIcons.ticket(PhosphorIconsStyle.fill), color: statusColor, size: 32.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Saat Ini', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
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

  Widget _buildAttachmentFile(BuildContext context, String filename, String size) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.menuPastelBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: AppColors.menuPastelBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.menuPastelBlue, size: 32.w(context)),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filename, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
                Text(size, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.menuPastelBlue, size: 24.w(context)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h(context)),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.menuPastelRed,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.w(context)),
                side: BorderSide(color: AppColors.menuPastelRed),
              ),
            ),
            child: Text('Tolak Dispensasi'),
          ),
        ),
        SizedBox(width: 16.w(context)),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h(context)),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
            ),
            child: Text('Setujui'),
          ),
        ),
      ],
    );
  }
}
