import 'dart:io';

void main() {
  final files = [
    'lib/features/home/screens/siswa_home_screen.dart',
    'lib/features/home/widgets/ai_chatbot_snippet.dart',
    'lib/features/home/widgets/digital_id_card.dart',
    'lib/features/home/widgets/quick_menu_grid.dart',
  ];

  final regex = RegExp(r'PhosphorIcons\.([a-zA-Z]+)\(\)');

  for (final path in files) {
    final file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      content = content.replaceAllMapped(regex, (match) {
        return 'PhosphorIcons.${match.group(1)}(PhosphorIconsStyle.bold)';
      });
      file.writeAsStringSync(content);
      print('Updated $path');
    }
  }
}
