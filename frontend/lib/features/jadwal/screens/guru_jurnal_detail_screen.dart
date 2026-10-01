import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class GuruJurnalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> journal;

  const GuruJurnalDetailScreen({
    Key? key,
    required this.journal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Detail Jurnal',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              journal['title'] ?? 'Pertemuan Kelas',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Info Jadwal
            _buildSectionTitle(context, 'Informasi Jadwal', PhosphorIcons.calendar(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 16),
            Container(
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, 'Kelas', journal['class'] ?? 'XII IPS 1', PhosphorIcons.usersThree(PhosphorIconsStyle.regular)),
                  Divider(color: AppColors.outline, height: 24.h(context)),
                  _buildInfoRow(context, 'Mata Pelajaran', journal['subject'] ?? 'Sosiologi', PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular)),
                  Divider(color: AppColors.outline, height: 24.h(context)),
                  _buildInfoRow(context, 'Waktu / Jam Ke-', journal['time'] ?? '08:00 - 09:30', PhosphorIcons.clock(PhosphorIconsStyle.regular)),
                ],
              ),
            ),

            Spacing.custom(context, 32),

            // 2. Kehadiran Singkat
            _buildSectionTitle(context, 'Rekap Kehadiran', PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 16),
            Row(
              children: [
                Expanded(child: _buildAttendanceCard(context, 'Hadir', '32', AppColors.menuPastelGreen)),
                SizedBox(width: 12.w(context)),
                Expanded(child: _buildAttendanceCard(context, 'Izin', '1', AppColors.menuPastelBlue)),
                SizedBox(width: 12.w(context)),
                Expanded(child: _buildAttendanceCard(context, 'Sakit', '2', AppColors.menuPastelPurple)),
                SizedBox(width: 12.w(context)),
                Expanded(child: _buildAttendanceCard(context, 'Alpa', '0', AppColors.menuPastelRed)),
              ],
            ),

            Spacing.custom(context, 32),

            // 3. Catatan Jurnal
            _buildSectionTitle(context, 'Catatan Jurnal', PhosphorIcons.notePencil(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topik Pembahasan',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    'Pemberdayaan Komunitas Berbasis Kearifan Lokal',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'Deskripsi / Evaluasi',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    'Siswa sangat antusias melakukan diskusi terkait bentuk-bentuk kearifan lokal di Aceh. Beberapa siswa belum berani mengemukakan pendapat di depan kelas.',
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                  ),
                ],
              ),
            ),

            Spacing.custom(context, 32),

            // 4. Lampiran
            _buildSectionTitle(context, 'Lampiran Foto', PhosphorIcons.image(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 16),
            Container(
              width: double.infinity,
              height: 180.h(context),
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.outline),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.image(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.5), size: 48.w(context)),
                    SizedBox(height: 8.h(context)),
                    Text(
                      'Tidak ada lampiran',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
            ),
            
            Spacing.custom(context, 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.onPrimaryContainer, size: 18.w(context)),
        ),
        SizedBox(width: 12.w(context)),
        Text(
          title,
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w(context)),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8.w(context)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.w(context)),
        ),
        SizedBox(width: 16.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
              SizedBox(height: 4.h(context)),
              Text(value, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context, String label, String count, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(count, style: AppTextStyles.titleLarge(context, color: color)),
          SizedBox(height: 4.h(context)),
          Text(label, style: AppTextStyles.labelSmall(context, color: color)),
        ],
      ),
    );
  }
}
