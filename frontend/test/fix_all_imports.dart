import 'dart:io';

void main() {
  final dir = Directory('f:/projek/anise_app/frontend/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    var original = content;

    // Use simple string replacement for known bad paths
    content = content.replaceAll(
      "import '../../../../core/theme/app_text_styles.dart';",
      "import 'package:anise_app/core/theme/app_text_styles.dart';"
    );
    content = content.replaceAll(
      "import '../../../core/theme/app_text_styles.dart';",
      "import 'package:anise_app/core/theme/app_text_styles.dart';"
    );
    content = content.replaceAll(
      "import '../../core/theme/app_text_styles.dart';",
      "import 'package:anise_app/core/theme/app_text_styles.dart';"
    );
    content = content.replaceAll(
      "import '../core/theme/app_text_styles.dart';",
      "import 'package:anise_app/core/theme/app_text_styles.dart';"
    );

    if (content != original) {
      file.writeAsStringSync(content);
      print('Fixed imports in: ' + file.path);
    }
  }
}
