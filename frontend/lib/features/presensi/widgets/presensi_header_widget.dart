import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/presensi_provider.dart';

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
        : _months[DateTime.now().month - 1];

    final validYear = _years.contains(currentYear) ? currentYear : _years[2];

    return Row(
      children: [
        // 1. Dropdown Bulan
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onBackground.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonthName,
                isExpanded: true,
                icon: Icon(
                  PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                  color: AppColors.onSurfaceVariant,
                  size: 16.w(context),
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
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
          ),
        ),
        SizedBox(width: 12.w(context)),

        // 2. Dropdown Tahun
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onBackground.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: validYear,
                isExpanded: true,
                icon: Icon(
                  PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                  color: AppColors.onSurfaceVariant,
                  size: 16.w(context),
                ),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    final parsed = int.tryParse(newValue);
                    if (parsed != null) {
                      ref.read(selectedYearProvider.notifier).state = parsed;
                    }
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
