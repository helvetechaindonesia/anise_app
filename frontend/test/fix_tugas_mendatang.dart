import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/tugas_mendatang_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),");
  content = content.replaceAll("color: AppColors.textPrimary.withValues(alpha: 0.5),", "color: AppColors.error,");
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.caption(context, color: AppColors.onPrimary, fontWeight: FontWeight.bold),");
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold).copyWith(height: 1.1),", "style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.bold).copyWith(height: 1.1),");
  content = content.replaceAll("Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.textPrimary),", "Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),");
  
  // also the separator
  content = content.replaceAll("color: AppColors.textPrimary.withValues(alpha: 0.5),", "color: AppColors.outline,");

  file.writeAsStringSync(content);
}
