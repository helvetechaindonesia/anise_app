import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class TerbitJurnalMapelDropdown extends StatelessWidget {
  final String? selectedMapel;
  final List<dynamic> subjects;
  final ValueChanged<String?> onChanged;

  const TerbitJurnalMapelDropdown({
    super.key,
    required this.selectedMapel,
    required this.subjects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> subjectMap = {};
    for (final s in subjects) {
      final id = s['id']?.toString();
      final name = s['name']?.toString() ?? 'Mata Pelajaran';
      if (id != null && !subjectMap.containsKey(id)) {
        subjectMap[id] = name;
      }
    }

    final hasMatch = selectedMapel != null && subjectMap.containsKey(selectedMapel);
    final effectiveValue = hasMatch ? selectedMapel : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mata Pelajaran', style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          key: ValueKey(effectiveValue),
          initialValue: effectiveValue,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(14.w(context)),
          icon: Icon(
            PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
            color: AppColors.primary,
            size: 18.w(context),
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w(context), right: 10.w(context)),
              child: Icon(
                PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular),
                color: AppColors.primary,
                size: 20.w(context),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 46.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          hint: Text(
            'Pilih Mata Pelajaran',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
          ),
          items: subjectMap.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          validator: (val) => val == null ? 'Silakan pilih mata pelajaran' : null,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class TerbitJurnalJadwalDropdown extends StatelessWidget {
  final String? selectedJadwal;
  final List<dynamic> schedules;
  final String? selectedMapel;
  final ValueChanged<String?> onChanged;

  const TerbitJurnalJadwalDropdown({
    super.key,
    required this.selectedJadwal,
    required this.schedules,
    required this.selectedMapel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> scheduleMap = {};
    for (final s in schedules) {
      final id = s['id']?.toString();
      if (id != null && !scheduleMap.containsKey(id)) {
        scheduleMap[id] = s;
      }
    }

    final hasMatch = selectedJadwal != null && scheduleMap.containsKey(selectedJadwal);
    final effectiveValue = hasMatch ? selectedJadwal : null;
    final double dropdownItemHeight = (82.h(context)).clamp(76.0, 105.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal KBM & Kelas', style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          key: ValueKey('$effectiveValue-$selectedMapel'),
          initialValue: effectiveValue,
          isExpanded: true,
          itemHeight: dropdownItemHeight,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(14.w(context)),
          icon: Icon(
            PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
            color: AppColors.primary,
            size: 18.w(context),
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w(context), right: 10.w(context)),
              child: Icon(
                PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                color: AppColors.primary,
                size: 22.w(context),
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 46.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 8.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
          hint: Text(
            selectedMapel == null
                ? 'Pilih Mata Pelajaran Terlebih Dahulu'
                : 'Pilih Jadwal yang Tersedia',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
          ),
          selectedItemBuilder: selectedMapel == null
              ? null
              : (context) {
                  return scheduleMap.entries.map((entry) {
                    final s = entry.value;
                    final label = s['label']?.toString() ?? '';
                    final lines = label.split('\n');
                    final dateLine = lines.isNotEmpty ? lines[0] : '';
                    final classLine = lines.length > 1 ? lines[1] : '';

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dateLine,
                            style: AppTextStyles.labelLarge(context, color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (classLine.isNotEmpty) ...[
                            SizedBox(height: 3.h(context)),
                            Text(
                              classLine,
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList();
                },
          items: selectedMapel == null
              ? []
              : scheduleMap.entries.map((entry) {
                  final s = entry.value;
                  final label = s['label']?.toString() ?? '';
                  final lines = label.split('\n');
                  final dateLine = lines.isNotEmpty ? lines[0] : '';
                  final classLine = lines.length > 1 ? lines[1] : '';

                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dateLine,
                            style: AppTextStyles.labelLarge(context, color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (classLine.isNotEmpty) ...[
                            SizedBox(height: 3.h(context)),
                            Text(
                              classLine,
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
          validator: (val) => val == null ? 'Silakan pilih jadwal KBM' : null,
          onChanged: selectedMapel == null ? null : onChanged,
        ),
      ],
    );
  }
}
