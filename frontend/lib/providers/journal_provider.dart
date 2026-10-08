import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/journal_model.dart';
// import 'package:frontend/services/api/journal_api.dart';

class JournalNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final journalProvider = AsyncNotifierProvider<JournalNotifier, List<dynamic>>(() {
  return JournalNotifier();
});
