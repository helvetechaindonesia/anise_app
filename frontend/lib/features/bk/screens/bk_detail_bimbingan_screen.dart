import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';

class BkDetailBimbinganScreen extends StatelessWidget {
  final String title;
  final String type;
  final String desc;
  final String time;
  final String location;
  final Color typeColor;

  const BkDetailBimbinganScreen({
    Key? key,
    required this.title,
    required this.type,
    required this.desc,
    required this.time,
    required this.location,
    required this.typeColor,
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
                'Detail Bimbingan',
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
                    _buildSectionTitle(context, 'Agenda Bimbingan'),
                    Spacing.custom(context, 12),
                    Text(desc, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Pelaksanaan'),
                    Spacing.custom(context, 12),
                    _buildInfoRow(context, 'Tipe', type),
                    _buildInfoRow(context, 'Waktu', time),
                    _buildInfoRow(context, 'Tempat', location),
                    _buildInfoRow(context, 'Guru Pembimbing', 'Ahmad Dani, S.Pd'),
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Catatan / Hasil Konseling'),
                    Spacing.custom(context, 12),
                    _buildCatatan(context),
                    Spacing.custom(context, 32),
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
              color: typeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIcons.usersThree(PhosphorIconsStyle.fill), color: typeColor, size: 32.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: AppTextStyles.labelSmall(context, color: typeColor)),
                SizedBox(height: 4.h(context)),
                Text(title, style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
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
            width: 130.w(context),
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

  Widget _buildCatatan(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Text(
        'Siswa berjanji untuk tidak membolos lagi. Direkomendasikan untuk mengikuti kegiatan ekstrakurikuler agar memiliki aktivitas yang positif. Akan dipantau perkembangannya minggu depan.',
        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8)),
        textAlign: TextAlign.justify,
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
            child: Text('Ubah Catatan'),
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
            child: Text('Selesai'),
          ),
        ),
      ],
    );
  }
}
