import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/core/constants/colors.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  content = content.replaceAll("static const Color onSecondary = Color(0xFF1C3F4A);       // Hijau Gelap (Teks di atas Secondary)", "static const Color onSecondary = Color(0xFF000000);       // Hitam (Teks di atas Secondary)");

  file.writeAsStringSync(content);
}
