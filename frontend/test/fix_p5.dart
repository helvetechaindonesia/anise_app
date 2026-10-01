import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/widgets/presensi_rekap_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // 1 & 2 & 3: _buildHadirTerlambatRow
  // Card border removal:
  content = content.replaceAll("border: Border.all(color: AppColors.outline),\n              boxShadow", "boxShadow");
  
  // H Block background: secondary -> onSurface
  content = content.replaceAll("color: AppColors.secondary,\n                    borderRadius: BorderRadius.circular(10.w(context)),", "color: AppColors.onSurface,\n                    borderRadius: BorderRadius.circular(10.w(context)),");
  // H Block text: onSecondary -> surface
  content = content.replaceAll("Text('H', style: AppTextStyles.h3(context, color: AppColors.onSecondary))", "Text('H', style: AppTextStyles.h3(context, color: AppColors.surface))");
  
  // T Block text: onPrimary -> surface
  content = content.replaceAll("Text('T', style: AppTextStyles.h3(context, color: AppColors.onPrimary))", "Text('T', style: AppTextStyles.h3(context, color: AppColors.surface))");
  
  // Hadir texts: onSurface (already onSurface, except "Hadir Penuh" was onSurface with alpha)
  content = content.replaceAll("Text('Hadir Penuh', style: AppTextStyles.overline(context, color: AppColors.onSurface.withValues(alpha: 0.7)", "Text('Hadir Penuh', style: AppTextStyles.overline(context, color: AppColors.onSurface");
  
  // Terlambat texts:
  content = content.replaceAll("Text('Terlambat', style: AppTextStyles.overline(context, color: AppColors.onSurface.withValues(alpha: 0.7)", "Text('Terlambat', style: AppTextStyles.overline(context, color: AppColors.error");

  // 4: Toggle Container
  // Container background: AppColors.backgroundLight -> AppColors.surface
  content = content.replaceAll("color: AppColors.backgroundLight,\n                borderRadius: BorderRadius.circular(20.w(context)),", "color: AppColors.surface,\n                borderRadius: BorderRadius.circular(20.w(context)),");
  
  // Active thumb: _isPergerakanMode ? AppColors.surface -> _isPergerakanMode ? AppColors.onSurface
  content = content.replaceAll("color: _isPergerakanMode ? AppColors.surface : AppColors.transparent,", "color: _isPergerakanMode ? AppColors.onSurface : AppColors.transparent,");
  content = content.replaceAll("color: !_isPergerakanMode ? AppColors.surface : AppColors.transparent,", "color: !_isPergerakanMode ? AppColors.onSurface : AppColors.transparent,");
  
  // Texts in toggle
  content = content.replaceAll("color: _isPergerakanMode ? AppColors.onPrimaryContainer : AppColors.onPrimaryContainer.withValues(alpha: 0.5)", "color: _isPergerakanMode ? AppColors.surfaceVariant : AppColors.onSurface.withValues(alpha: 0.5)");
  content = content.replaceAll("color: !_isPergerakanMode ? AppColors.onPrimaryContainer : AppColors.onPrimaryContainer.withValues(alpha: 0.5)", "color: !_isPergerakanMode ? AppColors.surfaceVariant : AppColors.onSurface.withValues(alpha: 0.5)");

  file.writeAsStringSync(content);
}
