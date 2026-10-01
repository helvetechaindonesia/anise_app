import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

final disiplinReportsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users/disiplin-reports');
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    print('Error fetching disiplin reports: $e');
    return [];
  }
});

final allSiswaProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users/all-siswa');
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    print('Error fetching all siswa: $e');
    return [];
  }
});

class DisiplinNotifier extends StateNotifier<bool> {
  final Ref ref;
  DisiplinNotifier(this.ref) : super(false);

  Future<bool> submitReport({
    required int siswaId,
    required String category,
    String? notes,
  }) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      await dio.post(
        '/users/disiplin-reports',
        data: {
          'siswa_id': siswaId,
          'category': category,
          'notes': notes,
        },
      );
      state = false;
      ref.invalidate(disiplinReportsProvider);
      return true;
    } catch (e) {
      print('Error submitting disiplin report: $e');
      state = false;
      return false;
    }
  }
}

final disiplinNotifierProvider = StateNotifierProvider<DisiplinNotifier, bool>((ref) {
  return DisiplinNotifier(ref);
});
