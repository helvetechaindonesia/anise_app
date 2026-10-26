import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/habit_model.dart';

final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService(ref.read(dioProvider));
});

class MasterHabitsResponse {
  final List<HabitModel> habits;
  final Set<String> todayLoggedHabitIds;
  final Map<String, bool> todayPrayerLog;

  MasterHabitsResponse({
    required this.habits,
    required this.todayLoggedHabitIds,
    required this.todayPrayerLog,
  });
}

class HabitService {
  final Dio _dio;

  HabitService(this._dio);

  Future<MasterHabitsResponse> getMasterHabits() async {
    final response = await _dio.get('/g7kaih');
    if (response.data['status'] == 'success') {
      final data = response.data['data'];
      List habitListRaw = [];
      Set<String> loggedIds = {};
      Map<String, bool> prayerLog = {
        'is_subuh': false,
        'is_dhuhur': false,
        'is_asar': false,
        'is_maghrib': false,
        'is_isya': false,
        'is_quran': false,
      };

      if (data is Map) {
        habitListRaw = data['habits'] ?? [];
        final loggedRaw = data['today_logged_habit_ids'] as List? ?? [];
        loggedIds = loggedRaw.map((e) => e.toString()).toSet();
        if (data['today_prayer_log'] is Map) {
          final pMap = data['today_prayer_log'] as Map;
          pMap.forEach((k, v) {
            prayerLog[k.toString()] = v == true;
          });
        }
      } else if (data is List) {
        habitListRaw = data;
      }

      final habits = habitListRaw.map((e) => HabitModel.fromJson(e)).toList();
      return MasterHabitsResponse(
        habits: habits,
        todayLoggedHabitIds: loggedIds,
        todayPrayerLog: prayerLog,
      );
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

  Future<void> submitPrayerLog(Map<String, bool> prayerFields) async {
    final response = await _dio.post('/g7kaih/prayer-log', data: prayerFields);
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
