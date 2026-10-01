import 'dart:io';

void main() {
  // poin_screen.dart
  final fScreen = File('f:/projek/anise_app/frontend/lib/features/poin/screens/poin_screen.dart');
  if (fScreen.existsSync()) {
    var c = fScreen.readAsStringSync();
    c = c.replaceAll("AppColors.backgroundLight,", "AppColors.background,");
    c = c.replaceFirst("AppColors.background,\n      elevation: 0,", "AppColors.surface,\n      elevation: 0,");
    c = c.replaceAll("color: AppColors.textDark", "color: AppColors.onSurface");
    c = c.replaceAll("color: AppColors.primary, fontWeight: FontWeight.w500", "color: AppColors.onSurface, fontWeight: FontWeight.w500");
    c = c.replaceAll("Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.primary", "Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface");
    fScreen.writeAsStringSync(c);
  }

  // poin_header_widget.dart
  final fHeader = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_header_widget.dart');
  if (fHeader.existsSync()) {
    var c = fHeader.readAsStringSync();
    c = c.replaceFirst("color: AppColors.primary", "color: AppColors.onBackground");
    c = c.replaceFirst("color: AppColors.primary", "color: AppColors.onBackground.withValues(alpha: 0.7)");
    c = c.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5)", "color: AppColors.primaryContainer");
    c = c.replaceFirst("color: AppColors.primary", "color: AppColors.onPrimaryContainer");
    fHeader.writeAsStringSync(c);
  }

  // poin_target_card_widget.dart
  final fTarget = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_target_card_widget.dart');
  if (fTarget.existsSync()) {
    var c = fTarget.readAsStringSync();
    c = c.replaceFirst("color: AppColors.primary.withValues(alpha: 0.5),", "color: AppColors.secondary,");
    c = c.replaceFirst("border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),", "border: Border.all(color: AppColors.outline),"); // or remove border
    c = c.replaceFirst("color: AppColors.primary,", "color: AppColors.onSecondary.withValues(alpha: 0.2),");
    c = c.replaceAll("color: AppColors.primary", "color: AppColors.onSecondary");
    fTarget.writeAsStringSync(c);
  }
}
