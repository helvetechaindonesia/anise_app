import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_button.dart';

class SchoolOffDaysCard extends ConsumerStatefulWidget {
  final VoidCallback? onSaved;

  const SchoolOffDaysCard({super.key, this.onSaved});

  @override
  ConsumerState<SchoolOffDaysCard> createState() => _SchoolOffDaysCardState();
}

class _SchoolOffDaysCardState extends ConsumerState<SchoolOffDaysCard> {
  bool _isLoading = true;
  bool _isSaving = false;

  String _systemDays = '5_DAYS'; // '5_DAYS', '6_DAYS', 'CUSTOM'
  final Set<String> _selectedOffDays = {'SATURDAY', 'SUNDAY'};

  final List<Map<String, String>> _allDays = [
    {'key': 'MONDAY', 'label': 'Senin'},
    {'key': 'TUESDAY', 'label': 'Selasa'},
    {'key': 'WEDNESDAY', 'label': 'Rabu'},
    {'key': 'THURSDAY', 'label': 'Kamis'},
    {'key': 'FRIDAY', 'label': 'Jumat'},
    {'key': 'SATURDAY', 'label': 'Sabtu'},
    {'key': 'SUNDAY', 'label': 'Minggu'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/master/school-settings/operational');
      if (res.data != null && res.data['data'] != null) {
        final data = res.data['data'];
        setState(() {
          _systemDays = data['school_system_days'] ?? '5_DAYS';
          final List<dynamic> offList = data['school_off_days'] ?? ['SATURDAY', 'SUNDAY'];
          _selectedOffDays.clear();
          for (var item in offList) {
            _selectedOffDays.add(item.toString().toUpperCase());
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/master/school-settings/operational', data: {
        'school_system_days': _systemDays,
        'school_off_days': _selectedOffDays.toList(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengaturan hari libur mingguan berhasil disimpan!',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan: $e',
              style: AppTextStyles.bodyMedium(context, color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _applyPreset(String preset) {
    setState(() {
      _systemDays = preset;
      if (preset == '5_DAYS') {
        _selectedOffDays.clear();
        _selectedOffDays.addAll(['SATURDAY', 'SUNDAY']);
      } else if (preset == '6_DAYS') {
        _selectedOffDays.clear();
        _selectedOffDays.add('SUNDAY');
      }
    });
  }

  void _toggleDay(String dayKey) {
    setState(() {
      _systemDays = 'CUSTOM';
      if (_selectedOffDays.contains(dayKey)) {
        if (_selectedOffDays.length > 1) {
          _selectedOffDays.remove(dayKey);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Minimal harus ada 1 hari libur dalam seminggu.',
                style: AppTextStyles.bodySmall(context, color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedOffDays.add(dayKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
        padding: EdgeInsets.all(20.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul & Ikon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Icon(
                  PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold),
                  color: AppColors.primary,
                  size: 22.w(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Operasional & Libur Rutin',
                      style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      'Sinkronisasi kalender presensi & jurnal sekolah',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),

          // Preset Sistem Hari Sekolah
          Text(
            'Sistem Hari Sekolah:',
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 8.h(context)),
          Row(
            children: [
              Expanded(
                child: _buildPresetChip(
                  context,
                  label: '5 Hari (Sab & Min)',
                  isSelected: _systemDays == '5_DAYS',
                  onTap: () => _applyPreset('5_DAYS'),
                ),
              ),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: _buildPresetChip(
                  context,
                  label: '6 Hari (Min Saja)',
                  isSelected: _systemDays == '6_DAYS',
                  onTap: () => _applyPreset('6_DAYS'),
                ),
              ),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: _buildPresetChip(
                  context,
                  label: 'Kustom',
                  isSelected: _systemDays == 'CUSTOM',
                  onTap: () => _applyPreset('CUSTOM'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),

          // Hari Libur Mingguan (Tap to toggle)
          Text(
            'Hari Libur Rutin Mingguan (Pilih Hari Libur):',
            style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
          ),
          SizedBox(height: 8.h(context)),
          Wrap(
            spacing: 8.w(context),
            runSpacing: 8.h(context),
            children: _allDays.map((day) {
              final isOff = _selectedOffDays.contains(day['key']);
              return FilterChip(
                label: Text(
                  day['label']!,
                  style: AppTextStyles.labelMedium(
                    context,
                    color: isOff ? Colors.white : AppColors.onSurface,
                  ).copyWith(
                    fontWeight: isOff ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                selected: isOff,
                selectedColor: AppColors.error,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: isOff ? AppColors.error : AppColors.outline.withValues(alpha: 0.3),
                ),
                checkmarkColor: Colors.white,
                onSelected: (_) => _toggleDay(day['key']!),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h(context)),

          // Catatan Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.info(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.error),
                SizedBox(width: 8.w(context)),
                Expanded(
                  child: Text(
                    'Hari yang ditandai merah adalah hari libur mingguan tanpa jadwal & presensi.',
                    style: AppTextStyles.labelSmall(context, color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h(context)),

          // Tombol Simpan
          AniseButton(
            text: 'Simpan Hari Libur Mingguan',
            isLoading: _isSaving,
            icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
            onPressed: _isSaving ? null : _saveSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.w(context)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h(context), horizontal: 4.w(context)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10.w(context)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall(
            context,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
