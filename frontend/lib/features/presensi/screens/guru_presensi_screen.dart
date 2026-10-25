import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import 'presensi_camera_screen.dart';

import '../providers/presensi_provider.dart';
import '../widgets/presensi_header_widget.dart';
import '../widgets/presensi_rekap_widget.dart';
import '../widgets/presensi_riwayat_list_widget.dart';

class GuruPresensiScreen extends ConsumerStatefulWidget {
  const GuruPresensiScreen({super.key});

  @override
  ConsumerState<GuruPresensiScreen> createState() => _GuruPresensiScreenState();
}

class _GuruPresensiScreenState extends ConsumerState<GuruPresensiScreen> {
  bool _isDownloading = false;

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final month = ref.read(selectedMonthProvider);
      final year = ref.read(selectedYearProvider);
      final dio = ref.read(dioProvider);

      final response = await dio.get<List<int>>(
        '/attendance/export',
        queryParameters: {'month': month, 'year': year},
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Data berkas dari server kosong.');
      }

      final bytes = Uint8List.fromList(response.data!);
      String fileName = 'Rekap_Presensi_Pegawai_${month}_$year.xlsx';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan Rekap Presensi Tenaga Pendidik',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: bytes,
      );

      if (result != null && mounted) {
        AniseFeedbackDialog.showSuccess(
          context,
          title: 'Unduhan Berhasil',
          message: 'Berkas rekap presensi berhasil disimpan.',
        );
      }
    } catch (e) {
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Mengunduh',
          message: 'Terjadi kendala saat mengunduh berkas: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /// Menentukan status real-time siklus kerja tenaga pendidik berdasarkan jam saat ini
  Map<String, dynamic> _getCurrentShiftStatus() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final currentMinutes = hour * 60 + minute;

    // 06:00 - 07:00 (Hadir Tepat)
    if (currentMinutes >= 360 && currentMinutes <= 420) {
      return {
        'title': 'Presensi Masuk Tepat Waktu (H)',
        'subtitle': 'Batas waktu tepat sampai 07:00 WIB',
        'badge': '06:00 - 07:00 WIB',
        'color': AppColors.secondary,
        'icon': PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
      };
    }
    // 07:01 - 12:00 (Terlambat)
    else if (currentMinutes > 420 && currentMinutes <= 720) {
      return {
        'title': 'Presensi Masuk Terlambat (T)',
        'subtitle': 'Batas akhir absen masuk pukul 12:00 WIB',
        'badge': '07:01 - 12:00 WIB',
        'color': AppColors.warning,
        'icon': PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
      };
    }
    // 12:01 - 15:59 (Jam Dinas / Pulang Awal - Kembali)
    else if (currentMinutes > 720 && currentMinutes < 960) {
      return {
        'title': 'Siklus Keluar/Kembali Dinas (PA / K)',
        'subtitle': 'Tap ganjil = Pulang Awal, Tap genap = Kembali',
        'badge': 'Jam Kerja Aktif',
        'color': AppColors.info,
        'icon': PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.bold),
      };
    }
    // 16:00 - 18:00 (Jam Pulang Resmi)
    else if (currentMinutes >= 960 && currentMinutes <= 1080) {
      return {
        'title': 'Presensi Pulang Resmi (PULANG)',
        'subtitle': 'Batas waktu presensi pulang sampai 18:00 WIB',
        'badge': '16:00 - 18:00 WIB',
        'color': AppColors.secondary,
        'icon': PhosphorIcons.house(PhosphorIconsStyle.fill),
      };
    }
    // Di luar jam dinas (< 06:00 atau > 18:00)
    else {
      return {
        'title': 'Di Luar Jam Presensi',
        'subtitle': currentMinutes < 360 ? 'Presensi masuk buka pukul 06:00 WIB' : 'Jam presensi telah berakhir (TAP)',
        'badge': 'Tutup',
        'color': AppColors.error,
        'icon': PhosphorIcons.clock(PhosphorIconsStyle.fill),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = _getCurrentShiftStatus();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            AniseAppBar(
              title: 'Presensi Tenaga Pendidik',
              leading: IconButton(
                icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),
                    const PresensiHeaderWidget(),
                    SizedBox(height: 20.h(context)),
                    
                    // CARD 1: BANNER INFORMASI SHIFT REAL-TIME TENAGA PENDIDIK
                    _buildShiftBanner(context, shift),
                    SizedBox(height: 16.h(context)),

                    // CARD 2: TOMBOL PRESENSI CAM DENGAN SIKLUS REAL-TIME
                    _buildPresensiCamCard(context, shift),
                    SizedBox(height: 24.h(context)),
                    
                    // KARTU REKAP DINAMIS TENAGA PENDIDIK (H, T, TAM, TAP, PA, K, KWK, Cuti, Izin, Sakit, Alpha)
                    const PresensiRekapWidget(),
                    SizedBox(height: 24.h(context)),
                    
                    _buildSectionTitle(
                      context,
                      'Riwayat Kehadiran Pegawai',
                      'Catatan Masuk, Pulang, dan Izin Dinas',
                      icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.bold),
                      isSmallSub: true,
                    ),
                    SizedBox(height: 16.h(context)),
                    
                    // DAFTAR RIWAYAT DENGAN LOGIKA TENAGA PENDIDIK
                    const PresensiRiwayatListWidget(),
                    SizedBox(height: 24.h(context)),
                    
                    // TOMBOL UNDUH LAPORAN EXCEL
                    AniseButton(
                      text: 'Unduh Rekap Presensi (.xlsx)',
                      leadingIcon: PhosphorIcons.fileXls(PhosphorIconsStyle.bold),
                      isLoading: _isDownloading,
                      onPressed: _handleDownload,
                    ),
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

  Widget _buildShiftBanner(BuildContext context, Map<String, dynamic> shift) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: (shift['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: (shift['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(shift['icon'] as IconData, color: shift['color'] as Color, size: 22.w(context)),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Siklus Presensi Saat Ini',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 2.h(context)),
                      decoration: BoxDecoration(
                        color: shift['color'] as Color,
                        borderRadius: BorderRadius.circular(6.w(context)),
                      ),
                      child: Text(
                        shift['badge'] as String,
                        style: AppTextStyles.labelSmall(context, color: AppColors.primaryDark).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  shift['title'] as String,
                  style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  shift['subtitle'] as String,
                  style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresensiCamCard(BuildContext context, Map<String, dynamic> shift) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PresensiCameraScreen()),
        );
        if (result == true) {
          ref.invalidate(presensiSummaryProvider);
          ref.invalidate(presensiLogProvider);
        }
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
                PhosphorIcons.camera(PhosphorIconsStyle.bold),
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
                    'Presensi Cam Pegawai',
                    style: AppTextStyles.titleMedium(context, color: AppColors.surface),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Verifikasi Biometrik AI 512-D & Geofence',
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

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle, {IconData? icon, bool isSmallSub = false}) {
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
                Text(
                  title,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
