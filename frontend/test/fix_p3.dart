import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/widgets/presensi_rekap_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Outer container color for _buildCombinedStatsCard
  content = content.replaceAll("color: AppColors.surface,\n        borderRadius: BorderRadius.circular(24.w(context)),\n        border: Border.all(color: AppColors.outline),", "color: AppColors.primaryContainer,\n        borderRadius: BorderRadius.circular(24.w(context)),");
  
  // For the toggle: AppColors.backgroundLight remains. 
  // Inside toggle, _isPergerakanMode ? AppColors.surface -> AppColors.surface
  // The toggle text colors AppColors.onSurface -> AppColors.onPrimaryContainer
  content = content.replaceAll("color: _isPergerakanMode ? AppColors.onSurface : AppColors.onBackground.withValues(alpha: 0.5),", "color: _isPergerakanMode ? AppColors.onPrimaryContainer : AppColors.onPrimaryContainer.withValues(alpha: 0.5),");
  content = content.replaceAll("color: !_isPergerakanMode ? AppColors.onSurface : AppColors.onBackground.withValues(alpha: 0.5),", "color: !_isPergerakanMode ? AppColors.onPrimaryContainer : AppColors.onPrimaryContainer.withValues(alpha: 0.5),");
  
  // _buildCombinedStatItem texts
  content = content.replaceAll("AppTextStyles.h1(context, color: AppColors.onSurface)", "AppTextStyles.h1(context, color: AppColors.onPrimaryContainer)");
  content = content.replaceAll("AppTextStyles.overline(context, color: AppColors.onSurface.withValues(alpha: 0.5)", "AppTextStyles.overline(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.5)");

  // Icon itemColor inside _buildCombinedStatItem
  // Color itemColor = isAlert ? AppColors.error : AppColors.primary; -> isAlert ? AppColors.error : AppColors.onPrimaryContainer;
  content = content.replaceAll("Color itemColor = isAlert ? AppColors.error : AppColors.primary;", "Color itemColor = isAlert ? AppColors.error : AppColors.onPrimaryContainer;");

  // _buildKetidakhadiranSummary
  content = content.replaceAll("color: AppColors.surface,\n          borderRadius: BorderRadius.circular(12.w(context)),\n          border: Border.all(color: AppColors.outline),", "color: AppColors.primaryContainer,\n          borderRadius: BorderRadius.circular(12.w(context)),");
  
  content = content.replaceAll("AppTextStyles.bodySmall(context, color: AppColors.onSurface,", "AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer,");
  content = content.replaceAll("AppTextStyles.overline(context, color: AppColors.onSurface.withValues(alpha: 0.7),", "AppTextStyles.overline(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7),");
  content = content.replaceAll("Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer");
  content = content.replaceAll("color: AppColors.onSurface,\n                  size: 16.w(context),", "color: AppColors.onPrimaryContainer,\n                  size: 16.w(context),");

  file.writeAsStringSync(content);
}
