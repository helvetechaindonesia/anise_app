import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';

import '../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../tugas/providers/tugas_provider.dart';

final mentorsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final user = ref.watch(authProvider).user;
  
  if (user == null || user.role != UserRole.siswa) return [];

  try {
    final response = await dio.get('/users/siswa/teachers');
    if (response.data['status'] == 'success') {
      final List<dynamic> data = response.data['data'];
      return data.map((t) => {
        'id': t['id'].toString(),
        'name': t['name'].toString(),
        'subject': t['subject'].toString(),
        'color': AppColors.primary,
      }).toList().cast<Map<String, dynamic>>();
    }
    return [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    rethrow;
  }
});

final tugasMendatangProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final tasksAsync = ref.watch(getTasksProvider);
  
  return tasksAsync.when(
    data: (tasks) {
      if (tasks.isEmpty) return [];
      
      return tasks.take(3).map((t) => {
        'subject': t['subject'] ?? '-',
        'teacher': t['teacher'] ?? '-',
        'title': t['title'] ?? '-',
        'timeInfo': t['due_date'] ?? '-',
        'statusText': 'Belum Dikerjakan',
        'statusColor': AppColors.primary,
        'statusIcon': PhosphorIcons.hourglass(PhosphorIconsStyle.bold),
        'timeBgColor': AppColors.primary.withValues(alpha: 0.5),
        'timeIconColor': AppColors.primary,
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

