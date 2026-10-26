import 'package:flutter/material.dart';
import '../screens/guru_isi_jurnal_screen.dart';

/// Adapter wrapper backward-compatibility agar pemanggilan GuruIsiJurnalDialog.show(...)
/// langsung membuka GuruIsiJurnalScreen secara Full Page.
class GuruIsiJurnalDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String journalId,
    required String subjectName,
    required String className,
    required String timeRange,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GuruIsiJurnalScreen(
          journalId: journalId,
          subjectName: subjectName,
          className: className,
          timeRange: timeRange,
        ),
      ),
    );
  }
}
