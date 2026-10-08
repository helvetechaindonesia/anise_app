import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/assessment_model.dart';
// import 'package:frontend/services/api/assessment_api.dart';

class AssessmentNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final assessmentProvider = AsyncNotifierProvider<AssessmentNotifier, List<dynamic>>(() {
  return AssessmentNotifier();
});
