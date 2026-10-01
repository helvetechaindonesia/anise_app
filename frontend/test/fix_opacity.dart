import 'dart:io';

void main() {
  final file1 = File('f:/projek/anise_app/frontend/lib/features/jadwal/widgets/schedule_card.dart');
  if (file1.existsSync()) {
    var content1 = file1.readAsStringSync();
    
    // Description text
    content1 = content1.replaceAll("color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7)", "color: isLive ? AppColors.onPrimaryContainer : AppColors.onSurface");
    
    // Footer mutedTextColor
    content1 = content1.replaceAll("Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);", "Color mutedTextColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");
    
    file1.writeAsStringSync(content1);
  }

  final file2 = File('f:/projek/anise_app/frontend/lib/features/jadwal/widgets/schedule_card_components.dart');
  if (file2.existsSync()) {
    var content2 = file2.readAsStringSync();
    
    // mutedTextColor
    content2 = content2.replaceAll("Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);", "Color mutedTextColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");
    
    // subtitleColor
    content2 = content2.replaceAll("Color subtitleColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7);", "Color subtitleColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;");

    file2.writeAsStringSync(content2);
  }
}
