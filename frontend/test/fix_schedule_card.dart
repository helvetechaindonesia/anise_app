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
  // Fix ScheduleCard
  fixFile('f:/projek/anise_app/frontend/lib/features/jadwal/widgets/schedule_card.dart', {
    "color: AppColors.primary": "color: AppColors.textPrimary",
    "style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.bodyMedium(context, color: AppColors.textDark, fontWeight: FontWeight.bold)",
    "style: AppTextStyles.caption(context, color: AppColors.primary.withValues(alpha: 0.5))": "style: AppTextStyles.caption(context, color: AppColors.textDark.withValues(alpha: 0.5))",
    "color: AppColors.primary.withValues(alpha: 0.1)": "color: AppColors.textPrimary.withValues(alpha: 0.1)", // Wait, primary with alpha 0.1 is teal tint. That's fine! Let's keep it.
  });
}
