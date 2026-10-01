import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/jadwal/widgets/schedule_card.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Update description text color
  content = content.replaceAll("AppTextStyles.bodySmall(context, color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant)", "AppTextStyles.bodySmall(context, color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7))");
  
  // Footer colors
  content = content.replaceAll("Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;", "Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");
  content = content.replaceAll("Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant;", "Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);");
  
  // Bottom Sheet Header colors
  content = content.replaceAll("Icon(PhosphorIcons.chatTeardrop(PhosphorIconsStyle.light), size: 48.w(context), color: AppColors.onSurfaceVariant.withValues(alpha: 0.5))", "Icon(PhosphorIcons.chatTeardrop(PhosphorIconsStyle.light), size: 48.w(context), color: AppColors.onSurface.withValues(alpha: 0.5))");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)", "style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))");
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)", "style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)");

  file.writeAsStringSync(content);
}
