import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/pembiasaan/widgets/harian_tab.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  // Progress text fix
  content = content.replaceAll(
    "Text(\n                  '/',",
    "Text(\n                  '\/\',"
  );

  // Active item background & border
  content = content.replaceAll(
    "color: AppColors.surface,\n              borderRadius: BorderRadius.circular(20.w(context)),\n              border: Border.all(\n                color: isChecked ? AppColors.primary : AppColors.outline,",
    "color: isChecked ? AppColors.secondary : AppColors.surface,\n              borderRadius: BorderRadius.circular(20.w(context)),\n              border: Border.all(\n                color: isChecked ? AppColors.secondary : AppColors.outline,"
  );

  // Icon container
  content = content.replaceAll(
    "color: isChecked ? AppColors.primary : AppColors.outline,\n                    shape: BoxShape.circle,",
    "color: isChecked ? AppColors.onSecondary.withValues(alpha: 0.2) : AppColors.background,\n                    shape: BoxShape.circle,"
  );
  content = content.replaceAll(
    "color: isChecked ? AppColors.onPrimary : AppColors.onSurface,\n                    size: 24.w(context),",
    "color: isChecked ? AppColors.onSecondary : AppColors.onSurface,\n                    size: 24.w(context),"
  );

  // Texts
  content = content.replaceAll(
    "style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface, fontWeight: FontWeight.w900)",
    "style: AppTextStyles.bodyMedium(context, color: isChecked ? AppColors.onSecondary : AppColors.onSurface, fontWeight: FontWeight.w900)"
  );
  content = content.replaceAll(
    "decorationColor: AppColors.onSurface,",
    "decorationColor: isChecked ? AppColors.onSecondary : AppColors.onSurface,"
  );
  content = content.replaceAll(
    "style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),",
    "style: AppTextStyles.bodySmall(context, color: isChecked ? AppColors.onSecondary.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),"
  );

  // Check circle
  content = content.replaceAll(
    "color: isChecked ? AppColors.primary : AppColors.transparent,\n                    shape: BoxShape.circle,\n                    border: Border.all(\n                      color: isChecked ? AppColors.primary : AppColors.outline,",
    "color: isChecked ? AppColors.onSecondary : AppColors.transparent,\n                    shape: BoxShape.circle,\n                    border: Border.all(\n                      color: isChecked ? AppColors.onSecondary : AppColors.outline,"
  );
  content = content.replaceAll(
    "Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 16.w(context))",
    "Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.secondary, size: 16.w(context))"
  );

  file.writeAsStringSync(content);
}
