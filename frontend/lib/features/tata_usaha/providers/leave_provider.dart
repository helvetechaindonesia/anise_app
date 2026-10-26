import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

// Provider untuk Inbox Perizinan (Wali Kelas / Kepala Sekolah)
final perijinanInboxProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/leaves/pending');
    if (response.data is Map && response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    print('Error fetching perijinan inbox: $e');
    return [];
  }
});

// Provider untuk Riwayat Pengajuan Saya (History)
final myLeavesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/leaves/my');
    if (response.data is Map && response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    print('Error fetching my leaves: $e');
    return [];
  }
});

class LeaveNotifier extends StateNotifier<bool> {
  final Ref ref;
  LeaveNotifier(this.ref) : super(false);

  Future<Map<String, dynamic>> submitLeave({
    required String type, // 'IZIN', 'SAKIT', 'DISPENSASI'
    required String reason,
    required String startDate,
    required String endDate,
    String? exitTime,
    double? latitude,
    double? longitude,
    String? attachmentPath,
    String? faceImagePath,
  }) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      final Map<String, dynamic> dataMap = {
        'type': type,
        'reason': reason,
        'start_date': startDate,
        'end_date': endDate,
      };

      if (exitTime != null && exitTime.isNotEmpty) {
        dataMap['exit_time'] = exitTime;
      }
      if (latitude != null) {
        dataMap['latitude'] = latitude;
      }
      if (longitude != null) {
        dataMap['longitude'] = longitude;
      }

      FormData formData = FormData.fromMap(dataMap);

      if (attachmentPath != null && attachmentPath.isNotEmpty) {
        formData.files.add(MapEntry(
          'attachment',
          await MultipartFile.fromFile(attachmentPath),
        ));
      }

      if (faceImagePath != null && faceImagePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'face_image',
          await MultipartFile.fromFile(faceImagePath),
        ));
      }

      final res = await dio.post('/leaves', data: formData);
      state = false;
      ref.invalidate(myLeavesProvider);
      ref.invalidate(perijinanInboxProvider);
      return {
        'success': true,
        'message': res.data['message'] ?? 'Pengajuan berhasil dikirim.',
      };
    } catch (e) {
      print('Error submitting leave: $e');
      state = false;
      String err = 'Gagal mengajukan perizinan';
      if (e is DioException && e.response?.data is Map) {
        err = e.response?.data['message'] ?? err;
      }
      return {'success': false, 'message': err};
    }
  }

  Future<bool> updateStatus({
    required dynamic leaveId,
    required String status, // 'APPROVED' or 'REJECTED'
    String? notes,
  }) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      await dio.put('/leaves/$leaveId/status', data: {
        'status': status,
        if (notes != null) 'notes': notes,
      });
      state = false;
      ref.invalidate(perijinanInboxProvider);
      ref.invalidate(myLeavesProvider);
      return true;
    } catch (e) {
      print('Error updating leave status: $e');
      state = false;
      return false;
    }
  }

  Future<bool> confirmReturn({required dynamic leaveId}) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      await dio.put('/leaves/$leaveId/confirm-return');
      state = false;
      ref.invalidate(perijinanInboxProvider);
      return true;
    } catch (e) {
      print('Error confirming return: $e');
      state = false;
      return false;
    }
  }
}

final leaveNotifierProvider = StateNotifierProvider<LeaveNotifier, bool>((ref) {
  return LeaveNotifier(ref);
});
