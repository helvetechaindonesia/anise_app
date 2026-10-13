import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_button.dart';

import '../providers/presensi_provider.dart';
import '../widgets/presensi_header_widget.dart';
import '../widgets/presensi_rekap_widget.dart';
import '../widgets/presensi_riwayat_list_widget.dart';

class PresensiScreen extends ConsumerStatefulWidget {
  const PresensiScreen({super.key});

  @override
  ConsumerState<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends ConsumerState<PresensiScreen> {
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);

    try {
      final month = ref.read(selectedMonthProvider);
      final year = ref.read(selectedYearProvider);
      final token = await SharedPrefs.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sesi login tidak valid. Silakan login kembali.',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}/attendance/export?month=$month&year=$year&token=$token',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sedang mengunduh berkas Excel (.xlsx)... Periksa notifikasi unduhan ponsel Anda.',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );

      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengunduh: $e',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Presensi',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h(context)),
              // 1. Filter Dropdown Bulan & Tahun (Auto-Aktif Bulan/Tahun ini)
              const PresensiHeaderWidget(),
              SizedBox(height: 24.h(context)),

              // 2. Kartu Rekapitulasi Statistik Kehadiran Bulanan
              const PresensiRekapWidget(),
              SizedBox(height: 28.h(context)),

              // 3. Judul Seksi Log Harian
              Row(
                children: [
                  Icon(
                    PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.bold),
                    color: AppColors.onBackground,
                    size: 20.w(context),
                  ),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'Log Catatan Kehadiran',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h(context)),

              // 4. Daftar Riwayat Baku (ItemListTile Model B)
              const PresensiRiwayatListWidget(),
              SizedBox(height: 32.h(context)),

              // 5. Tombol Unduh Rekap Baku (PillButton)
              AniseButton(
                text: _isDownloading ? 'Menyiapkan Unduhan...' : 'Unduh Rekap Bulanan',
                icon: PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold),
                variant: AniseButtonVariant.primary,
                isLoading: _isDownloading,
                onPressed: _handleDownload,
              ),
              SizedBox(height: 40.h(context)),
            ],
          ),
        ),
      ),
    );
  }
}
