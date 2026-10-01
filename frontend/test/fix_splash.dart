import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/auth/screens/splash_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll('backgroundColor: AppColors.primary,', 'backgroundColor: AppColors.backgroundLight,');
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, fontWeight: FontWeight.w600).copyWith(fontSize: 14, letterSpacing: 0),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.w600).copyWith(fontSize: 14, letterSpacing: 0),");

  file.writeAsStringSync(content);
}
