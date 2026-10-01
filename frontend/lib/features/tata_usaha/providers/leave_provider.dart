import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

final dispensasiListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users/leaves?type=DISPENSASI');
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    print('Error fetching dispensasi: $e');
    return [];
  }
});

final izinListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users/leaves?type=IZIN');
    return response.data['data'] as List<dynamic>;
  } catch (e) {
    print('Error fetching izin: $e');
    return [];
  }
});

class LeaveNotifier extends StateNotifier<bool> {
  final Ref ref;
  LeaveNotifier(this.ref) : super(false);

  Future<bool> submitLeave({
    required String type, // 'DISPENSASI' or 'IZIN'
    required String reason,
    required String startDate,
    required String endDate,
    String? filePath,
  }) async {
    final dio = ref.read(dioProvider);
    state = true;
    try {
      FormData formData = FormData.fromMap({
        'type': type,
        'reason': reason,
        'start_date': startDate,
        'end_date': endDate,
      });

      if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(MapEntry(
          'attachment',
          await MultipartFile.fromFile(filePath),
        ));
      }

      await dio.post(
        '/users/leaves',
        data: formData,
      );
      state = false;
      if (type == 'DISPENSASI') {
        ref.invalidate(dispensasiListProvider);
      } else {
        ref.invalidate(izinListProvider);
      }
      return true;
    } catch (e) {
      print('Error submitting leave: $e');
      state = false;
      return false;
    }
  }
}

final leaveNotifierProvider = StateNotifierProvider<LeaveNotifier, bool>((ref) {
  return LeaveNotifier(ref);
});
