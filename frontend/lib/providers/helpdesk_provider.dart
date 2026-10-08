import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/helpdesk_model.dart';
// import 'package:frontend/services/api/helpdesk_api.dart';

class HelpdeskNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final helpdeskProvider = AsyncNotifierProvider<HelpdeskNotifier, List<dynamic>>(() {
  return HelpdeskNotifier();
});
