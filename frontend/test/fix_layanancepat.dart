import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/layanan_cepat_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Judul
  content = content.replaceAll("style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),");
  
  // Background Tombol
  content = content.replaceAll("color: AppColors.textPrimary,", "color: AppColors.surface,\n                      border: Border.all(color: AppColors.outline),");
  
  // Text Keterangan
  content = content.replaceAll("style: AppTextStyles.overline(context, color: AppColors.textDark.withValues(alpha: 0.8), fontWeight: FontWeight.w600),", "style: AppTextStyles.overline(context, color: AppColors.onSurface, fontWeight: FontWeight.w600),");

  file.writeAsStringSync(content);
}
