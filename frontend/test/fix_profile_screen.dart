import 'dart:io';

void main() {
  final fScreen = File('f:/projek/anise_app/frontend/lib/features/profile/screens/siswa_profile_screen.dart');
  if (fScreen.existsSync()) {
    var c = fScreen.readAsStringSync();
    
    // Bottom Sheet
    c = c.replaceFirst("backgroundColor: AppColors.backgroundLight", "backgroundColor: AppColors.surface");
    c = c.replaceFirst("style: AppTextStyles.bodyLarge(context, color: AppColors.primary, fontWeight: FontWeight.bold)", "style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface, fontWeight: FontWeight.bold)");
    
    // AppBar
    c = c.replaceFirst("backgroundColor: AppColors.backgroundLight,\n      elevation: 0,", "backgroundColor: AppColors.surface,\n      elevation: 0,");
    c = c.replaceFirst("style: AppTextStyles.h4(context, color: AppColors.textDark),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary", "style: AppTextStyles.caption(context, color: AppColors.onSurface");
    c = c.replaceFirst("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface");

    // Section title
    c = c.replaceAll("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w800)", "style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.w800)");
    c = c.replaceAll("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)", "style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)");
    
    // Logout button
    c = c.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),", "color: AppColors.errorContainer,");
    c = c.replaceFirst("Icon(PhosphorIcons.signOut(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.signOut(PhosphorIconsStyle.bold), color: AppColors.onErrorContainer,");
    c = c.replaceFirst("style: AppTextStyles.bodyMedium(context, color: AppColors.primary,", "style: AppTextStyles.bodyMedium(context, color: AppColors.onErrorContainer,");
    
    // Footer
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)", "style: AppTextStyles.caption(context, color: AppColors.onBackground.withValues(alpha: 0.5), fontWeight: FontWeight.w600)");

    fScreen.writeAsStringSync(c);
  }
}
