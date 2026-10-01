import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class PresensiRekapWidget extends StatefulWidget {
  const PresensiRekapWidget({super.key});

  @override
  State<PresensiRekapWidget> createState() => _PresensiRekapWidgetState();
}

class _PresensiRekapWidgetState extends State<PresensiRekapWidget> {
  bool _isPergerakanMode = true;
  bool _isKetidakhadiranExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHadirTerlambatRow(context),
        SizedBox(height: 24.h(context)),
        _buildCombinedStatsCard(context),
        SizedBox(height: 24.h(context)),
        _buildKetidakhadiranSummary(context),
      ],
    );
  }

  Widget _buildHadirTerlambatRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              boxShadow: [
                BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w(context),
                  height: 40.w(context),
                  decoration: BoxDecoration(
                    color: AppColors.onSurface,
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                  child: Center(
                    child: Text('H', style: AppTextStyles.titleLarge(context, color: AppColors.surface)),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hadir Penuh', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('22', style: AppTextStyles.titleLarge(context, color: AppColors.onSurface)),
                        SizedBox(width: 4.w(context)),
                        Text('Hari', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              boxShadow: [
                BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w(context),
                  height: 40.w(context),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                  child: Center(
                    child: Text('T', style: AppTextStyles.titleLarge(context, color: AppColors.surface)),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terlambat', style: AppTextStyles.labelSmall(context, color: AppColors.error)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('1', style: AppTextStyles.titleLarge(context, color: AppColors.error)),
                        SizedBox(width: 4.w(context)),
                        Text('Hari', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedStatsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h(context), horizontal: 20.w(context)),
        child: Row(
          children: [
            Expanded(
              child: _buildCombinedStatItem(context, PhosphorIcons.plusSquare(PhosphorIconsStyle.fill), 'PA', '1', 'Pulang Awal', isAlert: true),
            ),
            Container(width: 1, height: 40.h(context), color: AppColors.outline),
            Expanded(
              child: _buildCombinedStatItem(context, PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), 'Kembali', '1', 'Tervalidasi'),
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
        Icon(icon, color: itemColor, size: 18.w(context)),
        SizedBox(height: 8.h(context)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimaryContainer),
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
            style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildKetidakhadiranSummary(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isKetidakhadiranExpanded = !_isKetidakhadiranExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(12.w(context)),
          boxShadow: [
            BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 16.w(context)),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ketidakhadiran', style: AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer)),
                      Text('Oktober 2025', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                Icon(
                  _isKetidakhadiranExpanded ? PhosphorIcons.caretUp(PhosphorIconsStyle.bold) : PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                  color: AppColors.onPrimaryContainer,
                  size: 16.w(context),
                ),
              ],
            ),
            if (_isKetidakhadiranExpanded) ...[
              SizedBox(height: 16.h(context)),
              Container(
                padding: EdgeInsets.all(12.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8.w(context)),
                ),
                child: Column(
                  children: [
                    _buildSiaRow(context, 'Sakit', '0 Hari', AppColors.primary, PhosphorIcons.thermometer(PhosphorIconsStyle.fill)),
                    Divider(color: AppColors.outline, height: 16.h(context)),
                    _buildSiaRow(context, 'Izin', '1 Hari', AppColors.primary, PhosphorIcons.envelope(PhosphorIconsStyle.fill)),
                    Divider(color: AppColors.outline, height: 16.h(context)),
                    _buildSiaRow(context, 'Alpha', '0 Hari', AppColors.error, PhosphorIcons.xCircle(PhosphorIconsStyle.fill)),
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
                color: color.withValues(alpha: 0.2),
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
          style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
        ),
      ],
    );
  }
}

