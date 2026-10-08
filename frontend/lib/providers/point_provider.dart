import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/point_model.dart';
// import 'package:frontend/services/api/point_api.dart';

class PointNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final pointProvider = AsyncNotifierProvider<PointNotifier, List<dynamic>>(() {
  return PointNotifier();
});
