import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/widgets/decorative_background.dart';

class TUHariNonaktifSettingsScreen extends ConsumerStatefulWidget {
  const TUHariNonaktifSettingsScreen({super.key});

  @override
  ConsumerState<TUHariNonaktifSettingsScreen> createState() => _TUHariNonaktifSettingsScreenState();
}

class _TUHariNonaktifSettingsScreenState extends ConsumerState<TUHariNonaktifSettingsScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

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
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get('/master/school-settings/operational');
      if (res.data != null && res.data['data'] != null) {
        final data = res.data['data'];
        final List<dynamic> offList = data['school_off_days'] ?? ['SATURDAY', 'SUNDAY'];
        _selectedOffDays.clear();
        for (var item in offList) {
          _selectedOffDays.add(item.toString().toUpperCase());
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleDay(String dayKey) {
    setState(() {
      if (_selectedOffDays.contains(dayKey)) {
        if (_selectedOffDays.length > 1) {
          _selectedOffDays.remove(dayKey);
        } else {
          AniseFeedbackDialog.showWarning(
            context,
            title: 'Peringatan',
            message: 'Minimal harus ada 1 hari nonaktif dalam seminggu.',
          );
        }
      } else {
        _selectedOffDays.add(dayKey);
      }
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      String systemDays = 'CUSTOM';
      if (_selectedOffDays.length == 2 &&
          _selectedOffDays.contains('SATURDAY') &&
          _selectedOffDays.contains('SUNDAY')) {
        systemDays = '5_DAYS';
      } else if (_selectedOffDays.length == 1 && _selectedOffDays.contains('SUNDAY')) {
        systemDays = '6_DAYS';
      }

      final dio = ref.read(dioProvider);
      await dio.post('/master/school-settings/operational', data: {
        'school_system_days': systemDays,
        'school_off_days': _selectedOffDays.toList(),
      });

      if (mounted) {
        await AniseFeedbackDialog.showSuccess(
          context,
          title: 'Pengaturan Disimpan',
          message: 'Pengaturan hari nonaktif berhasil disimpan!',
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Menyimpan',
          message: 'Gagal menyimpan pengaturan: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hari Nonaktif Sekolah',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Informasi
                      Container(
                        padding: EdgeInsets.all(16.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16.w(context)),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.primary, size: 28.w(context)),
                            SizedBox(width: 12.w(context)),
                            Expanded(
                              child: Text(
                                'Pilih hari libur rutin mingguan sekolah. Hari yang ditandai merah adalah Hari Nonaktif (kegiatan KBM dan presensi ditiadakan).',
                                style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h(context)),

                      // Header Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Hari Mingguan',
                            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.w(context)),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              '${_selectedOffDays.length} Hari Nonaktif (Libur)',
                              style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h(context)),

                      // Daftar 7 Hari
                      Column(
                        children: _allDays.map((day) {
                          final dayKey = day['key']!;
                          final dayLabel = day['label']!;
                          final isOff = _selectedOffDays.contains(dayKey);

                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h(context)),
                            child: InkWell(
                              onTap: () => _toggleDay(dayKey),
                              borderRadius: BorderRadius.circular(16.w(context)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                                decoration: BoxDecoration(
                                  color: isOff ? AppColors.error.withValues(alpha: 0.06) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(16.w(context)),
                                  border: Border.all(
                                    color: isOff ? AppColors.error : AppColors.outline.withValues(alpha: 0.2),
                                    width: isOff ? 1.5 : 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isOff
                                          ? AppColors.error.withValues(alpha: 0.05)
                                          : AppColors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isOff
                                          ? PhosphorIcons.checkSquare(PhosphorIconsStyle.fill)
                                          : PhosphorIcons.square(PhosphorIconsStyle.bold),
                                      color: isOff ? AppColors.error : AppColors.onSurface.withValues(alpha: 0.3),
                                      size: 24.w(context),
                                    ),
                                    SizedBox(width: 14.w(context)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dayLabel,
                                            style: AppTextStyles.titleMedium(context, color: isOff ? AppColors.error : AppColors.onBackground).copyWith(
                                              fontWeight: isOff ? FontWeight.w700 : FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 2.h(context)),
                                          Text(
                                            isOff
                                                ? 'Hari Libur Rutin (KBM & Presensi Libur)'
                                                : 'Hari Aktif (KBM & Presensi Masuk)',
                                            style: AppTextStyles.labelSmall(
                                              context,
                                              color: isOff
                                                  ? AppColors.error.withValues(alpha: 0.8)
                                                  : AppColors.onSurface.withValues(alpha: 0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                                      decoration: BoxDecoration(
                                        color: isOff
                                            ? AppColors.error
                                            : AppColors.outline.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8.w(context)),
                                      ),
                                      child: Text(
                                        isOff ? 'NONAKTIF' : 'AKTIF',
                                        style: AppTextStyles.labelSmall(
                                          context,
                                          color: isOff ? Colors.white : AppColors.onSurface.withValues(alpha: 0.6),
                                        ).copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 32.h(context)),

                      // Tombol Simpan
                      AniseButton(
                        text: 'Simpan Hari Nonaktif',
                        onPressed: _isSaving ? null : _saveSettings,
                        isLoading: _isSaving,
                        icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
