import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import model dan repository/API service terkait
// import 'package:frontend/models/inventory_model.dart';
// import 'package:frontend/services/api/inventory_api.dart';

class InventoryNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    // Return initial state
    return [];
  }

  // Tambahkan fungsi untuk manipulasi state di sini (fetch, add, update, delete)
}

final inventoryProvider = AsyncNotifierProvider<InventoryNotifier, List<dynamic>>(() {
  return InventoryNotifier();
});
