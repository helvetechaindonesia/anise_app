import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/widgets/presensi_rekap_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Fix Hadir Penuh text
  content = content.replaceAll("Text('Hadir Penuh', style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),", 
                               "Text('Hadir Penuh', style: AppTextStyles.overline(context, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),");
  
  // Fix Terlambat text
  content = content.replaceAll("Text('Terlambat', style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),", 
                               "Text('Terlambat', style: AppTextStyles.overline(context, color: AppColors.error, fontWeight: FontWeight.w600)),");

  file.writeAsStringSync(content);
}
