import 'dart:io';

void main() {
  // poin_main_card_widget.dart
  final fMain = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_main_card_widget.dart');
  if (fMain.existsSync()) {
    var c = fMain.readAsStringSync();
    
    // Background and shadow
    c = c.replaceFirst(
      "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(24.w(context)),",
      "color: AppColors.primaryContainer,\n        borderRadius: BorderRadius.circular(24.w(context)),"
    );
    c = c.replaceFirst(
      "BoxShadow(\n            color: AppColors.primary.withValues(alpha: 0.5),\n            blurRadius: 20,",
      "BoxShadow(\n            color: AppColors.onBackground.withValues(alpha: 0.05),\n            blurRadius: 20,"
    );
    
    // Replace .primary.withValues(alpha: 0.5) inside the container with .onPrimaryContainer.withValues(alpha: 0.1)
    c = c.replaceAll("AppColors.primary.withValues(alpha: 0.5)", "AppColors.onPrimaryContainer.withValues(alpha: 0.1)");
    
    // Replace .primary inside the container with .onPrimaryContainer
    c = c.replaceAll("color: AppColors.primary,", "color: AppColors.onPrimaryContainer,");
    c = c.replaceAll("color: AppColors.primary)", "color: AppColors.onPrimaryContainer)"); // For Icon and styles that end with closing paren
    
    // Wait, let's just make it simple:
    c = c.replaceAll("AppColors.primary", "AppColors.onPrimaryContainer");

    // But wait, the background was AppColors.primary initially which I changed to AppColors.primaryContainer. 
    // And AppColors.onPrimaryContainer replaced AppColors.primary.
    // This is safe. Let's write it.
    fMain.writeAsStringSync(c);
  }

  // poin_activity_list_widget.dart
  final fActivity = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_activity_list_widget.dart');
  if (fActivity.existsSync()) {
    var c = fActivity.readAsStringSync();
    
    // Filters:
    c = c.replaceAll(
      "color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),",
      "color: isSelected ? AppColors.primaryContainer : AppColors.surface,"
    );
    c = c.replaceAll(
      "border: Border.all(\n                  color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),\n                ),",
      "border: Border.all(\n                  color: isSelected ? AppColors.primaryContainer : AppColors.outline,\n                ),"
    );
    c = c.replaceAll(
      "style: AppTextStyles.bodySmall(context, color: isSelected ? AppColors.primary : AppColors.primary,",
      "style: AppTextStyles.bodySmall(context, color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,"
    );

    // Empty state text
    c = c.replaceFirst("color: AppColors.primary)", "color: AppColors.onBackground)");
    
    // Activity Cards (convert to transparent list items without shadow, with divider)
    c = c.replaceFirst("final accentColor = isPlus ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5);", "final accentColor = isPlus ? AppColors.primary : AppColors.error;");
    c = c.replaceFirst("final bgColor = isPlus ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.5);", "final bgColor = isPlus ? AppColors.secondary : AppColors.errorContainer;");
    c = c.replaceFirst("final accentColorText = isPlus ? AppColors.primary : AppColors.primary;", "final accentColorText = isPlus ? AppColors.onSecondary : AppColors.onErrorContainer;");

    c = c.replaceFirst(
      "color: AppColors.primary,\n        borderRadius: BorderRadius.circular(20.w(context)),\n        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),\n        boxShadow: [\n          BoxShadow(\n            color: AppColors.black.withValues(alpha: 0.5),\n            blurRadius: 10,\n            offset: const Offset(0, 4),\n          ),\n        ],",
      "color: Colors.transparent,\n        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.5))),"
    );

    // Update inner texts in the transparent card (since background is now transparent/backgroundLight, text should be onBackground)
    c = c.replaceAll("color: AppColors.primary", "color: AppColors.onBackground");
    c = c.replaceAll("color: AppColors.primary.withValues(alpha: 0.5)", "color: AppColors.onBackground.withValues(alpha: 0.5)");
    
    // Fix the Divider inside the card (we can just remove it or keep it as outline)
    c = c.replaceAll("Divider(color: AppColors.onBackground.withValues(alpha: 0.5), height: 1)", "Divider(color: AppColors.outline, height: 1)");

    fActivity.writeAsStringSync(c);
  }
}
