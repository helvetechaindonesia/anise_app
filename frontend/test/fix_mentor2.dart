import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/bimbingan_mentor_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Revert "Lihat Semua" to onBackground
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.primaryContainer, fontWeight: FontWeight.bold).copyWith(height: 1.1),", "style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.bold).copyWith(height: 1.1),");
  content = content.replaceAll("Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primaryContainer),", "Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),");

  // Fix Profile Icon Color
  content = content.replaceAll("Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.primaryContainer, size: 32.w(context)),", "Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 32.w(context)),");
  
  // Fix Profile Circle Background
  content = content.replaceAll("color: mentor['color'] as Color,", "color: AppColors.onPrimaryContainer.withValues(alpha: 0.1),");

  file.writeAsStringSync(content);
}
