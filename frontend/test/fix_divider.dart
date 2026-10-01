import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/tugas_mendatang_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("color: AppColors.outline,", "color: AppColors.primary,");

  file.writeAsStringSync(content);
}
