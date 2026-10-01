import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/screens/tugas_screen.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll("border: Border.all(color: AppColors.outline),", "");
    file.writeAsStringSync(content);
  }
}
