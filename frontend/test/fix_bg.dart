import 'dart:io';

void main() {
  final file1 = File('f:/projek/anise_app/frontend/lib/features/tugas/screens/tugas_screen.dart');
  if (file1.existsSync()) {
    var content = file1.readAsStringSync();
    content = content.replaceAll("AppColors.background,", "AppColors.backgroundLight,");
    file1.writeAsStringSync(content);
  }

  final file2 = File('f:/projek/anise_app/frontend/lib/features/tugas/screens/tugas_detail_screen.dart');
  if (file2.existsSync()) {
    var content = file2.readAsStringSync();
    content = content.replaceAll("AppColors.background,", "AppColors.backgroundLight,");
    content = content.replaceAll("AppColors.background", "AppColors.backgroundLight"); // catch any without comma
    file2.writeAsStringSync(content);
  }
}
