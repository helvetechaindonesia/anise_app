import 'dart:io';

void main() {
  final fScreen = File('f:/projek/anise_app/frontend/lib/features/penilaian/screens/agenda_penilaian_screen.dart');
  if (fScreen.existsSync()) {
    var c = fScreen.readAsStringSync();
    
    // Scaffold and SliverAppBar
    c = c.replaceFirst("backgroundColor: AppColors.backgroundLight", "backgroundColor: AppColors.background"); // Keep it background
    c = c.replaceFirst("backgroundColor: AppColors.primary,\n      elevation: 0,", "backgroundColor: AppColors.surface,\n      elevation: 0,");
    c = c.replaceFirst("style: AppTextStyles.h4(context, color: AppColors.primary),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500),", "style: AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.w500),");
    c = c.replaceFirst("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface");

    // Headers
    c = c.replaceFirst("style: AppTextStyles.h4(context),", "style: AppTextStyles.h4(context, color: AppColors.onBackground),");
    c = c.replaceFirst("style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)", "style: AppTextStyles.caption(context, color: AppColors.onBackground.withValues(alpha: 0.7), fontWeight: FontWeight.w600)");
    
    // Filter Chips
    c = c.replaceAll("color: isSelected ? const Color(0xFF003049) : const Color(0xFFE5E9FF),", "color: isSelected ? AppColors.primaryContainer : AppColors.surface,\n                border: Border.all(color: isSelected ? AppColors.primaryContainer : AppColors.outline),");
    c = c.replaceAll("style: AppTextStyles.caption(context, color: isSelected ? AppColors.primary : AppColors.primary, fontWeight: FontWeight.w800)", "style: AppTextStyles.caption(context, color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface, fontWeight: FontWeight.w800)");

    // Agenda Card
    c = c.replaceFirst(
      "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(24.w(context)),\n        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),\n        boxShadow: [\n          BoxShadow(\n            color: AppColors.black.withValues(alpha: 0.5),\n            blurRadius: 10,\n            offset: const Offset(0, 4),\n          ),\n        ],",
      "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(24.w(context)),\n        border: Border.all(color: AppColors.outline),"
    );

    // Inner icon block
    c = c.replaceFirst(
      "color: AppColors.primary.withValues(alpha: 0.5),\n                  borderRadius: BorderRadius.circular(16.w(context)),",
      "color: AppColors.primaryContainer,\n                  borderRadius: BorderRadius.circular(16.w(context)),"
    );
    c = c.replaceFirst("Icon(data['icon'] as IconData, color: AppColors.primary, size: 24.w(context))", "Icon(data['icon'] as IconData, color: AppColors.onPrimaryContainer, size: 24.w(context))");
    
    // label and title
    c = c.replaceFirst("style: AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.w800),", "style: AppTextStyles.overline(context, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w800),");
    c = c.replaceFirst("style: AppTextStyles.h1(context),", "style: AppTextStyles.h1(context, color: AppColors.onSurface),");
    
    // bobot block
    c = c.replaceFirst("color: data['type'] == 'SAS' ? const Color(0xFFE5E9FF) : AppColors.primary,", "color: data['type'] == 'SAS' ? AppColors.secondary : AppColors.primary,");
    c = c.replaceFirst("style: AppTextStyles.overline(context, color: data['type'] == 'SAS' ? const Color(0xFF003049) : AppColors.primary, fontWeight: FontWeight.w800)", "style: AppTextStyles.overline(context, color: data['type'] == 'SAS' ? AppColors.onSecondary : AppColors.onPrimary, fontWeight: FontWeight.w800)");
    
    // info container
    c = c.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),\n              borderRadius: BorderRadius.circular(16.w(context)),", "color: AppColors.background,\n              borderRadius: BorderRadius.circular(16.w(context)),");
    
    // _buildAgendaInfoRow
    c = c.replaceFirst("Icon(icon, color: AppColors.primary, size: 16.w(context))", "Icon(icon, color: AppColors.onSurface, size: 16.w(context))");
    c = c.replaceFirst("style: AppTextStyles.bodySmall(context, color: AppColors.primary.withValues(alpha: 0.5), fontWeight: FontWeight.w600),", "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface, fontWeight: FontWeight.w600),");
    
    fScreen.writeAsStringSync(c);
  }
}
