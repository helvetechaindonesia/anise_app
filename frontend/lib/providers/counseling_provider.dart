import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/counseling_model.dart';
// import 'package:frontend/services/api/counseling_api.dart';

class CounselingNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final counselingProvider = AsyncNotifierProvider<CounselingNotifier, List<dynamic>>(() {
  return CounselingNotifier();
});
