import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/layanan_cepat_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Icon color
  content = content.replaceAll("color: AppColors.primary,", "color: AppColors.onSurface,");

  file.writeAsStringSync(content);
}
