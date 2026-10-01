import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Sapaan pake onBackground (it should already be onBackground, but just to be sure)
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8), fontWeight: FontWeight.w600),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground, fontWeight: FontWeight.w600),");
  
  // Ikon notif di header diganti onSurface
  content = content.replaceAll("icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),", "icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),");

  file.writeAsStringSync(content);
}
