import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/main_navigation_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("unselectedItemColor: AppColors.onSurface.withValues(alpha: 0.5),", "unselectedItemColor: AppColors.onSurface.withValues(alpha: 0.25),");

  file.writeAsStringSync(content);
}
