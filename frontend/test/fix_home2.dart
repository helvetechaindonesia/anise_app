import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Header names
  content = content.replaceAll("style: AppTextStyles.h4(context, color: AppColors.onBackground),", "style: AppTextStyles.h4(context, color: AppColors.onSurface),");
  content = content.replaceAll("style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),", "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),");

  file.writeAsStringSync(content);
}
