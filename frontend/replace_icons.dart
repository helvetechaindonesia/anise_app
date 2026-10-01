import 'dart:io';

void main() {
  void replaceInFile(String path, Map<String, String> replacements) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    var content = file.readAsStringSync();
    if (!content.contains('package:phosphor_flutter/phosphor_flutter.dart')) {
      content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:phosphor_flutter/phosphor_flutter.dart';");
    }
    
    replacements.forEach((key, value) {
      content = content.replaceAll(key, value);
    });
    
    file.writeAsStringSync(content);
  }

  replaceInFile(
    'lib/features/home/widgets/ai_chatbot_snippet.dart', 
    {
      'Icons.smart_toy': 'PhosphorIcons.robot()',
      'Icons.send': 'PhosphorIcons.paperPlaneRight()',
    }
  );

  replaceInFile(
    'lib/features/home/widgets/digital_id_card.dart', 
    {
      'Icons.person': 'PhosphorIcons.user()',
      'Icons.check_circle': 'PhosphorIcons.checkCircle()',
    }
  );

  replaceInFile(
    'lib/features/home/widgets/quick_menu_grid.dart', 
    {
      'Icons.camera_alt_outlined': 'PhosphorIcons.camera()',
      'Icons.edit_document': 'PhosphorIcons.pencilSimple()',
      'Icons.assessment_outlined': 'PhosphorIcons.chartBar()',
      'Icons.checklist': 'PhosphorIcons.listChecks()',
      'Icons.assignment_outlined': 'PhosphorIcons.clipboardText()',
      'Icons.history': 'PhosphorIcons.clockCounterClockwise()',
      'Icons.emoji_events_outlined': 'PhosphorIcons.trophy()',
      'Icons.people_outline': 'PhosphorIcons.users()',
      'Icons.settings_outlined': 'PhosphorIcons.gear()',
    }
  );
}
