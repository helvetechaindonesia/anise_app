import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/widgets/tugas_list_tab.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Fix empty state
  content = content.replaceAll("Icon(PhosphorIcons.checks(PhosphorIconsStyle.fill), size: 48.w(context), color: AppColors.primary.withValues(alpha: 0.5))", "Icon(PhosphorIcons.checks(PhosphorIconsStyle.fill), size: 48.w(context), color: AppColors.onBackground.withValues(alpha: 0.2))");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.w600),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5), fontWeight: FontWeight.w600),");
  
  // Replace ListView.builder with ListView.separated
  content = content.replaceAll("return ListView.builder(", "return ListView.separated(");
  // Add separatorBuilder
  content = content.replaceAll("itemCount: filteredTasks.length,\n      itemBuilder: (context, index) {", "itemCount: filteredTasks.length,\n      separatorBuilder: (context, index) => Divider(color: AppColors.primary, height: 24.h(context)),\n      itemBuilder: (context, index) {");

  // Fix task card colors in _buildTaskCard (timeBgColor, timeIconColor, statusColor)
  // We want to pass secondary things or keep it as is, wait, we don't even use timeBgColor/timeIconColor/statusColor in the TugasItemCard if the text is transparent onBackground!
  // Actually, TugasItemCard still accepts these parameters but in our previous refactoring we hardcoded it to AppColors.secondary for shape and AppColors.onSecondary for text/icon inside the shape. Let me verify that.
  // Wait, looking at TugasItemCard build method above:
  // Container decoration: color: AppColors.secondary,
  // Icon color: AppColors.onSecondary
  // Status is just onBackground.
  // So the arguments timeBgColor, timeIconColor, statusColor are basically ignored by TugasItemCard now!
  // That's totally fine, we can leave them.

  file.writeAsStringSync(content);
}
