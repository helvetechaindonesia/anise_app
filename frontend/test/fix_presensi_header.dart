import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/widgets/presensi_header_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Texts on background
  content = content.replaceAll("AppTextStyles.h4(context, color: AppColors.primary)", "AppTextStyles.h4(context, color: AppColors.onBackground)");
  content = content.replaceAll("AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w500)", "AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.w500)");
  
  // Back button and Month Selector (Shapes)
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5),", "color: AppColors.secondary,");
  content = content.replaceAll("Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onSecondary,");
  content = content.replaceAll("Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onSecondary,");
  content = content.replaceAll("Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.primary,", "Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSecondary,");
  content = content.replaceAll("AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.w800)", "AppTextStyles.overline(context, color: AppColors.onSecondary, fontWeight: FontWeight.w800)");

  file.writeAsStringSync(content);
}
