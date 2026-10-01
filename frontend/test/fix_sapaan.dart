import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Revert Sapaan to onBackground
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface, fontWeight: FontWeight.w600),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.w600),");

  file.writeAsStringSync(content);
}
