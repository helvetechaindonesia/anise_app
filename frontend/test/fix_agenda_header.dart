import 'dart:io';

void main() {
  final fHeader = File('f:/projek/anise_app/frontend/lib/features/penilaian/widgets/agenda_header_widget.dart');
  if (fHeader.existsSync()) {
    var c = fHeader.readAsStringSync();
    
    // Back button
    c = c.replaceAll(
      "color: AppColors.surface,\n                  shape: BoxShape.circle,\n                  border: Border.all(color: AppColors.outline),",
      "color: AppColors.transparent,\n                  shape: BoxShape.circle,"
    );
    c = c.replaceFirst("color: AppColors.onSurface, size: 20.w(context)", "color: AppColors.onBackground, size: 20.w(context)");
    
    // Pill badge
    c = c.replaceAll(
      "color: AppColors.surface,\n            borderRadius: BorderRadius.circular(100),\n            border: Border.all(color: AppColors.outline),",
      "color: AppColors.secondary,\n            borderRadius: BorderRadius.circular(100),"
    );
    c = c.replaceFirst("color: AppColors.onSurface, size: 14.w(context)", "color: AppColors.onSecondary, size: 14.w(context)");
    c = c.replaceFirst("style: AppTextStyles.overline(context, color: AppColors.onSurface,", "style: AppTextStyles.overline(context, color: AppColors.onSecondary,");

    fHeader.writeAsStringSync(c);
  }
}
