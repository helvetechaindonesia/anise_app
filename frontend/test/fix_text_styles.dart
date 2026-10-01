import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/core/theme/app_text_styles.dart');
  if (!file.existsSync()) return;
  
  var content = file.readAsStringSync();
  content = content.replaceAll('color: color ?? AppColors.primary,', 'color: color ?? AppColors.onBackground,');
  content = content.replaceAll("import 'package:frontend/core/theme/app_text_styles.dart';", ""); // remove redundant self import
  
  file.writeAsStringSync(content);
}
