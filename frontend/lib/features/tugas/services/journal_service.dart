import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/schedule_model.dart';

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(ref.read(dioProvider));
});

class JournalService {
  final Dio _dio;

  JournalService(this._dio);

  Future<List<ScheduleModel>> getMySchedules() async {
    final response = await _dio.get('/journals/schedules');
    if (response.data['status'] == 'success') {
      final List data = response.data['data'];
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    }
    throw Exception(response.data['message']);
  }

  Future<void> submitJournal({
    required String scheduleId,
    required String date,
    required String topic,
    String? notes,
    bool hasTask = false,
    String? taskTitle,
    String? taskDescription,
    String? taskDeadline,
  }) async {
    final response = await _dio.post('/journals', data: {
      'schedule_id': scheduleId,
      'date': date,
      'topic': topic,
      'notes': notes,
      'has_task': hasTask,
      'task_title': taskTitle,
      'task_description': taskDescription,
      'task_deadline': taskDeadline,
    });

    if (response.data['status'] != 'success') {
      throw Exception(response.data['message']);
    }
  }
}
