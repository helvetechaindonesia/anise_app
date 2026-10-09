import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../../core/network/dio_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

final journalsBySubjectProvider = FutureProvider.family<List<dynamic>, String>((ref, subjectId) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/journals/by-subject/$subjectId');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    throw Exception(e.toString());
  }
});

class TugasNotifier extends StateNotifier<AsyncValue<void>> {
  final Dio _dio;

  TugasNotifier(this._dio) : super(const AsyncValue.data(null));

  Future<bool> createTugas({
    required String journalId,
    required String title,
    required String description,
    required String dueDate,
    File? attachment,
    Function(double)? onProgress,
  }) async {
    state = const AsyncValue.loading();
    try {
      final formData = FormData.fromMap({
        'journal_id': journalId,
        'title': title,
        'description': description,
        'due_date': dueDate,
      });

      if (attachment != null) {
        String fileName = attachment.path.split('/').last;
        if (Platform.isWindows) {
          fileName = attachment.path.split('\\').last;
        }
        formData.files.add(MapEntry(
          'attachment',
          await MultipartFile.fromFile(attachment.path, filename: fileName),
        ));
      }

      final response = await _dio.post(
        '/assignments',
        data: formData,
        onSendProgress: (count, total) {
          if (total > 0 && onProgress != null) {
            onProgress(count / total);
          }
        },
      );

      state = const AsyncValue.data(null);
      return response.data['status'] == 'success';
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final tugasProvider = StateNotifierProvider<TugasNotifier, AsyncValue<void>>((ref) {
  return TugasNotifier(ref.watch(dioProvider));
});

final getTasksProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final user = ref.watch(authProvider).user;
  
  if (user == null) return [];

  final endpoint = user.role == UserRole.siswa ? '/assignments/siswa' : '/assignments';

  try {
    final response = await dio.get(endpoint);
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    rethrow;
  } catch (e) {
    throw Exception(e.toString());
  }
});
