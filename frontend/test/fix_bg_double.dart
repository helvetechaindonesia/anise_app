import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/screens/tugas_detail_screen.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll("AppColors.backgroundLightLight", "AppColors.backgroundLight");
    file.writeAsStringSync(content);
  }
}
