import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/discipline_model.dart';
// import 'package:frontend/services/api/discipline_api.dart';

class DisciplineNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final disciplineProvider = AsyncNotifierProvider<DisciplineNotifier, List<dynamic>>(() {
  return DisciplineNotifier();
});
