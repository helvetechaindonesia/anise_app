import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/user_model.dart';
// import 'package:frontend/services/api/user_api.dart';

class UserNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final userProvider = AsyncNotifierProvider<UserNotifier, List<dynamic>>(() {
  return UserNotifier();
});
