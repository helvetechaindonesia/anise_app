import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

/// Provider saldo & ringkasan poin kedisiplinan user
final pointBalanceProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/points/balance');
    if (response.data is Map && response.data['data'] is Map) {
      return Map<String, dynamic>.from(response.data['data']);
    }
    return {
      'balance': 100,
      'initial_balance': 100,
      'total_deducted': 0,
      'days_in_month': 30,
      'deduction_per_violation': 1.1,
      'total_violations_month': 0,
      'violations_counted': 0,
      'today_violations': 0,
      'remaining_violations_today': 3,
      'month_label': '',
    };
  } catch (e) {
    print('Error fetching point balance: $e');
    return {
      'balance': 100,
      'initial_balance': 100,
      'total_deducted': 0,
      'days_in_month': 30,
      'deduction_per_violation': 1.1,
      'total_violations_month': 0,
      'violations_counted': 0,
      'today_violations': 0,
      'remaining_violations_today': 3,
      'month_label': '',
    };
  }
});

/// Provider riwayat pelanggaran poin user
final pointHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/points/history');
    if (response.data is Map && response.data['data'] is List) {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } catch (e) {
    print('Error fetching point history: $e');
    return [];
  }
});
