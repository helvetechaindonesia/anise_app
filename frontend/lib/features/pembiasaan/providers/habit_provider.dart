import '../../../core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_model.dart';
import '../services/habit_service.dart';

final masterHabitsProvider = FutureProvider<List<HabitModel>>((ref) async {
  final service = ref.read(habitServiceProvider);
  return await service.getMasterHabits();
});

final pendingLogsProvider = FutureProvider<List<StudentHabitLogModel>>((ref) async {
  final service = ref.read(habitServiceProvider);
  return await service.getPendingLogs();
});

class HabitSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  final HabitService _service;

  HabitSubmitNotifier(this._service) : super(const AsyncData(null));

  Future<bool> submitLog({
    required String habitId,
    String? notes,
    String? photoPath,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.submitHabitLog(
        habitId: habitId,
        notes: notes,
        photoPath: photoPath,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final habitSubmitProvider = StateNotifierProvider<HabitSubmitNotifier, AsyncValue<void>>((ref) {
  return HabitSubmitNotifier(ref.read(habitServiceProvider));
});

final monitoredStudentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/habits/monitored-students');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    throw Exception(e.toString());
  }
});

final guruHabitStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/habits/guru-stats');
    if (response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception(response.data['message']);
  } catch (e) {
    throw Exception(e.toString());
  }
});
