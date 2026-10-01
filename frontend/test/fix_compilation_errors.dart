import 'dart:io';

void main() {
  // poin_target_card_widget.dart
  final fTarget = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_target_card_widget.dart');
  if (fTarget.existsSync()) {
    var c = fTarget.readAsStringSync();
    c = c.replaceAll("const BoxDecoration(", "BoxDecoration(");
    fTarget.writeAsStringSync(c);
  }

  // poin_main_card_widget.dart
  final fMain = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_main_card_widget.dart');
  if (fMain.existsSync()) {
    var c = fMain.readAsStringSync();
    c = c.replaceAll("AppColors.onPrimaryContainerContainer", "AppColors.primaryContainer");
    fMain.writeAsStringSync(c);
  }

  // poin_header_widget.dart
  final fHeader = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_header_widget.dart');
  if (fHeader.existsSync()) {
    var c = fHeader.readAsStringSync();
    c = c.replaceAll("AppColors.onPrimaryContainerContainer", "AppColors.primaryContainer");
    fHeader.writeAsStringSync(c);
  }
}
