import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/pembiasaan/screens/pembiasaan_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Scaffold bg
  content = content.replaceAll("backgroundColor: AppColors.primary,", "backgroundColor: AppColors.backgroundLight,");
  
  // AppBar
  content = content.replaceAll("backgroundColor: AppColors.primary,\n      elevation: 0,", "backgroundColor: AppColors.surface,\n      elevation: 0,");
  content = content.replaceAll("style: AppTextStyles.h4(context),\n              ),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),\n              ),");
  content = content.replaceAll("style: AppTextStyles.caption(context, fontWeight: FontWeight.w500),\n              ),", "style: AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.w500),\n              ),");
  content = content.replaceAll("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),");
  
  // Header Back Button
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n                  shape: BoxShape.circle,", "color: Colors.transparent,\n                  shape: BoxShape.circle,");
  content = content.replaceAll("Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),", "Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 20.w(context)),");
  
  // Header Texts
  // Wait, I replaced all h4 without colors above? Yes, but only one matched exactly because of indentation or context. Let's use replaceFirst.
  content = content.replaceFirst("style: AppTextStyles.h4(context),\n                ),", "style: AppTextStyles.h4(context, color: AppColors.onBackground),\n                ),"); // Pembiasaan Diri
  content = content.replaceFirst("style: AppTextStyles.caption(context, fontWeight: FontWeight.w500),\n                ),", "style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.w500),\n                ),");
  
  // Header Icon Container
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n            borderRadius: BorderRadius.circular(16.w(context)),", "color: AppColors.primaryContainer,\n            borderRadius: BorderRadius.circular(16.w(context)),");
  content = content.replaceAll("Icon(PhosphorIcons.leaf(PhosphorIconsStyle.fill), color: AppColors.primary, size: 24.w(context)),", "Icon(PhosphorIcons.leaf(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 24.w(context)),");
  
  // TabBar
  content = content.replaceAll("color: AppColors.primary,\n        borderRadius: BorderRadius.circular(100),\n        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),", "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(100),");
  content = content.replaceAll("indicator: BoxDecoration(\n          color: AppColors.primary,", "indicator: BoxDecoration(\n          color: AppColors.onSurface,");
  content = content.replaceAll("labelColor: AppColors.primary,", "labelColor: AppColors.surface,");
  content = content.replaceAll("unselectedLabelColor: AppColors.primary,", "unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.5),");

  file.writeAsStringSync(content);
}
