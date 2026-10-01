import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Ikon notif
  content = content.replaceAll("icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.textDark, size: 24.w(context)),", "icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),");
  
  // Nama sekolah & keterangan
  content = content.replaceAll("style: AppTextStyles.h4(context, color: AppColors.textDark),", "style: AppTextStyles.h4(context, color: AppColors.onBackground),");
  content = content.replaceAll("style: AppTextStyles.bodySmall(context, color: AppColors.textDark),", "style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),");
  
  // Sapaan
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.primary.withValues(alpha: 0.5), fontWeight: FontWeight.w600),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8), fontWeight: FontWeight.w600),");
  content = content.replaceAll("style: AppTextStyles.h1(context, color: AppColors.primary).copyWith(", "style: AppTextStyles.h1(context, color: AppColors.onBackground).copyWith(");

  file.writeAsStringSync(content);
}
