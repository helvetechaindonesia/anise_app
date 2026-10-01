import 'dart:io';

void main() {
  // 1. agenda_header_widget.dart
  final fHeader = File('f:/projek/anise_app/frontend/lib/features/penilaian/widgets/agenda_header_widget.dart');
  if (fHeader.existsSync()) {
    var c = fHeader.readAsStringSync();
    c = c.replaceAll("color: AppColors.primary.withValues(alpha: 0.5)", "color: AppColors.surface");
    c = c.replaceAll("shape: BoxShape.circle,", "shape: BoxShape.circle,\n                  border: Border.all(color: AppColors.outline),");
    c = c.replaceFirst("color: AppColors.primary, size: 20.w(context)", "color: AppColors.onSurface, size: 20.w(context)");
    
    c = c.replaceFirst("style: AppTextStyles.h4(context, color: AppColors.primary),", "style: AppTextStyles.h4(context, color: AppColors.onBackground),");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500),", "style: AppTextStyles.caption(context, color: AppColors.onBackground.withValues(alpha: 0.7), fontWeight: FontWeight.w500),");
    
    c = c.replaceFirst("color: AppColors.primary,\n            borderRadius: BorderRadius.circular(100),", "color: AppColors.surface,\n            borderRadius: BorderRadius.circular(100),\n            border: Border.all(color: AppColors.outline),");
    c = c.replaceFirst("color: AppColors.primary, size: 14.w(context)", "color: AppColors.onSurface, size: 14.w(context)");
    c = c.replaceFirst("style: AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.w800)", "style: AppTextStyles.overline(context, color: AppColors.onSurface, fontWeight: FontWeight.w800)");
    
    fHeader.writeAsStringSync(c);
  }

  // 2. agenda_bottom_banner_widget.dart
  final fBanner = File('f:/projek/anise_app/frontend/lib/features/penilaian/widgets/agenda_bottom_banner_widget.dart');
  if (fBanner.existsSync()) {
    var c = fBanner.readAsStringSync();
    c = c.replaceFirst("color: const Color(0xFFEEF0FF)", "color: AppColors.secondary");
    c = c.replaceFirst("color: Color(0xFF003049)", "color: AppColors.onSecondary.withValues(alpha: 0.2)");
    c = c.replaceFirst("color: AppColors.primary, size: 24.w(context)", "color: AppColors.onSecondary, size: 24.w(context)");
    c = c.replaceFirst("color: const Color(0xFF003049)", "color: AppColors.onSecondary");
    c = c.replaceFirst("color: AppColors.primary", "color: AppColors.onSecondary");
    c = c.replaceFirst("style: AppTextStyles.bodyMedium(context)", "style: AppTextStyles.bodyMedium(context, color: AppColors.onSecondary)");
    fBanner.writeAsStringSync(c);
  }

  // 3. agenda_featured_card_widget.dart
  final fFeatured = File('f:/projek/anise_app/frontend/lib/features/penilaian/widgets/agenda_featured_card_widget.dart');
  if (fFeatured.existsSync()) {
    var c = fFeatured.readAsStringSync();
    c = c.replaceAll("color: AppColors.primary, // Dark Teal", "color: AppColors.primaryContainer,");
    c = c.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n            blurRadius: 16,", "color: AppColors.onBackground.withValues(alpha: 0.05),\n            blurRadius: 16,");
    
    // Ujian mendatang pill
    c = c.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),\n                  borderRadius: BorderRadius.circular(100),", "color: AppColors.primary,\n                  borderRadius: BorderRadius.circular(100),");
    c = c.replaceFirst("color: AppColors.primary, fontWeight: FontWeight.bold", "color: AppColors.onPrimary, fontWeight: FontWeight.bold");
    c = c.replaceFirst("Icon(PhosphorIcons.timer(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.timer(PhosphorIconsStyle.bold), color: AppColors.secondary,");
    
    // Mata Pelajaran Wajib
    c = c.replaceFirst("style: AppTextStyles.overline(context, color: AppColors.primary.withValues(alpha: 0.5)", "style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)");
    c = c.replaceFirst("style: AppTextStyles.h3(context, color: AppColors.primary),", "style: AppTextStyles.h3(context, color: AppColors.onPrimaryContainer),");
    
    // Perlengkapan container
    c = c.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),\n              borderRadius: BorderRadius.circular(12.w(context)),", "color: AppColors.primary,\n              borderRadius: BorderRadius.circular(12.w(context)),");
    c = c.replaceFirst("Icon(PhosphorIcons.listChecks(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.listChecks(PhosphorIconsStyle.bold), color: AppColors.onPrimary,");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary.withValues(alpha: 0.5)", "style: AppTextStyles.caption(context, color: AppColors.onPrimary.withValues(alpha: 0.8)");
    c = c.replaceFirst("style: AppTextStyles.bodyMedium(context)", "style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)");
    
    // Unduh jadwal button
    c = c.replaceFirst("color: AppColors.primary,\n              borderRadius: BorderRadius.circular(12.w(context)),", "color: AppColors.primary,\n              borderRadius: BorderRadius.circular(12.w(context)),"); // no change
    c = c.replaceFirst("Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimary,");
    c = c.replaceFirst("style: AppTextStyles.bodySmall(context, color: AppColors.primary", "style: AppTextStyles.bodySmall(context, color: AppColors.onPrimary");
    
    // FeaturedInfoRow icon/text (used via _buildFeaturedInfoRow helper)
    c = c.replaceFirst("Icon(icon, color: AppColors.primary.withValues(alpha: 0.5)", "Icon(icon, color: AppColors.secondary");
    c = c.replaceFirst("style: AppTextStyles.bodySmall(context, color: AppColors.primary", "style: AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer");

    fFeatured.writeAsStringSync(c);
  }
}
