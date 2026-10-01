import 'dart:io';

void main() {
  // Fix poin_header_widget.dart
  final fHeader = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_header_widget.dart');
  if (fHeader.existsSync()) {
    var c = fHeader.readAsStringSync();
    c = c.replaceAll(
      "PhosphorIcons.medal(PhosphorIconsStyle.bold),\n            color: AppColors.primary,",
      "PhosphorIcons.medal(PhosphorIconsStyle.bold),\n            color: AppColors.onPrimaryContainer,"
    );
    fHeader.writeAsStringSync(c);
  }

  // Fix poin_main_card_widget.dart
  final fMain = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_main_card_widget.dart');
  if (fMain.existsSync()) {
    var c = fMain.readAsStringSync();
    
    // Top Row overflow fix: wrap the first Container in Expanded
    c = c.replaceFirst(
      "Container(\n                padding: EdgeInsets.symmetric",
      "Expanded(\n                child: Container(\n                  padding: EdgeInsets.symmetric"
    );
    // Find the end of this Container and close the Expanded, and add some spacing before the next Row
    c = c.replaceFirst(
      "          Row(\n                children: [\n                  Icon(PhosphorIcons.star",
      "              SizedBox(width: 8.w(context)),\n              Row(\n                children: [\n                  Icon(PhosphorIcons.star"
    );
    // The replaceFirst for Expanded needs to close the bracket. The original had:
    // Container( ... child: Row(...) ), 
    // Row( ... )
    // We just wrap the Container. Let's do it carefully with regex or string replacement.
    // It's safer to just provide the exact replacement for the Top Row.
    
    // First, let's fix the colors.
    // Replace all AppColors.onPrimaryContainer.withValues(alpha: 0.1) with AppColors.primary (for backgrounds) 
    // EXCEPT inside AppTextStyles, where it should be AppColors.onPrimaryContainer.
    c = c.replaceAll("color: AppColors.onPrimaryContainer.withValues(alpha: 0.1),", "color: AppColors.primary,");
    c = c.replaceAll("AppTextStyles.overline(context, color: AppColors.primary,", "AppTextStyles.overline(context, color: AppColors.onPrimaryContainer,");
    c = c.replaceAll("color: AppColors.primary), fontWeight:", "color: AppColors.onPrimaryContainer, fontWeight:"); // caught by previous line?
    
    // Let's just fix all text styles that might have gotten the wrong color.
    c = c.replaceAll("style: AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.bold),", "style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.bold),");
    c = c.replaceAll("style: AppTextStyles.overline(context, color: AppColors.primary, fontWeight: FontWeight.w600),", "style: AppTextStyles.overline(context, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600),");
    
    // Bottom row icon colors
    c = c.replaceAll("color: AppColors.onPrimaryContainer.withValues(alpha: 0.1), size: 16.w(context)", "color: AppColors.onPrimaryContainer, size: 16.w(context)");

    fMain.writeAsStringSync(c);
  }
}
