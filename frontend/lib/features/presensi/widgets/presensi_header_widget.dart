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
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> _years = ['2024', '2025', '2026', '2027', '2028'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonthIndex = ref.watch(selectedMonthProvider) - 1;
    final currentYear = ref.watch(selectedYearProvider).toString();

    final selectedMonthName = (currentMonthIndex >= 0 && currentMonthIndex < _months.length)
        ? _months[currentMonthIndex]
        : _months[(DateTime.now().month - 1).clamp(0, 11)];

    final yearList = List<String>.from(_years);
    if (!yearList.contains(currentYear)) {
      yearList.add(currentYear);
      yearList.sort();
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
                  ref.read(selectedMonthProvider.notifier).state = newIndex + 1;
                }
              }
            },
            items: _months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Bulan: $value', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 12.w(context)),

        // 2. Dropdown Baku Tahun
        Expanded(
          child: AniseDropdown<String>(
            value: currentYear,
            onChanged: (String? newValue) {
              if (newValue != null) {
                final parsed = int.tryParse(newValue);
                if (parsed != null) {
                  ref.read(selectedYearProvider.notifier).state = parsed;
                }
              }
            },
            items: yearList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text('Tahun: $value', overflow: TextOverflow.ellipsis),
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

