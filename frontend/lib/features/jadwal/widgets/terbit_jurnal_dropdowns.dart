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

class _ScheduleDisplayInfo {
  final String dayDate;
  final String time;
  final String className;

  const _ScheduleDisplayInfo({
    required this.dayDate,
    required this.time,
    required this.className,
  });
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

  _ScheduleDisplayInfo _parseScheduleData(Map<String, dynamic> s) {
    String dayDate = '';
    String time = '';
    String className = '';

    if (s['day_name'] != null && s['date_formatted'] != null) {
      dayDate = "${s['day_name']}, ${s['date_formatted']}";
    }
    if (s['time_range'] != null) {
      time = s['time_range'].toString();
    }
    if (s['class_name'] != null) {
      className = s['class_name'].toString();
    }

    if (dayDate.isEmpty || time.isEmpty || className.isEmpty) {
      final label = s['label']?.toString() ?? '';
      final lines = label.split('\n');
      if (dayDate.isEmpty && lines.isNotEmpty) dayDate = lines[0];
      if (lines.length > 1) {
        final subparts = lines[1].split('•');
        if (time.isEmpty && subparts.isNotEmpty) time = subparts[0].trim();
        if (className.isEmpty && subparts.length > 1) className = subparts[1].trim();
        if (className.isEmpty && subparts.length == 1) className = lines[1].trim();
      }
    }

    return _ScheduleDisplayInfo(
      dayDate: dayDate.isEmpty ? 'Jadwal KBM' : dayDate,
      time: time.isEmpty ? 'Jam Pelajaran' : time,
      className: className.isEmpty ? 'Kelas' : className,
    );
  }

  Widget _buildScheduleInfoLines(
    BuildContext context,
    _ScheduleDisplayInfo info,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Baris 1: Hari, Tanggal/Bulan/Tahun
        Text(
          info.dayDate,
          style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h(context)),

        // Baris 2: Jam
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.clock(PhosphorIconsStyle.bold),
              size: 13.w(context),
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(width: 5.w(context)),
            Flexible(
              child: Text(
                info.time,
                style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant).copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h(context)),

        // Baris 3: Kelas
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.chalkboard(PhosphorIconsStyle.bold),
              size: 13.w(context),
              color: AppColors.primary,
            ),
            SizedBox(width: 5.w(context)),
            Flexible(
              child: Text(
                info.className,
                style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSchedulePickerSheet(
    BuildContext context,
    Map<String, dynamic> scheduleMap,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h(context)),
              Container(
                width: 44.w(context),
                height: 4.h(context),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.w(context)),
                ),
              ),
              SizedBox(height: 12.h(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pilih Jadwal KBM',
                            style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h(context)),
                          Text(
                            'Pilih sesi mengajar yang sesuai untuk jurnal ini',
                            style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        PhosphorIcons.x(PhosphorIconsStyle.bold),
                        size: 20.w(context),
                        color: AppColors.onSurfaceVariant,
                      ),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(16.w(context), 8.h(context), 16.w(context), 24.h(context)),
                  itemCount: scheduleMap.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h(context)),
                  itemBuilder: (context, index) {
                    final entry = scheduleMap.entries.elementAt(index);
                    final isCurrentSelected = entry.key == selectedJadwal;
                    final info = _parseScheduleData(entry.value);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onChanged(entry.key);
                          Navigator.pop(bottomSheetContext);
                        },
                        borderRadius: BorderRadius.circular(14.w(context)),
                        child: Container(
                          padding: EdgeInsets.all(14.w(context)),
                          decoration: BoxDecoration(
                            color: isCurrentSelected
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(14.w(context)),
                            border: Border.all(
                              color: isCurrentSelected
                                  ? AppColors.primary
                                  : AppColors.outline.withValues(alpha: 0.25),
                              width: isCurrentSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildScheduleInfoLines(context, info),
                              ),
                              SizedBox(width: 12.w(context)),
                              Container(
                                width: 22.w(context),
                                height: 22.w(context),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCurrentSelected
                                        ? AppColors.primary
                                        : AppColors.outline.withValues(alpha: 0.4),
                                    width: isCurrentSelected ? 6.w(context) : 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
    final selectedSchedule = hasMatch ? scheduleMap[selectedJadwal] : null;
    final isSelected = selectedSchedule != null;
    final isEnabled = selectedMapel != null && schedules.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal KBM & Kelas',
          style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
        ),
        SizedBox(height: 8.h(context)),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: !isEnabled
                ? () {
                    if (selectedMapel == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Silakan pilih mata pelajaran terlebih dahulu.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (schedules.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tidak ada jadwal KBM yang tersedia untuk mata pelajaran ini.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                : () => _showSchedulePickerSheet(context, scheduleMap),
            borderRadius: BorderRadius.circular(14.w(context)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 14.w(context),
                vertical: isSelected ? 12.h(context) : 14.h(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.w(context)),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outline.withValues(alpha: 0.3),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Prefix Icon (Kotak Kalender)
                  Container(
                    width: 44.w(context),
                    height: 44.w(context),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isSelected ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Center(
                      child: Icon(
                        PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                        color: AppColors.primary,
                        size: 24.w(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w(context)),

                  // Tengah: 3 Baris Info atau Hint
                  Expanded(
                    child: isSelected
                        ? _buildScheduleInfoLines(
                            context,
                            _parseScheduleData(selectedSchedule),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedMapel == null
                                    ? 'Pilih Mata Pelajaran Terlebih Dahulu'
                                    : 'Pilih Jadwal yang Tersedia',
                                style: AppTextStyles.bodyMedium(
                                  context,
                                  color: AppColors.onSurface.withValues(alpha: 0.45),
                                ).copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 3.h(context)),
                              Text(
                                selectedMapel == null
                                    ? 'Mata pelajaran belum dipilih'
                                    : 'Ketuk untuk melihat sesi KBM',
                                style: AppTextStyles.labelSmall(
                                  context,
                                  color: AppColors.onSurface.withValues(alpha: 0.3),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),
                  SizedBox(width: 8.w(context)),

                  // Caret Down di sebelah kanan
                  Icon(
                    PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    size: 18.w(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
