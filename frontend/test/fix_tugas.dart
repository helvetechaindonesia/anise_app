import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/screens/tugas_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Scaffold bg
  content = content.replaceAll("backgroundColor: AppColors.primary,", "backgroundColor: AppColors.background,");
  
  // AppBar bg
  content = content.replaceAll("backgroundColor: AppColors.primary,\n      elevation: 0,", "backgroundColor: AppColors.surface,\n      elevation: 0,");
  
  // AppBar texts & icons
  content = content.replaceAll("AppTextStyles.h4(context, color: AppColors.primary)", "AppTextStyles.h4(context, color: AppColors.onSurface)");
  content = content.replaceAll("AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500)", "AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.w500)");
  content = content.replaceAll("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context))", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context))");
  
  // _buildHeader
  // Back button
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n                  shape: BoxShape.circle,", "color: Colors.transparent,\n                  shape: BoxShape.circle,");
  content = content.replaceAll("Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context))", "Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 20.w(context))");
  // Header Texts
  content = content.replaceAll("AppTextStyles.h4(context, color: AppColors.primary)", "AppTextStyles.h4(context, color: AppColors.onBackground)"); // Need to be careful not to replace AppBar again, wait, I already replaced the AppBar ones!
  // I will use more specific replace
  
  // Actually, I can just use a regex or specific replace for _buildHeader
  content = content.replaceAll("Text(\n                  'Tugas & Evaluasi',\n                  style: AppTextStyles.h4(context, color: AppColors.primary),\n                ),", "Text(\n                  'Tugas & Evaluasi',\n                  style: AppTextStyles.h4(context, color: AppColors.onBackground),\n                ),");
  content = content.replaceAll("Text(\n                  'Kelola tenggat waktu tugasmu',\n                  style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500),\n                ),", "Text(\n                  'Kelola tenggat waktu tugasmu',\n                  style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.w500),\n                ),");
  
  // Books Icon
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n            borderRadius: BorderRadius.circular(16.w(context)),", "color: AppColors.primaryContainer,\n            borderRadius: BorderRadius.circular(16.w(context)),");
  content = content.replaceAll("Icon(PhosphorIcons.books(PhosphorIconsStyle.fill), color: AppColors.primary, size: 24.w(context))", "Icon(PhosphorIcons.books(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 24.w(context))");
  
  // _buildStatsCard
  // Container bg & shadow
  content = content.replaceAll("color: AppColors.primary,\n        borderRadius: BorderRadius.circular(24.w(context)),", "color: AppColors.primaryContainer,\n        borderRadius: BorderRadius.circular(24.w(context)),");
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),\n            blurRadius: 16,\n            offset: const Offset(0, 8),", "color: AppColors.onBackground.withValues(alpha: 0.05),\n            blurRadius: 10,\n            offset: const Offset(0, 4),");
  // Dividers
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5)", "color: AppColors.outline"); // Actually, onPrimaryContainer.withValues(alpha: 0.2)
  // Let's replace the whole stats items calling
  content = content.replaceAll("_buildStatItem(context, belum.toString(), 'Belum', PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill), AppColors.primary),", "_buildStatItem(context, belum.toString(), 'Belum', PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill), AppColors.onPrimaryContainer),");
  content = content.replaceAll("_buildStatItem(context, terlewat.toString(), 'Terlewat', PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), AppColors.primary),", "_buildStatItem(context, terlewat.toString(), 'Terlewat', PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), AppColors.error),");
  content = content.replaceAll("_buildStatItem(context, '1', 'Minggu Ini', PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill), AppColors.primary),", "_buildStatItem(context, '1', 'Minggu Ini', PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill), AppColors.onPrimaryContainer),");
  
  // _buildStatItem itself
  content = content.replaceAll("style: AppTextStyles.h2(context, color: AppColors.primary)", "style: AppTextStyles.h2(context, color: AppColors.onPrimaryContainer)");
  // The label uses AppColors.primary.withValues(alpha: 0.5) but I just changed all of that to outline.
  // Wait, let's fix _buildStatItem label specifically
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.outline, fontWeight: FontWeight.w500)", "style: AppTextStyles.caption(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7), fontWeight: FontWeight.w500)");
  
  // Also the dividers need to be onPrimaryContainer alpha 0.2
  content = content.replaceAll("Container(width: 1, height: 40.h(context), color: AppColors.outline)", "Container(width: 1, height: 40.h(context), color: AppColors.onPrimaryContainer.withValues(alpha: 0.2))");

  // _buildCustomTabBar
  content = content.replaceAll("color: AppColors.primary,\n        borderRadius: BorderRadius.circular(100),\n        border: Border.all(color: AppColors.outline),", "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(100),\n        border: Border.all(color: AppColors.outline),"); // Wait, original border was primary.withValues(alpha: 0.5).
  // Let me replace the exact original
  content = content.replaceAll("color: AppColors.primary,\n        borderRadius: BorderRadius.circular(100),\n        border: Border.all(color: AppColors.outline),", "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(100),\n        border: Border.all(color: AppColors.outline),"); // Actually my mass replace changed primary.withValues(alpha: 0.5) to outline. So the border is now outline.
  content = content.replaceAll("color: AppColors.primary,\n        borderRadius: BorderRadius.circular(100),", "color: AppColors.surface,\n        borderRadius: BorderRadius.circular(100),");
  content = content.replaceAll("indicator: BoxDecoration(\n          color: AppColors.surface,\n          borderRadius: BorderRadius.circular(100),\n        ),", "indicator: BoxDecoration(\n          color: AppColors.onSurface,\n          borderRadius: BorderRadius.circular(100),\n        ),"); // wait, indicator color is primary originally
  content = content.replaceAll("indicator: BoxDecoration(\n          color: AppColors.primary,\n          borderRadius: BorderRadius.circular(100),\n        ),", "indicator: BoxDecoration(\n          color: AppColors.onSurface,\n          borderRadius: BorderRadius.circular(100),\n        ),");
  content = content.replaceAll("labelColor: AppColors.primary,", "labelColor: AppColors.surface,");
  content = content.replaceAll("unselectedLabelColor: AppColors.primary,", "unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.5),");

  file.writeAsStringSync(content);
}
