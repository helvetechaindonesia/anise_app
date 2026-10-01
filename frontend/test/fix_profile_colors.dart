import 'dart:io';

void main() {
  final fScreen = File('f:/projek/anise_app/frontend/lib/features/profile/screens/siswa_profile_screen.dart');
  if (fScreen.existsSync()) {
    var c = fScreen.readAsStringSync();
    
    // Fix error colors
    c = c.replaceAll("color: AppColors.errorContainer,", "color: AppColors.error.withValues(alpha: 0.1),");
    c = c.replaceAll("color: AppColors.onErrorContainer,", "color: AppColors.error,");

    fScreen.writeAsStringSync(c);
  }
}
