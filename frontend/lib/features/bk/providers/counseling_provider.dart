import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

// Model sederhana untuk guru BK
class GuruBkData {
  final String id;
  final String name;
  final String email;

  GuruBkData({required this.id, required this.name, required this.email});

  factory GuruBkData.fromJson(Map<String, dynamic> json) => GuruBkData(
        id: json['id'].toString(),
        name: json['name'].toString(),
        email: json['email']?.toString() ?? '',
      );
}

// Provider untuk data guru BK siswa
final guruBkProvider = FutureProvider.autoDispose<GuruBkData?>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/counseling/guru-bk');
    if (response.data['status'] == 'success') {
      return GuruBkData.fromJson(response.data['data']);
    }
    return null;
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return null;
    rethrow;
  }
});

// Provider untuk riwayat pengajuan bimbingan siswa
final siswaKonsultasiProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/counseling/siswa');
    if (response.data['status'] == 'success') {
      return (response.data['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    rethrow;
  }
});

// Notifier untuk submit pengajuan
class CounselingNotifier extends StateNotifier<AsyncValue<void>> {
  final Dio _dio;
  CounselingNotifier(this._dio) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String topic,
    required String scheduleDate,
    required String scheduleTime,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post('/counseling', data: {
        'topic': topic,
        'schedule_date': scheduleDate,
        'schedule_time': scheduleTime,
        'description': description,
      });
      state = const AsyncValue.data(null);
      return response.data['status'] == 'success';
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final counselingNotifierProvider = StateNotifierProvider<CounselingNotifier, AsyncValue<void>>((ref) {
  return CounselingNotifier(ref.watch(dioProvider));
});
