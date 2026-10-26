import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

final selectedDisiplinDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final disiplinReportsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final selectedDate = ref.watch(selectedDisiplinDateProvider);
  final dateStr =
      "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

  try {
    final response = await dio.get(
      '/discipline/reports',
      queryParameters: {'date': dateStr},
    );
    if (response.data is Map && response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    print('Error fetching disiplin reports: $e');
    return [];
  }
});

final allSiswaProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/discipline/students');
    if (response.data is Map && response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    print('Error fetching all siswa: $e');
    return [];
  }
});

class DisiplinNotifier extends StateNotifier<bool> {
  final Ref ref;
  DisiplinNotifier(this.ref) : super(false);

  Future<Map<String, dynamic>> submitReport({
    required String siswaId,
    required String category,
    String? notes,
  }) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      final res = await dio.post(
        '/discipline/reports',
        data: {
          'siswa_id': siswaId,
          'category': category,
          'notes': notes,
        },
      );
      state = false;
      ref.invalidate(disiplinReportsProvider);
      return {
        'success': true,
        'message': res.data['message'] ?? 'Berhasil mencatat kedisiplinan',
        'is_guru_wali': res.data['data']?['is_guru_wali'] ?? false,
      };
    } catch (e) {
      print('Error submitting disiplin report: $e');
      state = false;
      String err = 'Gagal mengirim laporan';
      if (e is DioException && e.response?.data is Map) {
        err = e.response?.data['message'] ?? err;
      }
      return {'success': false, 'message': err};
    }
  }

  Future<bool> approveReport({
    required dynamic reportId,
    String? notes,
  }) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      await dio.put(
        '/discipline/reports/$reportId/approve',
        data: {
          if (notes != null) 'notes': notes,
        },
      );
      state = false;
      ref.invalidate(disiplinReportsProvider);
      return true;
    } catch (e) {
      print('Error approving report: $e');
      state = false;
      return false;
    }
  }
}

final disiplinNotifierProvider = StateNotifierProvider<DisiplinNotifier, bool>((ref) {
  return DisiplinNotifier(ref);
});

