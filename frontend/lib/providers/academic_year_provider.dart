import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/academic_year_model.dart';
// import 'package:frontend/services/api/academic_year_api.dart';

class AcademicYearNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final academic_yearProvider = AsyncNotifierProvider<AcademicYearNotifier, List<dynamic>>(() {
  return AcademicYearNotifier();
});
