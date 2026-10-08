import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/kpi_model.dart';
// import 'package:frontend/services/api/kpi_api.dart';

class KpiNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final kpiProvider = AsyncNotifierProvider<KpiNotifier, List<dynamic>>(() {
  return KpiNotifier();
});
