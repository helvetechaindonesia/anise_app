import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/pembiasaan/widgets/harian_tab.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  // Exactly matching : AppColors.background,
  content = content.replaceAll(
    "AppColors.background,",
    "AppColors.backgroundLight,"
  );

  file.writeAsStringSync(content);
}
