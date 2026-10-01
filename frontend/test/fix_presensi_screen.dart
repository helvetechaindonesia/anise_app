import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/screens/presensi_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Scaffold bg
  content = content.replaceAll("backgroundColor: AppColors.primary,", "backgroundColor: AppColors.backgroundLight, // WAS primary");
  
  // AppBar bg (will also match the one in SliverAppBar if I use specific text)
  content = content.replaceAll("SliverAppBar(\n      pinned: true,\n      backgroundColor: AppColors.backgroundLight, // WAS primary", "SliverAppBar(\n      pinned: true,\n      backgroundColor: AppColors.surface,");
  
  // Inside AppBar:
  content = content.replaceAll("AppTextStyles.h4(context, color: AppColors.primary)", "AppTextStyles.h4(context, color: AppColors.onSurface)");
  content = content.replaceAll("AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500)", "AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.w500)");
  content = content.replaceAll("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface");
  
  // Inside _buildSectionTitle
  content = content.replaceAll("Icon(icon, color: AppColors.primary,", "Icon(icon, color: AppColors.onBackground,");
  content = content.replaceAll("AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.w800)", "AppTextStyles.overline(context, color: AppColors.onBackground, fontWeight: FontWeight.w800)");
  content = content.replaceAll("AppTextStyles.h4(context, color: AppColors.primary)", "AppTextStyles.h4(context, color: AppColors.onBackground)");
  content = content.replaceAll("Icon(trailingIcon, color: AppColors.primary,", "Icon(trailingIcon, color: AppColors.onBackground,");
  content = content.replaceAll("AppTextStyles.bodySmall(context, color: AppColors.primary, fontWeight: FontWeight.w600)", "AppTextStyles.bodySmall(context, color: AppColors.onBackground, fontWeight: FontWeight.w600)");
  
  // Inside _buildDownloadButton
  content = content.replaceAll("color: const Color(0xFF06231C), // Very dark greenish-black from mockup", "color: AppColors.primaryContainer,");
  content = content.replaceAll("Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer");
  content = content.replaceAll("AppTextStyles.buttonLarge(context, color: AppColors.primary)", "AppTextStyles.buttonLarge(context, color: AppColors.onPrimaryContainer)");

  file.writeAsStringSync(content);
}
