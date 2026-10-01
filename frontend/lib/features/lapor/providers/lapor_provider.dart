import 'package:flutter_riverpod/flutter_riverpod.dart';

final laporCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'Perundungan (Bullying)',
    'Kendala Fasilitas Sekolah',
    'Kekerasan / Pelanggaran Disiplin',
    'Konseling Kesehatan Mental',
    'Lainnya',
  ];
});
