import 'dart:io';

void main() {
  final fScreen = File('f:/projek/anise_app/frontend/lib/features/lapor/screens/lapor_kesiswaan_screen.dart');
  if (fScreen.existsSync()) {
    var c = fScreen.readAsStringSync();
    
    // Scaffold
    c = c.replaceFirst("backgroundColor: AppColors.primary,", "backgroundColor: AppColors.backgroundLight,");
    
    // AppBar
    c = c.replaceFirst("backgroundColor: AppColors.primary,\n      elevation: 0,", "backgroundColor: AppColors.surface,\n      elevation: 0,");
    c = c.replaceFirst("style: AppTextStyles.h4(context, color: AppColors.primary),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500),", "style: AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.w500),");
    c = c.replaceFirst("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface");

    // Header
    c = c.replaceFirst(
      "color: AppColors.primary.withValues(alpha: 0.5),\n                  shape: BoxShape.circle,",
      "color: AppColors.transparent,\n                  shape: BoxShape.circle,"
    );
    c = c.replaceFirst("Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground");
    c = c.replaceFirst("style: AppTextStyles.h3(context, color: AppColors.primary),", "style: AppTextStyles.h3(context, color: AppColors.onBackground),");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary", "style: AppTextStyles.caption(context, color: AppColors.onBackground.withValues(alpha: 0.7)");
    
    // Info Banner (Pusat Layanan Kesiswaan)
    c = c.replaceFirst(
      "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        boxShadow: [\n          BoxShadow(\n            color: AppColors.primary.withValues(alpha: 0.5),\n            blurRadius: 10,\n            offset: const Offset(0, 4),\n          ),\n        ],",
      "color: AppColors.primaryContainer,\n        borderRadius: BorderRadius.circular(20.w(context)),"
    );
    c = c.replaceFirst(
      "color: AppColors.primary.withValues(alpha: 0.5),\n              borderRadius: BorderRadius.circular(12.w(context)),",
      "color: AppColors.primary,\n              borderRadius: BorderRadius.circular(12.w(context)),"
    );
    c = c.replaceFirst("Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), color: AppColors.primary", "Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), color: AppColors.onPrimary");
    c = c.replaceFirst("style: AppTextStyles.bodyMedium(context, color: AppColors.primary", "style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimaryContainer");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary.withValues(alpha: 0.5)", "style: AppTextStyles.caption(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)");
    
    fScreen.writeAsStringSync(c);
  }
}
