import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/identity_card_3d_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("AppColors.primary", "AppColors.primaryContainer");
  content = content.replaceAll("AppColors.onPrimary", "AppColors.onPrimaryContainer");

  file.writeAsStringSync(content);
}
