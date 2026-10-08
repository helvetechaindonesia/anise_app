import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/school_profile_model.dart';
// import 'package:frontend/services/api/school_profile_api.dart';

class SchoolProfileNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final school_profileProvider = AsyncNotifierProvider<SchoolProfileNotifier, List<dynamic>>(() {
  return SchoolProfileNotifier();
});
