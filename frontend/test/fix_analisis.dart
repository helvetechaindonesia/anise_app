import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/pembiasaan/widgets/analisis_tab.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  // _buildAnalysisModeTab selector container
  content = content.replaceFirst(
    "color: AppColors.primary.withValues(alpha: 0.5),\n            borderRadius: BorderRadius.circular(100),",
    "color: AppColors.surface,\n            borderRadius: BorderRadius.circular(100),\n            border: Border.all(color: AppColors.outline),"
  );
  
  // _buildAnalysisModeTab item
  content = content.replaceFirst(
    "color: isSelected ? AppColors.primary : AppColors.transparent,",
    "color: isSelected ? AppColors.onSurface : AppColors.transparent,"
  );
  content = content.replaceFirst(
    "BoxShadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 2)),",
    "BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),"
  );
  content = content.replaceFirst(
    "style: AppTextStyles.bodySmall(context, color: isSelected ? AppColors.primary : AppColors.primary, fontWeight: FontWeight.w800),",
    "style: AppTextStyles.bodySmall(context, color: isSelected ? AppColors.surface : AppColors.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w800),"
  );

  // Radar Chart Card bg
  content = content.replaceFirst(
    "color: AppColors.primary,\n            borderRadius: BorderRadius.circular(24.w(context)),\n            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),",
    "color: AppColors.surface,\n            borderRadius: BorderRadius.circular(24.w(context)),\n            border: Border.all(color: AppColors.outline),"
  );
  content = content.replaceFirst(
    "BoxShadow(color: AppColors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),",
    "BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),"
  );
  content = content.replaceFirst("style: AppTextStyles.h4(context),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),");
  content = content.replaceFirst("style: AppTextStyles.bodySmall(context, color: AppColors.primary, fontWeight: FontWeight.w500),", "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w500),");

  // Radar Chart colors
  content = content.replaceFirst("fillColor: AppColors.primary.withValues(alpha: 0.5),", "fillColor: AppColors.primary.withValues(alpha: 0.2),");
  content = content.replaceFirst("tickBorderData: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),", "tickBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1)),");
  content = content.replaceFirst("gridBorderData: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),", "gridBorderData: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1), width: 1.5),");
  content = content.replaceFirst("style: AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.w700)", "style: AppTextStyles.overline(context, color: AppColors.onSurface, fontWeight: FontWeight.w700)");

  // Legend Card
  content = content.replaceFirst(
    "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(20.w(context)),",
    "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.outline),"
  );
  content = content.replaceAll("style: AppTextStyles.bodySmall(context, color: AppColors.primary.withValues(alpha: 0.5)", "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.7)");
  content = content.replaceAll("style: AppTextStyles.h4(context, color: AppColors.primary)", "style: AppTextStyles.h4(context, color: AppColors.onSurface)");
  content = content.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5)", "color: AppColors.outline"); // for the vertical divider

  // Streak & Consistency Cards
  content = content.replaceAll(
    "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),",
    "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.outline),"
  );
  content = content.replaceAll("Icon(PhosphorIcons.fire(PhosphorIconsStyle.fill), color: AppColors.primary", "Icon(PhosphorIcons.fire(PhosphorIconsStyle.fill), color: AppColors.error");
  content = content.replaceAll("Icon(PhosphorIcons.target(PhosphorIconsStyle.fill), color: AppColors.primary", "Icon(PhosphorIcons.target(PhosphorIconsStyle.fill), color: AppColors.onSurface");
  content = content.replaceAll("style: AppTextStyles.bodySmall(context, color: AppColors.primary, fontWeight: FontWeight.bold)", "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface, fontWeight: FontWeight.bold)");
  content = content.replaceAll("style: AppTextStyles.h3(context, color: AppColors.primary)", "style: AppTextStyles.h3(context, color: AppColors.onSurface)");
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)", "style: AppTextStyles.caption(context, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600)");

  // Insight Card
  content = content.replaceFirst(
    "color: AppColors.primary.withValues(alpha: 0.5),\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),",
    "color: AppColors.secondary,\n        borderRadius: BorderRadius.circular(20.w(context)),"
  );
  content = content.replaceFirst(
    "color: AppColors.primary,\n              shape: BoxShape.circle,",
    "color: AppColors.onSecondary.withValues(alpha: 0.2),\n              shape: BoxShape.circle,"
  );
  content = content.replaceFirst("BoxShadow(color: AppColors.primary.withValues(alpha: 0.5)", "BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05)");
  content = content.replaceFirst("Icon(PhosphorIcons.lightbulb(PhosphorIconsStyle.fill), color: AppColors.primary", "Icon(PhosphorIcons.lightbulb(PhosphorIconsStyle.fill), color: AppColors.onSecondary");
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.w900)", "style: AppTextStyles.bodyMedium(context, color: AppColors.onSecondary, fontWeight: FontWeight.w900)");
  content = content.replaceFirst("style: AppTextStyles.bodySmall(context, color: AppColors.primary, fontWeight: FontWeight.w500)", "style: AppTextStyles.bodySmall(context, color: AppColors.onSecondary, fontWeight: FontWeight.w500)");

  // Heatmap Calendar
  content = content.replaceFirst(
    "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),",
    "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.outline),"
  );
  content = content.replaceFirst("style: AppTextStyles.h4(context),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),");
  content = content.replaceFirst("Icon(PhosphorIcons.calendar(PhosphorIconsStyle.fill), color: AppColors.primary", "Icon(PhosphorIcons.calendar(PhosphorIconsStyle.fill), color: AppColors.onSurface");
  
  // Heatmap block colors
  content = content.replaceFirst("blockColor = AppColors.primary.withValues(alpha: 0.5);", "blockColor = AppColors.onSurface.withValues(alpha: 0.05);");
  content = content.replaceFirst("blockColor = AppColors.primary.withValues(alpha: 0.5);", "blockColor = AppColors.primary.withValues(alpha: 0.3);");
  content = content.replaceFirst("blockColor = AppColors.primary.withValues(alpha: 0.5);", "blockColor = AppColors.primary.withValues(alpha: 0.6);");
  // AppColors.primary stays the same
  
  // Heatmap legends
  content = content.replaceFirst("Text('Kurang', style: AppTextStyles.overline(context, color: AppColors.primary", "Text('Kurang', style: AppTextStyles.overline(context, color: AppColors.onSurface");
  content = content.replaceFirst("Text('Konsisten', style: AppTextStyles.overline(context, color: AppColors.primary", "Text('Konsisten', style: AppTextStyles.overline(context, color: AppColors.onSurface");
  content = content.replaceFirst("_buildLegendBox(context, AppColors.primary.withValues(alpha: 0.5))", "_buildLegendBox(context, AppColors.onSurface.withValues(alpha: 0.05))");
  content = content.replaceFirst("_buildLegendBox(context, AppColors.primary.withValues(alpha: 0.5))", "_buildLegendBox(context, AppColors.primary.withValues(alpha: 0.3))");
  content = content.replaceFirst("_buildLegendBox(context, AppColors.primary.withValues(alpha: 0.5))", "_buildLegendBox(context, AppColors.primary.withValues(alpha: 0.6))");
  
  file.writeAsStringSync(content);
}
