import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/jadwal/screens/jadwal_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Scaffold bg
  content = content.replaceAll("backgroundColor: AppColors.backgroundLight,", "backgroundColor: AppColors.background,");
  
  // AppBar bg
  content = content.replaceAll("backgroundColor: AppColors.background,", "backgroundColor: AppColors.surface,"); // wait, only SliverAppBar has backgroundLight left
  // Actually, wait, let's do more precise replacements.
  
  content = content.replaceAll("SliverAppBar(\n      pinned: true,\n      backgroundColor: AppColors.backgroundLight,", "SliverAppBar(\n      pinned: true,\n      backgroundColor: AppColors.surface,");
  
  // AppBar texts
  content = content.replaceAll("AppTextStyles.h4(context, color: AppColors.textDark)", "AppTextStyles.h4(context, color: AppColors.onSurface)");
  content = content.replaceAll("AppTextStyles.caption(context, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)", "AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.w500)");
  content = content.replaceAll("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context))", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context))");
  
  // _buildHeader
  content = content.replaceAll("Text(\n              'AGENDA AKADEMIK',\n              style: AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.bold),\n            ),", "Text(\n              'AGENDA AKADEMIK',\n              style: AppTextStyles.overline(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),\n            ),");
  content = content.replaceAll("Text(\n              'Jadwal Kelas',\n              style: AppTextStyles.bodyMedium(context, fontWeight: FontWeight.w900),\n            ),", "Text(\n              'Jadwal Kelas',\n              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.w900),\n            ),");
  
  // 'Pilih Tanggal' button
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.1),", "color: AppColors.secondary,");
  content = content.replaceAll("Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onSecondary");
  content = content.replaceAll("Text(\n                  'Pilih Tanggal',\n                  style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold),\n                ),", "Text(\n                  'Pilih Tanggal',\n                  style: AppTextStyles.caption(context, color: AppColors.onSecondary, fontWeight: FontWeight.bold),\n                ),");

  // _buildDateSelector (Active Tab)
  content = content.replaceAll("color: isSelected ? AppColors.primary : AppColors.surface,", "color: isSelected ? AppColors.primaryContainer : AppColors.surface,");
  content = content.replaceAll("style: AppTextStyles.overline(context, color: isSelected ? AppColors.onPrimary.withValues(alpha: 0.8) : AppColors.onSurfaceVariant", "style: AppTextStyles.overline(context, color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface");
  content = content.replaceAll("style: AppTextStyles.h4(context, color: isSelected ? AppColors.onPrimary : AppColors.onSurface)", "style: AppTextStyles.h4(context, color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface)");
  // Border color for inactive
  content = content.replaceAll("color: isSelected ? AppColors.onPrimary : AppColors.onSurface.withValues(alpha: 0.5),", "color: isSelected ? AppColors.onPrimaryContainer : AppColors.outline,");
  // Inner dot color
  content = content.replaceAll("color: AppColors.primary,\n                        shape: BoxShape.circle,", "color: AppColors.onPrimaryContainer,\n                        shape: BoxShape.circle,");
  
  // ScheduleList empty state texts
  content = content.replaceAll("color: AppColors.onBackground.withValues(alpha: 0.2)", "color: AppColors.onBackground.withValues(alpha: 0.3)");
  content = content.replaceAll("color: AppColors.onBackground.withValues(alpha: 0.5)", "color: AppColors.onBackground.withValues(alpha: 0.6)");

  file.writeAsStringSync(content);
}
