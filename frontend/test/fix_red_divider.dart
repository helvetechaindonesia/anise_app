import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/tugas_mendatang_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("height: 1,\n                      color: AppColors.error,", "height: 1,\n                      color: AppColors.primary,");

  file.writeAsStringSync(content);
}
