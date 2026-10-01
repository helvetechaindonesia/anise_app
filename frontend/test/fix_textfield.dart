import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/core/widgets/anise_text_field.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll('style: const TextStyle(color: AppColors.primary, fontSize: 16),', 'style: const TextStyle(color: AppColors.onSurface, fontSize: 16),');
  content = content.replaceAll('hintStyle: TextStyle(color: AppColors.primary.withValues(alpha: 0.5), fontSize: 14),', 'hintStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),');
  
  content = content.replaceAll('return AppColors.primary.withValues(alpha: 0.5); // Warna saat diam', 'return AppColors.onSurfaceVariant; // Warna saat diam');
  content = content.replaceAll('return AppColors.primary.withValues(alpha: 0.5);', 'return AppColors.onSurfaceVariant;');
  
  content = content.replaceAll('fillColor: const Color(0xFFF0F4F8), // Soft grayish blue as per design', 'fillColor: AppColors.surfaceVariant,');
  
  content = content.replaceAll('borderSide: BorderSide.none,', 'borderSide: const BorderSide(color: AppColors.outline, width: 1.0),');

  file.writeAsStringSync(content);
}
