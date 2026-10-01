import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Header background
  content = content.replaceAll("backgroundColor: AppColors.backgroundLight,", "backgroundColor: AppColors.surface,");
  
  // Header sapaan (currently onBackground, change to onSurface)
  content = content.replaceAll("color: AppColors.onBackground, fontWeight: FontWeight.w600),", "color: AppColors.onSurface, fontWeight: FontWeight.w600),");

  file.writeAsStringSync(content);
}
