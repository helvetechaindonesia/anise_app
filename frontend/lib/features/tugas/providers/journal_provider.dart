import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import '../services/journal_service.dart';

final schedulesProvider = FutureProvider<List<ScheduleModel>>((ref) async {
  final service = ref.read(journalServiceProvider);
  return await service.getMySchedules();
});

class JournalSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  final JournalService _service;

  JournalSubmitNotifier(this._service) : super(const AsyncData(null));

  Future<bool> submit({
    required String scheduleId,
    required String date,
    required String topic,
    String? notes,
    bool hasTask = false,
    String? taskTitle,
    String? taskDescription,
    String? taskDeadline,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.submitJournal(
        scheduleId: scheduleId,
        date: date,
        topic: topic,
        notes: notes,
        hasTask: hasTask,
        taskTitle: taskTitle,
        taskDescription: taskDescription,
        taskDeadline: taskDeadline,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final journalSubmitProvider = StateNotifierProvider<JournalSubmitNotifier, AsyncValue<void>>((ref) {
  return JournalSubmitNotifier(ref.read(journalServiceProvider));
});
