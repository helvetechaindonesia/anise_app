import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';

class PresensiHeaderWidget extends StatefulWidget {
  const PresensiHeaderWidget({super.key});

  @override
  State<PresensiHeaderWidget> createState() => _PresensiHeaderWidgetState();
}

class _PresensiHeaderWidgetState extends State<PresensiHeaderWidget> {
  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _years = ['2024', '2025', '2026', '2027'];

  String _selectedMonth = 'Oktober';
  String _selectedYear = '2025';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMonth,
                isExpanded: true,
                icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMonth = newValue;
                    });
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
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYear,
                isExpanded: true,
                icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedYear = newValue;
                    });
                  }
                },
                items: _years.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Tahun: $value', overflow: TextOverflow.ellipsis),
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

