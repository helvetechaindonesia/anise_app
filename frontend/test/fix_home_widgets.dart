import 'dart:io';

void fixFile(String filePath, Map<String, String> replacements) {
  final file = File(filePath);
  if (!file.existsSync()) return;
  
  var content = file.readAsStringSync();
  var original = content;

  replacements.forEach((key, value) {
    content = content.replaceAll(key, value);
  });

  if (content != original) {
    file.writeAsStringSync(content);
    print('Fixed colors in: ' + filePath);
  }
}

void main() {
  // Fix IdentityCard3DWidget
  fixFile('f:/projek/anise_app/frontend/lib/features/home/widgets/identity_card_3d_widget.dart', {
    'color: AppColors.primary, // background of card?': 'color: AppColors.textDark,', // actually wait, the decorative gradient was primary. Let's make the card primary, but text white.
    "style: AppTextStyles.overline(context, color: AppColors.primary.withValues(alpha: 0.5), fontWeight: FontWeight.bold)": "style: AppTextStyles.overline(context, color: AppColors.textPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.bold)",
    "style: AppTextStyles.bodyMedium(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary, fontWeight: FontWeight.bold)",
    "style: AppTextStyles.bodyLarge(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.bodyLarge(context, color: AppColors.textPrimary, fontWeight: FontWeight.bold)",
    "Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.textDark", // because the container is white/primary.withValues
    "color: AppColors.primary.withValues(alpha: 0.5)": "color: AppColors.textPrimary.withValues(alpha: 0.2)",
    "Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.textPrimary",
    "border: Border.all(color: AppColors.primary, width: 2)": "border: Border.all(color: AppColors.textPrimary, width: 2)",
    "color: AppColors.primary,\n                                  shape: BoxShape.circle,": "color: Colors.green,\n                                  shape: BoxShape.circle,"
  });

  // Fix LayananCepatWidget
  fixFile('f:/projek/anise_app/frontend/lib/features/home/widgets/layanan_cepat_widget.dart', {
    "color: AppColors.primary": "color: AppColors.textPrimary", // background of items
    "AppColors.primary.withValues(alpha: 0.05)": "AppColors.primary.withValues(alpha: 0.05)", 
    "style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)": "style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.w600)",
    "style: AppTextStyles.bodyLarge(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold)"
  });

  // Fix BimbinganMentorWidget
  fixFile('f:/projek/anise_app/frontend/lib/features/home/widgets/bimbingan_mentor_widget.dart', {
    "color: AppColors.primary": "color: AppColors.textPrimary",
    "style: AppTextStyles.bodyLarge(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold)",
    "style: AppTextStyles.caption(context, color: AppColors.primary.withValues(alpha: 0.5))": "style: AppTextStyles.caption(context, color: AppColors.textDark.withValues(alpha: 0.5))",
    "style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.w600)": "style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.w600)",
    "style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.caption(context, color: AppColors.textDark, fontWeight: FontWeight.bold)",
    "Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.primary": "Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.textDark"
  });

  // Fix TugasMendatangWidget
  fixFile('f:/projek/anise_app/frontend/lib/features/home/widgets/tugas_mendatang_widget.dart', {
    "color: AppColors.primary": "color: AppColors.textPrimary",
    "style: AppTextStyles.bodyLarge(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold)",
    "style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)": "style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)"
  });
}
