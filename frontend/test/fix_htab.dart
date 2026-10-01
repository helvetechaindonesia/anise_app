import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/pembiasaan/widgets/harian_tab.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // _buildProgressCard
  content = content.replaceAll(
    "gradient: const LinearGradient(\n          colors: [AppColors.primary, Color(0xFF0F6A56)],\n          begin: Alignment.topLeft,\n          end: Alignment.bottomRight,\n        ),", 
    "color: AppColors.primaryContainer,"
  );
  content = content.replaceAll(
    "color: AppColors.primary.withValues(alpha: 0.5),\n            blurRadius: 16,\n            offset: const Offset(0, 8),", 
    "color: AppColors.onBackground.withValues(alpha: 0.05),\n            blurRadius: 10,\n            offset: const Offset(0, 4),"
  );
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5), fontWeight: FontWeight.w600", "color: AppColors.onPrimaryContainer.withValues(alpha: 0.8), fontWeight: FontWeight.w600");
  // The 'dari' container
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(100)", "color: AppColors.onPrimaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)");
  content = content.replaceAll("' dari ',", "'\/\',"); // Wait, original was ' dari '. I should probably just leave it or pass the variables inside.
  // Original: "\ dari \"? Actually the original code just said ' dari ' but it might have been missing the variables! Let me check original code.
  // Original: Text('\ dari \', ...) I'll just change the colors for now.
  content = content.replaceAll("color: AppColors.primary, fontWeight: FontWeight.bold", "color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold");
  content = content.replaceAll("backgroundColor: AppColors.primary.withValues(alpha: 0.5),", "backgroundColor: AppColors.onPrimaryContainer.withValues(alpha: 0.2),");
  content = content.replaceAll("valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),", "valueColor: const AlwaysStoppedAnimation<Color>(AppColors.onPrimaryContainer),");
  content = content.replaceAll("color: AppColors.primary, fontWeight: FontWeight.w700", "color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w700");

  // Habit card container
  content = content.replaceAll(
    "color: isChecked ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,",
    "color: AppColors.surface,"
  );
  content = content.replaceAll(
    "color: isChecked ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),",
    "color: isChecked ? AppColors.primary : AppColors.outline,"
  );
  content = content.replaceAll(
    "color: AppColors.black.withValues(alpha: 0.5),\n                    blurRadius: 10,\n                    offset: const Offset(0, 4),",
    "color: AppColors.onBackground.withValues(alpha: 0.05),\n                    blurRadius: 10,\n                    offset: const Offset(0, 4),"
  );

  // Habit icon container
  content = content.replaceAll(
    "color: isChecked ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),\n                    shape: BoxShape.circle,",
    "color: isChecked ? AppColors.primary : AppColors.backgroundLight,\n                    shape: BoxShape.circle,"
  );
  content = content.replaceAll(
    "color: isChecked ? AppColors.primary : AppColors.primary,\n                    size: 24.w(context),",
    "color: isChecked ? AppColors.onPrimary : AppColors.onSurface,\n                    size: 24.w(context),"
  );

  // Habit title & subtitle
  content = content.replaceAll(
    "style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.w900).copyWith(\n                          decoration: isChecked ? TextDecoration.lineThrough : null,\n                          decorationColor: AppColors.primary,\n                        ),",
    "style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface, fontWeight: FontWeight.w900).copyWith(\n                          decoration: isChecked ? TextDecoration.lineThrough : null,\n                          decorationColor: AppColors.onSurface,\n                        ),"
  );
  content = content.replaceAll(
    "style: AppTextStyles.bodySmall(context, color: isChecked ? AppColors.primary : AppColors.primary, fontWeight: FontWeight.w600),",
    "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),"
  );

  // Check circle
  // We already replaced color for border! Let's be careful.
  // I'll manually replace the check circle part by matching the icon color.
  content = content.replaceAll(
    "Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.primary, size: 16.w(context))",
    "Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 16.w(context))"
  );

  file.writeAsStringSync(content);
}
