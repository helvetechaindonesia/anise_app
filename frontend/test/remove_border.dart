import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/tugas/widgets/tugas_item_card.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Remove border
  content = content.replaceAll("border: Border.all(color: AppColors.outline),", "");

  file.writeAsStringSync(content);
}
