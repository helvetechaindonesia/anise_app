import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/screens/tugas_detail_screen.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Scaffold bg
  content = content.replaceAll("backgroundColor: AppColors.primary,", "backgroundColor: AppColors.background,");
  
  // AppBar back button
  content = content.replaceAll("Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.primary),", "Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),");
  
  // AppBar title
  content = content.replaceAll("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),"); // wait, this will replace all bodyMedium(context) without colors. Let's do that!
  
  // Actually, wait, replacing all "bodyMedium(context)" with "bodyMedium(context, color: AppColors.onBackground)" might be good for the texts on background.
  // But there are texts on surface and primaryContainer. Let's be precise.
  
  // AppBar title
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.h4(context, color: AppColors.onBackground),"); // For 'Detail Tugas'
  
  // Subject container
  content = content.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),\n                    borderRadius: BorderRadius.circular(12),", "color: AppColors.secondary,\n                    borderRadius: BorderRadius.circular(12),");
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.caption(context, color: AppColors.onSecondary, fontWeight: FontWeight.bold),"); // subject
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodySmall(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),"); // Oleh teacher
  
  // Title
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.h2(context, color: AppColors.onBackground),");
  
  // Batas waktu container
  content = content.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),\n                borderRadius: BorderRadius.circular(12),\n                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),", "color: AppColors.surface,\n                borderRadius: BorderRadius.circular(12),\n                border: Border.all(color: AppColors.outline),");
  content = content.replaceFirst("Icon(PhosphorIcons.timer(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20),", "Icon(PhosphorIcons.timer(PhosphorIconsStyle.bold), color: AppColors.error, size: 20),");
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface, fontWeight: FontWeight.bold),"); // batas waktu text
  
  // Instruksi Tugas title
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.h4(context, color: AppColors.onBackground),");
  
  // Instruksi text
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground).copyWith(height: 1.6),");
  
  // Attachment container
  content = content.replaceFirst("color: AppColors.primary,\n                borderRadius: BorderRadius.circular(16),\n                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),", "color: AppColors.surface,\n                borderRadius: BorderRadius.circular(16),\n                border: Border.all(color: AppColors.outline),");
  // Attachment Icon Container
  content = content.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),\n                      borderRadius: BorderRadius.circular(12),", "color: AppColors.backgroundLight,\n                      borderRadius: BorderRadius.circular(12),");
  content = content.replaceFirst("Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.bold), color: AppColors.primary, size: 28),", "Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 28),");
  
  // Attachment texts
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface, fontWeight: FontWeight.bold),"); // filename
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.caption(context, color: AppColors.onSurface.withValues(alpha: 0.7)),"); // filesize
  content = content.replaceFirst("Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary),", "Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.onSurface),");

  // bottomNavigationBar
  content = content.replaceFirst("color: AppColors.primary,\n          boxShadow: [\n            BoxShadow(\n              color: AppColors.black.withValues(alpha: 0.5),", "color: AppColors.surface,\n          boxShadow: [\n            BoxShadow(\n              color: AppColors.onBackground.withValues(alpha: 0.05),");
  content = content.replaceFirst("backgroundColor: AppColors.primary,\n              },", "backgroundColor: AppColors.primaryContainer,\n              },"); // SnackBar
  content = content.replaceFirst("backgroundColor: AppColors.primary,\n            padding:", "backgroundColor: AppColors.primaryContainer,\n            padding:");
  content = content.replaceFirst("style: AppTextStyles.bodyMedium(context),", "style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),"); // Button text

  file.writeAsStringSync(content);
}
