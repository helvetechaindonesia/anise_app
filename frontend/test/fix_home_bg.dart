import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Background of the screen
  content = content.replaceAll("backgroundColor: AppColors.surface, // Background handled by DecorativeBackground", "backgroundColor: AppColors.backgroundLight, // Background handled by DecorativeBackground");

  file.writeAsStringSync(content);
}
