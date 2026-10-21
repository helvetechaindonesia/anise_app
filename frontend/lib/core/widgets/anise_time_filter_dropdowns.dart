import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Standarisasi Komponen Dropdown Filter Waktu (Bulan & Tahun)
class AniseTimeFilterDropdowns extends StatelessWidget {
  final String selectedMonth;
  final String selectedYear;
  final List<String> months;
  final List<String> years;
  final ValueChanged<String?> onMonthChanged;
  final ValueChanged<String?> onYearChanged;

  const AniseTimeFilterDropdowns({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.months,
    required this.years,
    required this.onMonthChanged,
    required this.onYearChanged,
  });

  /// Generator daftar tahun terstandarisasi berdasarkan tanggal rilis aplikasi
  static List<String> getYears(DateTime releaseDate) {
    final currentYear = DateTime.now().year;
    final releaseYear = releaseDate.year;
    final maxYear = currentYear >= releaseYear ? currentYear + 1 : releaseYear + 1;
    final List<String> list = ['Semua Tahun'];
    for (int y = releaseYear; y <= maxYear; y++) {
      list.add(y.toString());
    }
    return list;
  }

  /// Generator daftar bulan terstandarisasi dengan proteksi tanggal rilis aplikasi
  static List<String> getMonths(DateTime releaseDate, String selectedYear) {
    const allMonths = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final List<String> list = ['Semua Bulan'];
    if (selectedYear == releaseDate.year.toString()) {
      list.addAll(allMonths.sublist(releaseDate.month - 1));
    } else {
      list.addAll(allMonths);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown Bulan
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 2.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                icon: Icon(
                  PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                  color: AppColors.onSurfaceVariant,
                  size: 16.w(context),
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: onMonthChanged,
                items: months.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),

        // Dropdown Tahun
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 2.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedYear,
                isExpanded: true,
                icon: Icon(
                  PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                  color: AppColors.onSurfaceVariant,
                  size: 16.w(context),
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: onYearChanged,
                items: years.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
