import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

final agendaPenilaianProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'type': 'Formatif',
      'label': 'FORMATIF MANDIRI',
      'title': 'Kimia (Reaksi Redoks)',
      'weight': '15%',
      'date': 'Kamis, 30 Okt 2025 • 10:15 WIB',
      'subtitle': 'Guru Pengampu: Ibu Sri Wahyuni',
      'icon': PhosphorIcons.flask(PhosphorIconsStyle.bold),
    },
    {
      'type': 'Formatif',
      'label': 'FORMATIF ESAI',
      'title': 'Bahasa Inggris (Exposition)',
      'weight': '15%',
      'date': 'Jumat, 31 Okt 2025 • 07:30 WIB',
      'subtitle': 'Guru Pengampu: Mr. David',
      'icon': PhosphorIcons.translate(PhosphorIconsStyle.bold),
    },
    {
      'type': 'SAS',
      'label': 'SUMATIF AKHIR',
      'title': 'SAS Terpadu Semester Ganjil',
      'weight': '40%',
      'date': '01 - 12 Des 2025',
      'subtitle': 'Cakupan: Seluruh Mata Pelajaran Utama',
      'icon': PhosphorIcons.checkSquareOffset(PhosphorIconsStyle.bold),
    },
  ];
});
