import 'dart:io';

void main() {
  final fStats = File('f:/projek/anise_app/frontend/lib/features/profile/widgets/siswa_stats_row_widget.dart');
  var cStats = fStats.readAsStringSync();
  cStats = cStats.replaceAll("border: Border.all(color: AppColors.outline)", "/* border removed */");
  cStats = cStats.replaceAll("subtitleColor: AppColors.secondary,", "subtitleColor: AppColors.onSurface,");
  fStats.writeAsStringSync(cStats);

  final fMenu = File('f:/projek/anise_app/frontend/lib/features/profile/widgets/profile_menu_widget.dart');
  var cMenu = fMenu.readAsStringSync();
  cMenu = cMenu.replaceAll("border: Border.all(color: AppColors.outline),", "");
  fMenu.writeAsStringSync(cMenu);
}
