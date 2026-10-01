import 'dart:io';

void main() {
  final dir = Directory('f:/projek/anise_app/frontend/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    final content = file.readAsStringSync();
    if (content.contains('AppTextStyles') && !content.contains('app_text_styles.dart')) {
      print('Missing import in: ${file.path}');
      
      // Fix it automatically
      final importString = "import 'package:anise_app/core/theme/app_text_styles.dart';\n";
      final newContent = importString + content;
      file.writeAsStringSync(newContent);
    }
  }
}
