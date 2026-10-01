import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final presensiLogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('/auth/users/riwayat-presensi');
    final List<dynamic> data = response.data;
    return data.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    return []; // Fallback empty
  }
});
