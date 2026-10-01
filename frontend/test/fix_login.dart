import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/auth/screens/login_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // nama sekolah dan keterangan pake onBackground
  content = content.replaceAll("style: AppTextStyles.h1(context, color: AppColors.textDark),", "style: AppTextStyles.h1(context, color: AppColors.onBackground),");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary, fontWeight: FontWeight.w600),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.w600),");
  
  // Form container uses surface color
  content = content.replaceAll("color: AppColors.textPrimary,", "color: AppColors.surface,");
  
  // Nama formnya pake onBackground
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),");
  
  // Button pake primary, tulisan pake onPrimary
  content = content.replaceAll("foregroundColor: AppColors.textPrimary,", "foregroundColor: AppColors.onPrimary,");
  content = content.replaceAll("color: AppColors.textPrimary, strokeWidth: 3", "color: AppColors.onPrimary, strokeWidth: 3");
  content = content.replaceAll("color: AppColors.textPrimary,", "color: AppColors.onPrimary,");
  
  // Ingat saya, lupa password, bantuan dibawah pake onBackground
  content = content.replaceAll("style: AppTextStyles.bodySmall(context, color: AppColors.textDark),", "style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),");
  content = content.replaceAll("style: AppTextStyles.bodySmall(context, color: AppColors.primary, fontWeight: FontWeight.w600),", "style: AppTextStyles.bodySmall(context, color: AppColors.onBackground, fontWeight: FontWeight.w600),");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.bold),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),");
  
  file.writeAsStringSync(content);
}
