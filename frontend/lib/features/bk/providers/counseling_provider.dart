import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

// Model untuk guru BK di dropdown
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

// Provider daftar pilihan guru BK untuk dropdown siswa
final guruBkListProvider = FutureProvider.autoDispose<List<GuruBkData>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/counseling/guru-bk');
    if (response.data['status'] == 'success' && response.data['data'] is List) {
      return (response.data['data'] as List).map((e) => GuruBkData.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print('Error fetching guru BK list: $e');
    return [];
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
  } catch (e) {
    print('Error fetching siswa bimbingan history: $e');
    return [];
  }
});

// Filter tanggal untuk halaman Guru BK
final bkSelectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider daftar permintaan bimbingan masuk untuk Guru BK
final bkCounselingRequestsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final selectedDate = ref.watch(bkSelectedDateProvider);
  final dateStr =
      "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

  try {
    final response = await dio.get(
      '/counseling/requests',
      queryParameters: {'date': dateStr},
    );
    if (response.data['status'] == 'success' && response.data['data'] is List) {
      return (response.data['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  } catch (e) {
    print('Error fetching bk counseling requests: $e');
    return [];
  }
});

// Notifier untuk submit & approval pengajuan bimbingan
class CounselingNotifier extends StateNotifier<AsyncValue<void>> {
  final Dio _dio;
  final Ref _ref;

  CounselingNotifier(this._dio, this._ref) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String guruBkId,
    required String topic,
    required String scheduleDate,
    required String scheduleTime,
    String? description,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post('/counseling', data: {
        'guru_bk_id': guruBkId,
        'topic': topic,
        'schedule_date': scheduleDate,
        'schedule_time': scheduleTime,
        'description': description,
      });
      state = const AsyncValue.data(null);
      _ref.invalidate(siswaKonsultasiProvider);
      return response.data['status'] == 'success';
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateStatus({
    required String counselingId,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.put('/counseling/$counselingId/status', data: {
        'status': status,
      });
      state = const AsyncValue.data(null);
      _ref.invalidate(bkCounselingRequestsProvider);
      _ref.invalidate(siswaKonsultasiProvider);
      return response.data['status'] == 'success';
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final counselingNotifierProvider = StateNotifierProvider<CounselingNotifier, AsyncValue<void>>((ref) {
  return CounselingNotifier(ref.watch(dioProvider), ref);
});
