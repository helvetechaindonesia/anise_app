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
          _buildKetidakhadiranSummary(context, periodeStr, sakit, alpha, cuti: cuti),
        ],
      );
    }

    return Column(
      children: [
        _buildHadirTerlambatRow(context, hadirPenuh, terlambat),
        SizedBox(height: 24.h(context)),
        _buildCombinedStatsCard(context, pulangAwal, kembali),
        SizedBox(height: 24.h(context)),
        _buildKetidakhadiranSummary(context, periodeStr, sakit, alpha),
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
    final bool hasKwk = kwkJam != null && kwkJam != '0' && kwkJam != '0.0';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.w(context)),
                ),
                child: Icon(
                  PhosphorIcons.clockUser(PhosphorIconsStyle.bold),
                  color: AppColors.primary,
                  size: 18.w(context),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penyimpangan & Izin Jam Kerja',
                      style: AppTextStyles.titleSmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Monitoring kedisiplinan jam dinas harian',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),

          // Grid 2 Kolom yang lega dan proporsional
          Row(
            children: [
              Expanded(
                child: _buildPegawaiStatBox(
                  context,
                  title: 'Pulang Awal',
                  badge: 'PA',
                  value: paCount,
                  unit: 'Kali',
                  icon: PhosphorIcons.clockAfternoon(PhosphorIconsStyle.fill),
                  iconBgColor: paCount != '0'
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                  iconColor: paCount != '0' ? AppColors.error : AppColors.primary,
                  isAlert: paCount != '0',
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: _buildPegawaiStatBox(
                  context,
                  title: 'Kembali Dinas',
                  badge: 'K',
                  value: kembaliCount,
                  unit: 'Kali',
                  icon: PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.bold),
                  iconBgColor: AppColors.secondary.withValues(alpha: 0.12),
                  iconColor: AppColors.secondary,
                  isAlert: false,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          Row(
            children: [
              Expanded(
                child: _buildPegawaiStatBox(
                  context,
                  title: 'Tanpa Masuk',
                  badge: 'TAM',
                  value: tamCount,
                  unit: 'Hari',
                  icon: PhosphorIcons.clockClockwise(PhosphorIconsStyle.fill),
                  iconBgColor: tamCount != '0'
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                  iconColor: tamCount != '0' ? AppColors.error : AppColors.primary,
                  isAlert: tamCount != '0',
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: _buildPegawaiStatBox(
                  context,
                  title: 'Tanpa Pulang',
                  badge: 'TAP',
                  value: tapCount,
                  unit: 'Hari',
                  icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill),
                  iconBgColor: tapCount != '0'
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.08),
                  iconColor: tapCount != '0' ? AppColors.error : AppColors.primary,
                  isAlert: tapCount != '0',
                ),
              ),
            ],
          ),

          // Jika ada data KWK (Kurang Waktu Kerja)
          if (hasKwk) ...[
            SizedBox(height: 12.h(context)),
            _buildPegawaiStatBox(
              context,
              title: 'Kurang Waktu Kerja',
              badge: 'KWK',
              value: kwkJam,
              unit: 'Jam',
              icon: PhosphorIcons.timer(PhosphorIconsStyle.fill),
              iconBgColor: AppColors.warning.withValues(alpha: 0.15),
              iconColor: AppColors.warning,
              isAlert: true,
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPegawaiStatBox(
    BuildContext context, {
    required String title,
    required String badge,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isAlert,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w(context),
        vertical: 12.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14.w(context)),
        border: Border.all(
          color: isAlert
              ? AppColors.error.withValues(alpha: 0.25)
              : AppColors.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w(context)),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.w(context)),
          ),
          SizedBox(width: 10.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w(context), vertical: 1.5.h(context)),
                      decoration: BoxDecoration(
                        color: isAlert ? AppColors.error.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.w(context)),
                      ),
                      child: Text(
                        badge,
                        style: AppTextStyles.labelSmall(context).copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isAlert ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w(context)),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h(context)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.titleMedium(context).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: isAlert ? AppColors.error : AppColors.onSurface,
                      ),
                    ),
                    SizedBox(width: 4.w(context)),
                    Text(
                      unit,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        fontSize: 10.5,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildKetidakhadiranSummary(BuildContext context, String periodeStr, String sakit, String alpha, {String? cuti}) {
    return AniseExpandableCard(
      title: 'Rekap Ketidakhadiran & Cuti',
      subtitle: periodeStr,
      icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
      child: Column(
        children: [
          _buildSiaRow(context, 'Sakit (S)', '$sakit Hari', AppColors.primary, PhosphorIcons.firstAid(PhosphorIconsStyle.fill)),
          if (cuti != null) ...[
            Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), height: 16.h(context)),
            _buildSiaRow(context, 'Cuti (C)', '$cuti Hari', AppColors.warning, PhosphorIcons.calendarStar(PhosphorIconsStyle.fill)),
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
