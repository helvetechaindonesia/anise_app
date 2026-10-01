import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/screens/presensi_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("backgroundColor: AppColors.backgroundLight, // WAS primary", "backgroundColor: AppColors.background,");

  file.writeAsStringSync(content);
}
