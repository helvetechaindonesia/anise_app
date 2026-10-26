import 'dart:io' as dart_io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

class JurnalNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final Dio _dio;

  JurnalNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> fetchTerbitOptions() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/journals/terbit-options');
      if (response.data['status'] == 'success') {
        state = AsyncValue.data(response.data['data']);
      } else {
        state = AsyncValue.error('Gagal mengambil opsi terbit', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> terbitJurnal({
    required String scheduleId,
    required String subjectId,
    required String topicMaterial,
    String? description,
    required bool hasTask,
    dart_io.File? attachment,
    Function(double)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'schedule_id': scheduleId,
        'subject_id': subjectId,
        'topic_material': topicMaterial,
        'description': description ?? '',
        'has_task': hasTask ? 1 : 0,
      });

      if (attachment != null) {
        String fileName = attachment.path.split('/').last;
        if (dart_io.Platform.isWindows) {
          fileName = attachment.path.split('\\').last;
        }
        formData.files.add(MapEntry(
          'attachment',
          await MultipartFile.fromFile(attachment.path, filename: fileName),
        ));
      }

      final response = await _dio.post(
        '/journals/terbit',
        data: formData,
        onSendProgress: (count, total) {
          if (total > 0 && onProgress != null) {
            onProgress(count / total);
          }
        },
      );
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateJournal({
    required String journalId,
    required String topicMaterial,
    String? description,
    required bool hasTask,
    dart_io.File? attachment,
    Function(double)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'topic_material': topicMaterial,
        'description': description ?? '',
        'has_task': hasTask ? 1 : 0,
      });

      if (attachment != null) {
        String fileName = attachment.path.split('/').last;
        if (dart_io.Platform.isWindows) {
          fileName = attachment.path.split('\\').last;
        }
        formData.files.add(MapEntry(
          'attachment',
          await MultipartFile.fromFile(attachment.path, filename: fileName),
        ));
      }

      final response = await _dio.post(
        '/journals/$journalId/update',
        data: formData,
        onSendProgress: (count, total) {
          if (total > 0 && onProgress != null) {
            onProgress(count / total);
          }
        },
      );
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteJournal(String journalId) async {
    try {
      final response = await _dio.delete('/journals/$journalId');
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}

final jurnalProvider = StateNotifierProvider<JurnalNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return JurnalNotifier(ref.watch(dioProvider));
});

final allJournalsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final user = ref.watch(authProvider).user;
  
  if (user == null) return [];

  // Polling ringan real-time setiap 5 detik saat layar jadwal aktif
  final timer = dart_io.Platform.isWindows || dart_io.Platform.isAndroid || dart_io.Platform.isIOS
      ? Stream.periodic(const Duration(seconds: 5)).listen((_) {
          ref.invalidateSelf();
        })
      : null;

  ref.onDispose(() {
    timer?.cancel();
  });

  String endpoint = '/journals/guru';
  if (user.role == UserRole.siswa) {
    endpoint = '/journals/siswa';
  } else if (user.role == UserRole.kepalaSekolah) {
    endpoint = '/journals/all';
  }

  try {
    final response = await dio.get(endpoint);
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    throw Exception(e.toString());
  }
});

final kelasJadwalProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/journals/schedules');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    throw Exception(e.toString());
  }
});

final offDaysProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/journals/off-days');
    if (response.data['status'] == 'success') {
      return Map<String, dynamic>.from(response.data['data'] as Map);
    }
  } catch (_) {}
  return {
    'off_weekdays': <dynamic>['Minggu', 'Sunday'],
    'first_off_day': 'Minggu',
    'reset_time': '01:00',
    'current_week_start': '2026-10-26',
    'app_release_date': '2026-10-29',
    'holidays': <dynamic>[],
  };
});


