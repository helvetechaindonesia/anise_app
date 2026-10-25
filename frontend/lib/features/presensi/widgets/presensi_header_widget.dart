import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_dropdown.dart';
import '../providers/presensi_provider.dart';

/// Komponen filter Bulan & Tahun terstandarisasi untuk modul Presensi.
/// (Diberi alias [PresensiFilterWidget] untuk memperjelas fungsinya sebagai filter data).
class PresensiHeaderWidget extends ConsumerWidget {
  const PresensiHeaderWidget({super.key});

  static const List<String> _months = [
    'Semua Bulan',
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> _years = ['Semua Tahun', '2024', '2025', '2026', '2027', '2028'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);

    final selectedMonthName = (selectedMonth >= 0 && selectedMonth < _months.length)
        ? _months[selectedMonth]
        : 'Semua Bulan';

    final selectedYearStr = selectedYear == 0 ? 'Semua Tahun' : selectedYear.toString();

    final yearList = List<String>.from(_years);
    if (!yearList.contains(selectedYearStr)) {
      yearList.add(selectedYearStr);
    }

    return Row(
      children: [
        // 1. Dropdown Baku Bulan
        Expanded(
          child: AniseDropdown<String>(
            value: selectedMonthName,
            onChanged: (String? newValue) {
              if (newValue != null) {
                final newIndex = _months.indexOf(newValue);
                if (newIndex != -1) {
                  ref.read(selectedMonthProvider.notifier).state = newIndex;
                }
              }
            },
            items: _months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'Semua Bulan' ? 'Semua Bulan' : 'Bulan: $value', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 12.w(context)),

        // 2. Dropdown Baku Tahun
        Expanded(
          child: AniseDropdown<String>(
            value: selectedYearStr,
            onChanged: (String? newValue) {
              if (newValue != null) {
                if (newValue == 'Semua Tahun') {
                  ref.read(selectedYearProvider.notifier).state = 0;
                } else {
                  final parsed = int.tryParse(newValue);
                  if (parsed != null) {
                    ref.read(selectedYearProvider.notifier).state = parsed;
                  }
                }
              }
            },
            items: yearList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'Semua Tahun' ? 'Semua Tahun' : 'Tahun: $value', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Alias ramah bagi pengembang: [PresensiFilterWidget]
typedef PresensiFilterWidget = PresensiHeaderWidget;

