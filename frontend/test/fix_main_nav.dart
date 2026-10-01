import 'dart:io';

void fixFile(String filePath, Map<String, String> replacements) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  
  var content = file.readAsStringSync();
  var original = content;

  replacements.forEach((key, value) {
    content = content.replaceAll(key, value);
  });

  if (content != original) {
    file.writeAsStringSync(content);
    print('Fixed colors in: ' + filePath);
  }
}

void main() {
  // Fix MainNavigationScreen
  fixFile('f:/projek/anise_app/frontend/lib/features/home/screens/main_navigation_screen.dart', {
    "backgroundColor: AppColors.primary": "backgroundColor: AppColors.backgroundLight",
    "color: AppColors.primary,\n          boxShadow:": "color: AppColors.textPrimary,\n          boxShadow:",
    "color: AppColors.primary.withValues(alpha: 0.5)": "color: AppColors.textDark.withValues(alpha: 0.1)",
    "selectedItemColor: AppColors.primary": "selectedItemColor: AppColors.primary",
    "unselectedItemColor: AppColors.primary": "unselectedItemColor: AppColors.textDark.withValues(alpha: 0.4)",
    "backgroundColor: AppColors.backgroundLight,\n          type: BottomNavigationBarType.fixed": "backgroundColor: AppColors.textPrimary,\n          type: BottomNavigationBarType.fixed" // because it replaced the background color of BottomNavigationBar
  });
}
