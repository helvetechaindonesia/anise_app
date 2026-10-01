import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/jadwal/screens/jadwal_screen.dart');
  if (!file.existsSync()) return;
  
  var content = file.readAsStringSync();
  
  // App bar text
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500)", "style: AppTextStyles.caption(context, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)");

  // Button Pilih Tanggal
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n              borderRadius: BorderRadius.circular(20.w(context)),", "color: AppColors.primary.withValues(alpha: 0.1),\n              borderRadius: BorderRadius.circular(20.w(context)),");

  // Date Selector unselected background
  content = content.replaceAll("color: isSelected ? AppColors.primary : AppColors.primary,", "color: isSelected ? AppColors.primary : AppColors.surface,");
  
  // Date Selector border
  content = content.replaceAll("border: Border.all(\n                  color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),\n                  width: 1,\n                )", "border: Border.all(\n                  color: isSelected ? AppColors.primary : AppColors.outline,\n                  width: 1,\n                )");

  // Date Selector Text (Day)
  content = content.replaceAll("color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary", "color: isSelected ? AppColors.onPrimary.withValues(alpha: 0.8) : AppColors.onSurfaceVariant");
  
  // Date Selector Text (Date)
  content = content.replaceAll("color: isSelected ? AppColors.primary : AppColors.primary", "color: isSelected ? AppColors.onPrimary : AppColors.onSurface");
  
  // Date Selector Dot
  content = content.replaceAll("color: AppColors.primary,\n                        shape: BoxShape.circle,", "color: AppColors.onPrimary,\n                        shape: BoxShape.circle,");
  
  // Empty state icon
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5)", "color: AppColors.onBackground.withValues(alpha: 0.2)");
  
  // Empty state text
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.w500)", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5), fontWeight: FontWeight.w500)");

  file.writeAsStringSync(content);
}
