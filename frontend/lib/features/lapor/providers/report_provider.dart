import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

final studentReportsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/users/reports');
  if (response.data['status'] == 'success') {
    return response.data['data'] as List<dynamic>;
  }
  throw Exception(response.data['message']);
});
