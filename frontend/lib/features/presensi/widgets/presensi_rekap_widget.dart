import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_expandable_card.dart';
import '../../../../core/widgets/card_info.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/presensi_provider.dart';

class PresensiRekapWidget extends ConsumerWidget {
  final bool? isTenagaPendidik;
  const PresensiRekapWidget({super.key, this.isTenagaPendidik});

  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(presensiSummaryProvider);
    final summary = summaryAsync.value ?? {};

    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);

    final String periodeStr;
    if (selectedMonth == 0 && selectedYear == 0) {
      periodeStr = 'Semua Periode';
    } else if (selectedMonth == 0) {
      periodeStr = 'Semua Bulan $selectedYear';
    } else if (selectedYear == 0) {
      final mName = (selectedMonth >= 1 && selectedMonth <= 12) ? _months[selectedMonth - 1] : '';
      periodeStr = '$mName (Semua Tahun)';
    } else {
      final mName = (selectedMonth >= 1 && selectedMonth <= 12) ? _months[selectedMonth - 1] : '';
      periodeStr = '$mName $selectedYear';
    }

    // Cek role user: prioritaskan parameter eksplisit, kemudian authState, lalu summary
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role;
    final bool resolvedIsTenagaPendidik = isTenagaPendidik ??
        (summary['user_type'] == 'TENAGA_PENDIDIK' ||
         (userRole != null && userRole != UserRole.siswa));

    final hadirPenuh = (summary['hadir'] ?? summary['hadir_penuh'])?.toString() ?? '0';
    final terlambat = summary['terlambat']?.toString() ?? '0';
    final tidakAbsenMasuk = summary['tidak_absen_masuk']?.toString() ?? '0';
    final tidakAbsenPulang = summary['tidak_absen_pulang']?.toString() ?? '0';
    final pulangAwal = summary['pulang_awal']?.toString() ?? '0';
    final kembali = summary['kembali']?.toString() ?? '0';
    final kwkJam = summary['kwk_jam']?.toString() ?? '0';
    final sakit = summary['sakit']?.toString() ?? '0';
    final izin = summary['izin']?.toString() ?? '0';
    final cuti = summary['cuti']?.toString() ?? '0';
    final alpha = summary['alpha']?.toString() ?? '0';

    if (resolvedIsTenagaPendidik) {
      return Column(
        children: [
          _buildHadirTerlambatRow(context, hadirPenuh, terlambat),
          SizedBox(height: 16.h(context)),
          // CARD GABUNGAN: TAM, TAP, PA, Kembali (+ KWK jika ada)
          _buildPegawaiCombinedStatsCard(
            context,
            paCount: pulangAwal,
            kembaliCount: kembali,
            tamCount: tidakAbsenMasuk,
            tapCount: tidakAbsenPulang,
            kwkJam: kwkJam,
          ),
          SizedBox(height: 24.h(context)),
          _buildKetidakhadiranSummary(context, periodeStr, sakit, izin, alpha, cuti: cuti),
        ],
      );
    }

    return Column(
      children: [
        _buildHadirTerlambatRow(context, hadirPenuh, terlambat),
        SizedBox(height: 24.h(context)),
        _buildCombinedStatsCard(context, pulangAwal, kembali),
        SizedBox(height: 24.h(context)),
        _buildKetidakhadiranSummary(context, periodeStr, sakit, izin, alpha),
      ],
    );
  }

  Widget _buildPegawaiCombinedStatsCard(
    BuildContext context, {
    required String paCount,
    required String kembaliCount,
    required String tamCount,
    required String tapCount,
    String? kwkJam,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h(context), horizontal: 16.w(context)),
        child: Row(
          children: [
            // PA
            Expanded(
              child: _buildCombinedStatItem(
                context,
                PhosphorIcons.clockAfternoon(PhosphorIconsStyle.fill),
                'PA',
                paCount,
                'Pulang Awal',
                isAlert: paCount != '0',
              ),
            ),
            Container(
              width: 1,
              height: 40.h(context),
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
            ),
            // Kembali
            Expanded(
              child: _buildCombinedStatItem(
                context,
                PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.bold),
                'Kembali',
                kembaliCount,
                'Tervalidasi',
              ),
            ),
            Container(
              width: 1,
              height: 40.h(context),
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
            ),
            // TAM
            Expanded(
              child: _buildCombinedStatItem(
                context,
                PhosphorIcons.clockClockwise(PhosphorIconsStyle.fill),
                'TAM',
                tamCount,
                'Tanpa Masuk',
                isAlert: tamCount != '0',
              ),
            ),
            Container(
              width: 1,
              height: 40.h(context),
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
            ),
            // TAP
            Expanded(
              child: _buildCombinedStatItem(
                context,
                PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
                'TAP',
                tapCount,
                'Tanpa Pulang',
                isAlert: tapCount != '0',
              ),
            ),
            if (kwkJam != null && kwkJam != '0' && kwkJam != '0.0') ...[
              Container(
                width: 1,
                height: 40.h(context),
                color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildCombinedStatItem(
                  context,
                  PhosphorIcons.timer(PhosphorIconsStyle.fill),
                  'KWK',
                  '$kwkJam j',
                  'Kurang Jam',
                  isAlert: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHadirTerlambatRow(BuildContext context, String hadirCount, String terlambatCount) {
    return Row(
      children: [
        // 1. Card Hadir Penuh (CardInfo Baku)
        Expanded(
          child: CardInfo(
            title: 'Hadir Penuh',
            value: hadirCount,
            unit: 'Hari',
            icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            iconBgColor: AppColors.primary,
            iconColor: AppColors.onPrimary,
          ),
        ),
        SizedBox(width: 12.w(context)),

        // 2. Card Terlambat (CardInfo Baku)
        Expanded(
          child: CardInfo(
            title: 'Terlambat',
            value: terlambatCount,
            unit: 'Hari',
            icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
            iconBgColor: AppColors.error,
            iconColor: AppColors.onPrimary,
            titleColor: AppColors.error,
            valueColor: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedStatsCard(BuildContext context, String paCount, String kembaliCount, {String? kwkJam}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h(context), horizontal: 20.w(context)),
        child: Row(
          children: [
            Expanded(
              child: _buildCombinedStatItem(
                context,
                PhosphorIcons.clockAfternoon(PhosphorIconsStyle.fill),
                'PA',
                paCount,
                'Pulang Awal',
                isAlert: paCount != '0',
              ),
            ),
            Container(
              width: 1,
              height: 40.h(context),
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
            ),
            Expanded(
              child: _buildCombinedStatItem(
                context,
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                'Kembali',
                kembaliCount,
                'Tervalidasi',
              ),
            ),
            if (kwkJam != null) ...[
              Container(
                width: 1,
                height: 40.h(context),
                color: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildCombinedStatItem(
                  context,
                  PhosphorIcons.timer(PhosphorIconsStyle.fill),
                  'KWK',
                  '$kwkJam Jam',
                  'Kurang Kerja',
                  isAlert: kwkJam != '0' && kwkJam != '0.0',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedStatItem(BuildContext context, IconData icon, String shortLabel, String value, String desc, {bool isAlert = false}) {
    Color itemColor = isAlert ? AppColors.error : AppColors.onPrimaryContainer;
    return Column(
      children: [
        Icon(icon, color: itemColor, size: 20.w(context)),
        SizedBox(height: 8.h(context)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimaryContainer).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 4.h(context)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            shortLabel,
            style: AppTextStyles.labelMedium(context, color: itemColor),
          ),
        ),
        SizedBox(height: 2.h(context)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            desc,
            style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }

  Widget _buildKetidakhadiranSummary(BuildContext context, String periodeStr, String sakit, String izin, String alpha, {String? cuti}) {
    return AniseExpandableCard(
      title: 'Rekap Ketidakhadiran & Cuti',
      subtitle: periodeStr,
      icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
      child: Column(
        children: [
          _buildSiaRow(context, 'Sakit (S)', '$sakit Hari', AppColors.primary, PhosphorIcons.firstAid(PhosphorIconsStyle.fill)),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), height: 16.h(context)),
          _buildSiaRow(context, 'Izin Dinas / Pribadi (I)', '$izin Hari', AppColors.secondary, PhosphorIcons.envelope(PhosphorIconsStyle.fill)),
          if (cuti != null) ...[
            Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), height: 16.h(context)),
            _buildSiaRow(context, 'Cuti Tahunan / Bersama (C)', '$cuti Hari', AppColors.warning, PhosphorIcons.calendarStar(PhosphorIconsStyle.fill)),
          ],
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), height: 16.h(context)),
          _buildSiaRow(context, 'Alpha (A)', '$alpha Hari', AppColors.error, PhosphorIcons.xCircle(PhosphorIconsStyle.fill)),
        ],
      ),
    );
  }

  Widget _buildSiaRow(BuildContext context, String label, String value, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w(context)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 14.w(context)),
            ),
            SizedBox(width: 12.w(context)),
            Text(
              label,
              style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
