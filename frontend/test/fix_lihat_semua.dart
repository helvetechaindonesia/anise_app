import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/bimbingan_mentor_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // "Lihat Semua" text and icon to primaryContainer as requested
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.bold).copyWith(height: 1.1),", "style: AppTextStyles.caption(context, color: AppColors.primaryContainer, fontWeight: FontWeight.bold).copyWith(height: 1.1),");
  content = content.replaceAll("Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),", "Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primaryContainer),");

  file.writeAsStringSync(content);
}
