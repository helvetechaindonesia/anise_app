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
