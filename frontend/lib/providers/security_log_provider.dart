import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/security_log_model.dart';
// import 'package:frontend/services/api/security_log_api.dart';

class SecurityLogNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final security_logProvider = AsyncNotifierProvider<SecurityLogNotifier, List<dynamic>>(() {
  return SecurityLogNotifier();
});
