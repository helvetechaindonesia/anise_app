import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/presensi_provider.dart';

class PresensiRekapWidget extends ConsumerStatefulWidget {
  const PresensiRekapWidget({super.key});

  @override
  ConsumerState<PresensiRekapWidget> createState() => _PresensiRekapWidgetState();
}

class _PresensiRekapWidgetState extends ConsumerState<PresensiRekapWidget> {
  bool _isKetidakhadiranExpanded = false;

  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(presensiSummaryProvider);
    final summary = summaryAsync.value ?? {};

    final currentMonthIndex = ref.watch(selectedMonthProvider) - 1;
    final currentYear = ref.watch(selectedYearProvider);
    final monthName = (currentMonthIndex >= 0 && currentMonthIndex < _months.length)
        ? _months[currentMonthIndex]
        : _months[DateTime.now().month - 1];

    final hadirPenuh = summary['hadir_penuh']?.toString() ?? '0';
    final terlambat = summary['terlambat']?.toString() ?? '0';
    final pulangAwal = summary['pulang_awal']?.toString() ?? '0';
    final kembali = summary['kembali']?.toString() ?? '0';
    final sakit = summary['sakit']?.toString() ?? '0';
    final izin = summary['izin']?.toString() ?? '0';
    final alpha = summary['alpha']?.toString() ?? '0';

    return Column(
      children: [
        _buildHadirTerlambatRow(context, hadirPenuh, terlambat),
        SizedBox(height: 24.h(context)),
        _buildCombinedStatsCard(context, pulangAwal, kembali),
        SizedBox(height: 24.h(context)),
        _buildKetidakhadiranSummary(context, '$monthName $currentYear', sakit, izin, alpha),
      ],
    );
  }

  Widget _buildHadirTerlambatRow(BuildContext context, String hadirCount, String terlambatCount) {
    return Row(
      children: [
        // 1. Card Hadir Penuh (Ikon Dinamis Check Circle)
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onBackground.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w(context),
                  height: 42.w(context),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                      color: AppColors.onPrimary,
                      size: 22.w(context),
                    ),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hadir Penuh',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hadirCount,
                            style: AppTextStyles.titleLarge(context, color: AppColors.onSurface),
                          ),
                          SizedBox(width: 4.w(context)),
                          Text(
                            'Hari',
                            style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),

        // 2. Card Terlambat (Ikon Dinamis Warning Circle)
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onBackground.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42.w(context),
                  height: 42.w(context),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                      color: AppColors.onPrimary,
                      size: 22.w(context),
                    ),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terlambat',
                        style: AppTextStyles.labelSmall(context, color: AppColors.error),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            terlambatCount,
                            style: AppTextStyles.titleLarge(context, color: AppColors.error),
                          ),
                          SizedBox(width: 4.w(context)),
                          Text(
                            'Hari',
                            style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedStatsCard(BuildContext context, String paCount, String kembaliCount) {
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

  Widget _buildKetidakhadiranSummary(BuildContext context, String periodeStr, String sakit, String izin, String alpha) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isKetidakhadiranExpanded = !_isKetidakhadiranExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16.w(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.onBackground.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
                  color: AppColors.onPrimaryContainer,
                  size: 18.w(context),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekap Ketidakhadiran',
                        style: AppTextStyles.titleSmall(context, color: AppColors.onPrimaryContainer).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        periodeStr,
                        style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isKetidakhadiranExpanded
                      ? PhosphorIcons.caretUp(PhosphorIconsStyle.bold)
                      : PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                  color: AppColors.onPrimaryContainer,
                  size: 16.w(context),
                ),
              ],
            ),
            if (_isKetidakhadiranExpanded) ...[
              SizedBox(height: 16.h(context)),
              Container(
                padding: EdgeInsets.all(14.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Column(
                  children: [
                    _buildSiaRow(context, 'Sakit', '$sakit Hari', AppColors.primary, PhosphorIcons.firstAid(PhosphorIconsStyle.fill)),
                    Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), height: 16.h(context)),
                    _buildSiaRow(context, 'Izin', '$izin Hari', AppColors.secondary, PhosphorIcons.envelope(PhosphorIconsStyle.fill)),
                    Divider(color: AppColors.outlineVariant.withValues(alpha: 0.5), height: 16.h(context)),
                    _buildSiaRow(context, 'Alpha', '$alpha Hari', AppColors.error, PhosphorIcons.xCircle(PhosphorIconsStyle.fill)),
                  ],
                ),
              ),
            ]
          ],
        ),
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
