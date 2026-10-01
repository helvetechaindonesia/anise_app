import 'dart:io';

void main() {
  final dir = Directory('f:/projek/anise_app/frontend/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    var content = file.readAsStringSync();
    var original = content;

    content = content.replaceAll('package:anise_app/', 'package:frontend/');

    if (content != original) {
      file.writeAsStringSync(content);
      print('Fixed package name in: ' + file.path);
    }
  }
}
