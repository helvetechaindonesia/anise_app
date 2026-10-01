import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../notifications/screens/notification_screen.dart';
import 'tu_input_surat_screen.dart';
import 'tu_detail_surat_screen.dart';

class TuSuratScreen extends StatelessWidget {
  const TuSuratScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TuInputSuratScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), color: AppColors.surface, size: 20.w(context)),
        label: Text('Buat Surat', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary)),
      ),
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing.custom(context, 16),
                    Text('Dashboard Persuratan', style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground)),
                    Spacing.custom(context, 24),
                    _buildStatsGrid(context),
                    Spacing.custom(context, 32),
                    Text('Surat Terbaru', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                    Spacing.custom(context, 16),
                    _buildSuratList(context),
                    Spacing.custom(context, 80), // Padding for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 65.h(context),
      expandedHeight: 65.h(context),
      titleSpacing: 24.w(context),
      automaticallyImplyLeading: false, 
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo-smk.png',
            height: 36.h(context),
            width: 36.w(context),
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w(context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SMA N 1 Peunaron',
                style: AppTextStyles.headlineSmall(context, color: AppColors.onSurface),
              ),
              Text(
                'Anise By Helvetecha',
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
          icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        ),
        SizedBox(width: 16.w(context)),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Surat Masuk', '14', AppColors.menuPastelBlue, PhosphorIcons.downloadSimple(PhosphorIconsStyle.fill))),
        SizedBox(width: 12.w(context)),
        Expanded(child: _buildStatCard(context, 'Surat Keluar', '8', AppColors.menuPastelGreen, PhosphorIcons.uploadSimple(PhosphorIconsStyle.fill))),
        SizedBox(width: 12.w(context)),
        Expanded(child: _buildStatCard(context, 'Disposisi', '3', AppColors.menuPastelPurple, PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill))),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String count, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.w(context)),
          SizedBox(height: 12.h(context)),
          Text(count, style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground)),
          Text(title, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildSuratList(BuildContext context) {
    final List<Map<String, dynamic>> suratList = [
      {'nomor': '001/TU/SMAN1/2026', 'perihal': 'Undangan Rapat Orang Tua Wali', 'jenis': 'Keluar', 'tanggal': '20 Sep 2026', 'color': AppColors.menuPastelGreen},
      {'nomor': '112/DIS/IX/2026', 'perihal': 'Surat Edaran Dinas Pendidikan', 'jenis': 'Masuk', 'tanggal': '19 Sep 2026', 'color': AppColors.menuPastelBlue},
      {'nomor': '002/TU/SMAN1/2026', 'perihal': 'Surat Keterangan Aktif Siswa', 'jenis': 'Keluar', 'tanggal': '18 Sep 2026', 'color': AppColors.menuPastelGreen},
      {'nomor': '005/TU/SMAN1/2026', 'perihal': 'Dispensasi Siswa Mengikuti Lomba', 'jenis': 'Disposisi', 'tanggal': '15 Sep 2026', 'color': AppColors.menuPastelPurple},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: suratList.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h(context)),
      itemBuilder: (context, index) {
        final surat = suratList[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TuDetailSuratScreen(surat: surat),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.onBackground.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: surat['color'].withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  surat['jenis'] == 'Masuk' ? PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold) : 
                  (surat['jenis'] == 'Keluar' ? PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold) : PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold)),
                  color: surat['color'],
                  size: 20.w(context),
                ),
              ),
              SizedBox(width: 16.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surat['perihal'],
                      style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      surat['nomor'],
                      style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w(context)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surat['tanggal'],
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                  ),
                  SizedBox(height: 4.h(context)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                    decoration: BoxDecoration(
                      color: surat['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.w(context)),
                    ),
                    child: Text(
                      surat['jenis'],
                      style: AppTextStyles.labelSmall(context, color: surat['color']).copyWith(fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
      },
    );
  }
}
