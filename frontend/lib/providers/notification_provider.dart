import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/notification_model.dart';
// import 'package:frontend/services/api/notification_api.dart';

class NotificationNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final notificationProvider = AsyncNotifierProvider<NotificationNotifier, List<dynamic>>(() {
  return NotificationNotifier();
});
