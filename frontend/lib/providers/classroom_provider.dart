import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/classroom_model.dart';
// import 'package:frontend/services/api/classroom_api.dart';

class ClassroomNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final classroomProvider = AsyncNotifierProvider<ClassroomNotifier, List<dynamic>>(() {
  return ClassroomNotifier();
});
