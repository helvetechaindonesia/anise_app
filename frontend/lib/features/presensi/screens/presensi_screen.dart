import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_button.dart';

import '../widgets/presensi_header_widget.dart';
import '../widgets/presensi_rekap_widget.dart';
import '../widgets/presensi_riwayat_list_widget.dart';

class PresensiScreen extends ConsumerStatefulWidget {
  const PresensiScreen({super.key});

  @override
  ConsumerState<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends ConsumerState<PresensiScreen> {
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
                text: 'Unduh Rekap Bulanan',
                icon: PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold),
                variant: AniseButtonVariant.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Rekap presensi bulan ini sedang disiapkan...',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
                      ),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              SizedBox(height: 40.h(context)),
            ],
          ),
        ),
      ),
    );
  }
}
