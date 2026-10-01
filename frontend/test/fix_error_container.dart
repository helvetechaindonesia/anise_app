import 'dart:io';

void main() {
  final fActivity = File('f:/projek/anise_app/frontend/lib/features/poin/widgets/poin_activity_list_widget.dart');
  if (fActivity.existsSync()) {
    var c = fActivity.readAsStringSync();
    c = c.replaceAll("AppColors.errorContainer", "AppColors.error");
    c = c.replaceAll("AppColors.onErrorContainer", "AppColors.onPrimary"); // onPrimary is white
    fActivity.writeAsStringSync(c);
  }
}
