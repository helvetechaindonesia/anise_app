import 'dart:io';

void main() {
  final fScreen = File('f:/projek/anise_app/frontend/lib/features/penilaian/screens/agenda_penilaian_screen.dart');
  if (fScreen.existsSync()) {
    var c = fScreen.readAsStringSync();
    c = c.replaceAll("color: AppColors.background,", "color: AppColors.backgroundLight,");
    fScreen.writeAsStringSync(c);
  }

  final fBanner = File('f:/projek/anise_app/frontend/lib/features/penilaian/widgets/agenda_bottom_banner_widget.dart');
  if (fBanner.existsSync()) {
    var c = fBanner.readAsStringSync();
    c = c.replaceAll("const BoxDecoration(", "BoxDecoration(");
    fBanner.writeAsStringSync(c);
  }
}
