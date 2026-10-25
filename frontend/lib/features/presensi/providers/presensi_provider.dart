import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

/// Provider bulan yang dipilih (0 = Semua Bulan, 1-12 = Januari - Desember)
final selectedMonthProvider = StateProvider<int>((ref) => 0);

/// Provider tahun yang dipilih (0 = Semua Tahun, atau tahun spesifik seperti 2026)
final selectedYearProvider = StateProvider<int>((ref) => 0);

/// Provider data presensi gabungan (summary & logs) dari backend
final presensiDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  final month = ref.watch(selectedMonthProvider);
  final year = ref.watch(selectedYearProvider);

  final response = await dio.get('/attendance', queryParameters: {
    'month': month,
    'year': year,
  });

  if (response.data is Map<String, dynamic>) {
    return response.data as Map<String, dynamic>;
  }
  return {
    'summary': {
      'hadir_penuh': 0,
      'terlambat': 0,
      'pulang_awal': 0,
      'kembali': 0,
      'sakit': 0,
      'izin': 0,
      'alpha': 0,
    },
    'logs': (response.data as List<dynamic>?) ?? [],
  };
});

/// Provider riwayat log presensi harian
final presensiLogProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  return ref.watch(presensiDataProvider).whenData((data) {
    return (data['logs'] as List<dynamic>?) ?? [];
  });
});

/// Provider rekapitulasi statistik kehadiran bulanan
final presensiSummaryProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  return ref.watch(presensiDataProvider).whenData((data) {
    return (data['summary'] as Map<String, dynamic>?) ?? {};
  });
});
