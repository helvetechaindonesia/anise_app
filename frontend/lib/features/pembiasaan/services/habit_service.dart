import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/habit_model.dart';

final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService(ref.read(dioProvider));
});

class HabitService {
  final Dio _dio;

  HabitService(this._dio);

  Future<List<HabitModel>> getMasterHabits() async {
    final response = await _dio.get('/g7kaih');
    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => HabitModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<void> submitHabitLog({
    required String habitId,
    String? notes,
    String? photoPath,
  }) async {
    FormData formData = FormData.fromMap({
      'habit_id': habitId,
      if (notes != null) 'notes': notes,
      if (photoPath != null)
        'photo': await MultipartFile.fromFile(photoPath, filename: 'habit_proof.jpg'),
    });

    final response = await _dio.post('/g7kaih/log', data: formData);

    if (response.data['status'] != 'success') {
      throw Exception(response.data['message']);
    }
  }

  Future<List<StudentHabitLogModel>> getPendingLogs() async {
    final response = await _dio.get('/g7kaih/pending');
    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => StudentHabitLogModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }
}
