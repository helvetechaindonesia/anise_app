import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/identity_card_3d_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("AppColors.textPrimary", "AppColors.onPrimary");
  content = content.replaceAll("AppColors.textDark", "AppColors.onBackground");

  file.writeAsStringSync(content);
}
