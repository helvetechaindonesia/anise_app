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
  // Fix SiswaHomeScreen
  fixFile('f:/projek/anise_app/frontend/lib/features/home/screens/siswa_home_screen.dart', {
    'backgroundColor: AppColors.transparent': 'backgroundColor: AppColors.backgroundLight',
    'backgroundColor: AppColors.primary': 'backgroundColor: AppColors.backgroundLight',
    'style: AppTextStyles.h4(context)': 'style: AppTextStyles.h4(context, color: AppColors.textDark)',
    'style: AppTextStyles.bodySmall(context)': 'style: AppTextStyles.bodySmall(context, color: AppColors.textDark)',
    'Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary': 'Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.textDark',
    "Text(\n                      _getGreeting(),\n                      style: AppTextStyles.bodyMedium(context, color: AppColors.primary.withValues(alpha: 0.5), fontWeight: FontWeight.w600),\n                    )": "Text(\n                      _getGreeting(),\n                      style: AppTextStyles.bodyMedium(context, color: AppColors.textDark.withValues(alpha: 0.5), fontWeight: FontWeight.w600),\n                    )",
    "Text(\n                      '\!!',\n                      style: AppTextStyles.h1(context, color: AppColors.primary).copyWith(": "Text(\n                      '\!!',\n                      style: AppTextStyles.h1(context, color: AppColors.textDark).copyWith("
  });

  // Fix DecorativeBackground
  fixFile('f:/projek/anise_app/frontend/lib/core/widgets/decorative_background.dart', {
    'color: AppColors.primary.withValues(alpha: 0.5)': 'color: AppColors.primary.withValues(alpha: 0.05)',
    'color: AppColors.primary.withValues(alpha: 0.3)': 'color: AppColors.primary.withValues(alpha: 0.03)'
  });
}
