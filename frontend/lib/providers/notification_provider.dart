import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../features/auth/providers/auth_provider.dart';

/// Provider realtime notifikasi user (refresh otomatis setiap 6 detik)
final notificationsListProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final user = ref.watch(authProvider).user;
  if (user == null) return [];

  final timer = Stream.periodic(const Duration(seconds: 6)).listen((_) {
    ref.invalidateSelf();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  try {
    final response = await dio.get('/notifications');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (_) {
    return [];
  }
});

/// Provider jumlah notifikasi yang belum dibaca (unread count)
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notifsAsync = ref.watch(notificationsListProvider);
  return notifsAsync.maybeWhen(
    data: (list) => list.where((item) => item['is_read'] != true && item['is_read'] != 1).length,
    orElse: () => 0,
  );
});
