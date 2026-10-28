import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class ProjectStatsScreen extends StatelessWidget {
  const ProjectStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildHeroCard(context),
                  SizedBox(height: 20.h(context)),
                  _buildSectionTitle(context, 'Statistik Pengembangan (Git Sprint)'),
                  SizedBox(height: 12.h(context)),
                  _buildStatsGrid(context),
                  SizedBox(height: 24.h(context)),
                  _buildSectionTitle(context, 'Fondasi Arsitektur & Teknologi'),
                  SizedBox(height: 12.h(context)),
                  _buildTechStackCard(context),
                  SizedBox(height: 24.h(context)),
                  _buildDeveloperTributeCard(context),
                  SizedBox(height: 36.h(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentang & Kilas Balik Proyek',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                ),
                Text(
                  'Catatan sprint pembangunan Anise App',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 5.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.sparkle(PhosphorIconsStyle.fill), color: AppColors.primary, size: 14.w(context)),
                SizedBox(width: 4.w(context)),
                Text('v1.0.0', style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
            const Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.w(context)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.trophy(PhosphorIconsStyle.fill), color: const Color(0xFFFFD700), size: 16.w(context)),
                    SizedBox(width: 6.w(context)),
                    Text(
                      'Sprint Masterpiece',
                      style: GoogleFonts.outfit(
                        fontSize: 12.w(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIcons.codeBlock(PhosphorIconsStyle.bold), color: Colors.white.withValues(alpha: 0.4), size: 28.w(context)),
            ],
          ),
          SizedBox(height: 18.h(context)),
          Text(
            'Anise Smart Education',
            style: GoogleFonts.outfit(
              fontSize: 24.w(context),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'Sistem Informasi Manajemen Sekolah Terpadu dengan Presensi Biometrik Wajah, Geofencing GPS, dan Pembinaan Karakter.',
            style: GoogleFonts.outfit(
              fontSize: 13.w(context),
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold), color: Colors.white, size: 16.w(context)),
                SizedBox(width: 8.w(context)),
                Expanded(
                  child: Text(
                    'Periode Pembangunan: 01 Okt 2026 - 28 Okt 2026',
                    style: GoogleFonts.outfit(
                      fontSize: 12.w(context),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
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
      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                icon: PhosphorIcons.clockCountdown(PhosphorIconsStyle.fill),
                iconColor: const Color(0xFFF59E0B),
                value: '27 Hari',
                label: 'Total Waktu Sprint',
                sublabel: 'Kurang dari 1 bulan penuh',
              ),
            ),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: _buildMetricCard(
                context: context,
                icon: PhosphorIcons.gitCommit(PhosphorIconsStyle.fill),
                iconColor: const Color(0xFF10B981),
                value: '379 Commit',
                label: 'Jejak Iterasi Git',
                sublabel: 'Rata-rata ~14 commit/hari',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context: context,
                icon: PhosphorIcons.lightning(PhosphorIconsStyle.fill),
                iconColor: const Color(0xFF8B5CF6),
                value: 'Ultra Fast',
                label: 'Kecepatan Rata-rata',
                sublabel: 'Velocity pengerjaan sprint',
              ),
            ),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: _buildMetricCard(
                context: context,
                icon: PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                iconColor: AppColors.primary,
                value: '7 Role',
                label: 'Multi-Tenant Aktif',
                sublabel: 'Siswa, Guru, BK, TU, Sarpras, dkk',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w(context)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.w(context)),
          ),
          SizedBox(height: 12.h(context)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 19.w(context),
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            label,
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2.h(context)),
          Text(
            sublabel,
            style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackCard(BuildContext context) {
    final tags = [
      'Flutter Multiplatform',
      'Laravel 11 REST API',
      'PostgreSQL Database',
      'GPS Geofencing',
      'Face Biometrics 3D',
      'Realtime Heartbeat',
      'WhatsApp Automation',
      'Play Store SDK 35/36',
    ];

    return Container(
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.stack(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
              SizedBox(width: 8.w(context)),
              Text('Core Architecture & Modules', style: AppTextStyles.titleMedium(context, color: AppColors.onSurface)),
            ],
          ),
          SizedBox(height: 14.h(context)),
          Wrap(
            spacing: 8.w(context),
            runSpacing: 8.h(context),
            children: tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.outfit(
                    fontSize: 12.w(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperTributeCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.coffee(PhosphorIconsStyle.fill), color: const Color(0xFFB45309), size: 22.w(context)),
              SizedBox(width: 8.w(context)),
              Text(
                'Dibuat dengan Komitmen Penuh',
                style: GoogleFonts.outfit(
                  fontSize: 14.w(context),
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),
          Text(
            'Setiap baris kode, fungsi database, dan tampilan antarmuka dibangun secara intensif dengan standar tinggi untuk kemajuan digitalisasi pendidikan sekolah.',
            style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 14.h(context)),
          Divider(color: AppColors.outline.withValues(alpha: 0.1)),
          SizedBox(height: 10.h(context)),
          Text(
            'Helvetecha Developer Team © 2026',
            style: GoogleFonts.outfit(
              fontSize: 12.w(context),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
