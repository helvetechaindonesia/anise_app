import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/schedule_model.dart';
// import 'package:frontend/services/api/schedule_api.dart';

class ScheduleNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final scheduleProvider = AsyncNotifierProvider<ScheduleNotifier, List<dynamic>>(() {
  return ScheduleNotifier();
});
