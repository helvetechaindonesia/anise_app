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
  // Fix JadwalScreen
  fixFile('f:/projek/anise_app/frontend/lib/features/jadwal/screens/jadwal_screen.dart', {
    "backgroundColor: AppColors.primary": "backgroundColor: AppColors.backgroundLight",
    "color: AppColors.primary,\n      elevation": "color: AppColors.backgroundLight,\n      elevation",
    "style: AppTextStyles.h4(context, color: AppColors.primary)": "style: AppTextStyles.h4(context, color: AppColors.textDark)",
    "Icon(PhosphorIcons.funnel(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.funnel(PhosphorIconsStyle.bold), color: AppColors.textDark",
    "Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), color: AppColors.textDark"
  });

  // Fix PoinScreen
  fixFile('f:/projek/anise_app/frontend/lib/features/poin/screens/poin_screen.dart', {
    "backgroundColor: AppColors.primary": "backgroundColor: AppColors.backgroundLight",
    "color: AppColors.primary,\n        elevation": "color: AppColors.backgroundLight,\n        elevation",
    "style: AppTextStyles.h4(context, color: AppColors.primary)": "style: AppTextStyles.h4(context, color: AppColors.textDark)",
    "Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.bold), color: AppColors.textDark"
  });

  // Fix SiswaProfileScreen
  fixFile('f:/projek/anise_app/frontend/lib/features/profile/screens/siswa_profile_screen.dart', {
    "backgroundColor: AppColors.primary": "backgroundColor: AppColors.backgroundLight",
    "color: AppColors.primary,\n        elevation": "color: AppColors.backgroundLight,\n        elevation",
    "style: AppTextStyles.h4(context, color: AppColors.primary)": "style: AppTextStyles.h4(context, color: AppColors.textDark)",
    "Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), color: AppColors.textDark"
  });
}
