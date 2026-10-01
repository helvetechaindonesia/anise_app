import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/home/widgets/bimbingan_mentor_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Judul & Lihat Semua (onBackground)
  content = content.replaceAll("style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground, fontWeight: FontWeight.bold),");
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold).copyWith(height: 1.1),", "style: AppTextStyles.caption(context, color: AppColors.onBackground, fontWeight: FontWeight.bold).copyWith(height: 1.1),");
  content = content.replaceAll("Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.textDark),", "Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),");
  
  // Item card background (primaryContainer)
  content = content.replaceAll("color: AppColors.textPrimary,", "color: AppColors.primaryContainer,");
  
  // Elements inside card (onPrimaryContainer)
  // 1. Icon inside circle
  content = content.replaceAll("Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.textPrimary, size: 32.w(context)),", "Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 32.w(context)),");
  
  // 2. Online indicator border
  content = content.replaceAll("border: Border.all(color: AppColors.textPrimary, width: 2),", "border: Border.all(color: AppColors.onPrimaryContainer, width: 2),");
  
  // 3. Mentor Name & Subject
  content = content.replaceAll("style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.caption(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),");
  content = content.replaceAll("style: AppTextStyles.overline(context, color: AppColors.textDark.withValues(alpha: 0.5), fontWeight: FontWeight.w500),", "style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7), fontWeight: FontWeight.w500),");
  
  // 4. Jadwal Button
  content = content.replaceAll("color: AppColors.backgroundLight,", "color: AppColors.onPrimaryContainer,");
  content = content.replaceAll("Icon(PhosphorIcons.calendar(PhosphorIconsStyle.bold), color: AppColors.textDark, size: 12.w(context)),", "Icon(PhosphorIcons.calendar(PhosphorIconsStyle.bold), color: AppColors.primaryContainer, size: 12.w(context)),");
  content = content.replaceAll("style: AppTextStyles.overline(context, color: AppColors.textDark, fontWeight: FontWeight.bold),", "style: AppTextStyles.overline(context, color: AppColors.primaryContainer, fontWeight: FontWeight.bold),");

  file.writeAsStringSync(content);
}
