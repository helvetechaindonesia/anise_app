import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/announcement_model.dart';
// import 'package:frontend/services/api/announcement_api.dart';

class AnnouncementNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final announcementProvider = AsyncNotifierProvider<AnnouncementNotifier, List<dynamic>>(() {
  return AnnouncementNotifier();
});
