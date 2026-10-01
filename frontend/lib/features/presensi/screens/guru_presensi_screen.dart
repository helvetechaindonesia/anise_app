import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import 'presensi_camera_screen.dart';
import '../../../core/utils/responsive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/presensi_header_widget.dart';
import '../widgets/presensi_rekap_widget.dart';
import '../widgets/presensi_riwayat_list_widget.dart';

class GuruPresensiScreen extends ConsumerStatefulWidget {
  const GuruPresensiScreen({super.key});

  @override
  ConsumerState<GuruPresensiScreen> createState() => _GuruPresensiScreenState();
}

class _GuruPresensiScreenState extends ConsumerState<GuruPresensiScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),
                    const PresensiHeaderWidget(),
                    SizedBox(height: 24.h(context)),
                    
                    // CARD PRESENSI CAM KHUSUS GURU
                    _buildPresensiCamCard(context),
                    SizedBox(height: 24.h(context)),
                    
                    const PresensiRekapWidget(),
                    SizedBox(height: 24.h(context)),
                    _buildSectionTitle(context, 'Log Harian Presensi', '4 Catatan Terakhir', icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.bold), isSmallSub: true),
                    SizedBox(height: 16.h(context)),
                    const PresensiRiwayatListWidget(),
                    SizedBox(height: 24.h(context)),
                    _buildDownloadButton(context),
                    SizedBox(height: 40.h(context)),
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
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Presensi Pengajar',
        style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle, {String? trailingPill, Color? trailingColor, IconData? trailingIcon, IconData? icon, bool isSmallSub = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.onBackground, size: 18.w(context)),
              SizedBox(width: 8.w(context)),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSmallSub)
                  Text(
                    title,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground),
                  ),
                if (!isSmallSub) SizedBox(height: 2.h(context)),
                Text(
                  isSmallSub ? title : subtitle,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                ),
              ],
            ),
          ],
        ),
        if (trailingPill != null && trailingColor != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
            decoration: BoxDecoration(
              color: trailingColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.trophy(PhosphorIconsStyle.fill), color: trailingColor, size: 12.w(context)),
                SizedBox(width: 6.w(context)),
                Text(
                  trailingPill,
                  style: AppTextStyles.labelSmall(context, color: trailingColor),
                ),
              ],
            ),
          )
        else if (trailingIcon != null)
          Icon(trailingIcon, color: AppColors.onBackground, size: 20.w(context))
        else if (isSmallSub)
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
          ),
      ],
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12.w(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 20.w(context)),
          SizedBox(width: 10.w(context)),
          Text(
            'Unduh Rekap Bulanan',
            style: AppTextStyles.labelLarge(context, color: AppColors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }

  Widget _buildPresensiCamCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PresensiCameraScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.w(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.scan(PhosphorIconsStyle.bold),
                color: AppColors.surface,
                size: 32.w(context),
              ),
            ),
            SizedBox(width: 16.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap Presensi',
                    style: AppTextStyles.titleMedium(context, color: AppColors.surface),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Gunakan kamera untuk presensi cepat',
                    style: AppTextStyles.labelSmall(context, color: AppColors.surface.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              color: AppColors.surface,
              size: 20.w(context),
            ),
          ],
        ),
      ),
    );
  }

}
