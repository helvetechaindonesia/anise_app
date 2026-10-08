import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/attendance_model.dart';
// import 'package:frontend/services/api/attendance_api.dart';

class AttendanceNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final attendanceProvider = AsyncNotifierProvider<AttendanceNotifier, List<dynamic>>(() {
  return AttendanceNotifier();
});
