import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/jadwal/widgets/schedule_card_components.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // TeacherHeaderWidget
  content = content.replaceAll("Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant;", "Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);");
  content = content.replaceAll("Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;", "Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");
  // Profile picture background
  content = content.replaceAll("color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),", "color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.1),");
  
  // PostTitleWidget
  content = content.replaceAll("Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;", "Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");
  content = content.replaceAll("Color subtitleColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.primary;", "Color subtitleColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);");
  
  // FileAttachmentWidget
  content = content.replaceAll("Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant;", "Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);");
  content = content.replaceAll("Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;", "Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");
  content = content.replaceAll("Color bgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.surfaceVariant;", "Color bgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.backgroundLight;"); // Wait, backgroundLight or surfaceVariant? Let's use backgroundLight so it pops off the surface. Or outline? Let's use outline with very low alpha, or just outline. Actually, backgroundLight is good.
  content = content.replaceAll("Color iconBgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1);", "Color iconBgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.1);");
  
  // ImageGridWidget
  content = content.replaceAll("Color placeholderColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.surfaceVariant;", "Color placeholderColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.backgroundLight;");
  content = content.replaceAll("Color iconColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.5) : AppColors.onSurfaceVariant;", "Color iconColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.5);");

  // RatingSectionWidget
  content = content.replaceAll("color: AppColors.primary.withValues(alpha: 0.05),", "color: AppColors.backgroundLight,");

  file.writeAsStringSync(content);
}
