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
      final dio = ref.read(dioProvider);

      // Unduh binary data langsung via background HTTP Dio (tanpa redirect/buka browser)
      final response = await dio.get<List<int>>(
        '/attendance/export',
        queryParameters: {
          'month': month,
          'year': year,
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Data berkas dari server kosong.');
      }

      final bytes = Uint8List.fromList(response.data!);

      // Ekstrak nama file dari header Content-Disposition bila tersedia
      String fileName = 'Rekap_Presensi_${month}_$year.xlsx';
      final contentDisposition = response.headers.value('content-disposition');
      if (contentDisposition != null) {
        final match = RegExp(r'filename="?([^";]+)"?').firstMatch(contentDisposition);
        if (match != null && match.group(1) != null) {
          fileName = match.group(1)!;
        }
      }

      // Gunakan FilePicker.saveFile (SAF natif Android) agar file resmi terdaftar di sistem Android
      final savedUri = await FilePicker.saveFile(
        dialogTitle: 'Simpan Rekap Presensi',
        fileName: fileName,
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      if (!mounted) return;

      if (savedUri != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: AppColors.onPrimary,
                  size: 20.w(context),
                ),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Text(
                    'Berhasil menyimpan $fileName!',
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Penyimpanan berkas dibatalkan.',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.onSurfaceVariant,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengunduh berkas: $e',
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
