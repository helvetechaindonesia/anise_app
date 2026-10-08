import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/leave_model.dart';
// import 'package:frontend/services/api/leave_api.dart';

class LeaveNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final leaveProvider = AsyncNotifierProvider<LeaveNotifier, List<dynamic>>(() {
  return LeaveNotifier();
});
