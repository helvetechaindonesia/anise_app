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

String _formatDueDate(dynamic raw) {
  if (raw == null || raw.toString().trim().isEmpty) return '-';
  try {
    final dt = DateTime.parse(raw.toString()).toLocal();
    final now = DateTime.now();
    final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB";
    
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dt.year, dt.month, dt.day);
    final difference = targetDate.difference(today).inDays;
    
    if (difference == 0) {
      return "Hari ini, $timeStr";
    } else if (difference == 1) {
      return "Besok, $timeStr";
    } else if (difference > 1 && difference <= 7) {
      return "$difference hari lagi, $timeStr";
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}, $timeStr";
    }
  } catch (_) {
    return raw.toString();
  }
}

final tugasMendatangProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final tasksAsync = ref.watch(getTasksProvider);
  
  return tasksAsync.when(
    data: (tasks) {
      if (tasks.isEmpty) return [];
      
      return tasks.where((t) => t['status'] != 'Selesai Dikerjakan').take(5).map((t) {
        final status = t['status']?.toString() ?? 'Belum Dikerjakan';
        final isTerlewat = status == 'Terlewat';

        return {
          'id': t['id']?.toString(),
          'subject': t['subject'] ?? '-',
          'teacher': t['teacher'] ?? '-',
          'title': t['title'] ?? '-',
          'timeInfo': t['due_date_formatted'] ?? _formatDueDate(t['due_date']),
          'statusText': status,
          'statusColor': isTerlewat ? AppColors.error : AppColors.warning,
          'statusIcon': isTerlewat ? PhosphorIcons.warningCircle(PhosphorIconsStyle.bold) : PhosphorIcons.hourglass(PhosphorIconsStyle.bold),
          'timeBgColor': isTerlewat ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
          'timeIconColor': isTerlewat ? AppColors.error : AppColors.primary,
          'description': t['description'] ?? '',
          'submission': t['submission'],
          'attachments': t['attachments'],
        };
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

