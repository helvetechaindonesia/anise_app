import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/counseling_provider.dart';

class SiswaAjukanBimbinganScreen extends ConsumerStatefulWidget {
  const SiswaAjukanBimbinganScreen({super.key});

  @override
  ConsumerState<SiswaAjukanBimbinganScreen> createState() => _SiswaAjukanBimbinganScreenState();
}

class _SiswaAjukanBimbinganScreenState extends ConsumerState<SiswaAjukanBimbinganScreen> {
  final _descController = TextEditingController();
  String? _selectedTopic;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _topics = ['Karier', 'Akademik', 'Pribadi', 'Sosial', 'Lainnya'];
  final List<String> _timeSlots = [
    '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00', '13:00',
    '13:30', '14:00', '14:30',
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDateForApi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final guruBkAsync = ref.watch(guruBkProvider);
    final submitState = ref.watch(counselingNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Info header
                  Container(
                    padding: EdgeInsets.all(16.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16.w(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.chats(PhosphorIconsStyle.fill), color: AppColors.primary, size: 24.w(context)),
                        SizedBox(width: 12.w(context)),
                        Expanded(
                          child: Text(
                            'Sesi bimbingan bersama guru BK bersifat rahasia. Jangan ragu untuk bercerita!',
                            style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h(context)),

                  // Guru BK Info
                  guruBkAsync.when(
                    data: (guru) {
                      if (guru == null) {
                        return Container(
                          padding: EdgeInsets.all(12.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.w(context)),
                          ),
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill), color: AppColors.error, size: 18.w(context)),
                              SizedBox(width: 8.w(context)),
                              Expanded(
                                child: Text(
                                  'Guru BK belum ditugaskan untuk kelas kamu.',
                                  style: AppTextStyles.labelMedium(context, color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        padding: EdgeInsets.all(12.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12.w(context)),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44.w(context),
                              height: 44.w(context),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), color: AppColors.primary, size: 24.w(context)),
                            ),
                            SizedBox(width: 12.w(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Guru BK', style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
                                  Text(guru.name, style: AppTextStyles.titleSmall(context, color: AppColors.onSurface)),
                                ],
                              ),
                            ),
                            Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.success, size: 20.w(context)),
                          ],
                        ),
                      );
                    },
                    loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (e, _) => Container(
                      padding: EdgeInsets.all(12.w(context)),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.w(context))),
                      child: Text('Gagal memuat info guru BK', style: AppTextStyles.labelMedium(context, color: AppColors.error)),
                    ),
                  ),
                  SizedBox(height: 20.h(context)),

                  // Topic Dropdown
                  _buildSectionLabel(context, 'Topik Bimbingan'),
                  SizedBox(height: 8.h(context)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTopic,
                        hint: Text('Pilih topik (Karier, Akademik, Pribadi...)',
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4))),
                        isExpanded: true,
                        icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.5), size: 16.w(context)),
                        items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)))).toList(),
                        onChanged: (v) => setState(() => _selectedTopic = v),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Date Picker
                  _buildSectionLabel(context, 'Pilih Tanggal'),
                  SizedBox(height: 8.h(context)),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.w(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.5), size: 20.w(context)),
                          SizedBox(width: 12.w(context)),
                          Text(
                            _selectedDate != null ? _formatDate(_selectedDate!) : 'Tentukan tanggal konsultasi',
                            style: AppTextStyles.bodyMedium(context, color: _selectedDate != null ? AppColors.onBackground : AppColors.onBackground.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Time Dropdown
                  _buildSectionLabel(context, 'Pilih Waktu (Jam)'),
                  SizedBox(height: 8.h(context)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTime,
                        hint: Text('Tentukan jam konsultasi',
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4))),
                        isExpanded: true,
                        icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.5), size: 16.w(context)),
                        items: _timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground)))).toList(),
                        onChanged: (v) => setState(() => _selectedTime = v),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Description
                  _buildSectionLabel(context, 'Deskripsi Singkat'),
                  SizedBox(height: 8.h(context)),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ceritakan sedikit tentang apa yang ingin dibahas',
                      hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(16.w(context)),
                    ),
                  ),
                  SizedBox(height: 32.h(context)),

                  // Submit
                  ElevatedButton(
                    onPressed: submitState is AsyncLoading ? null : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      elevation: 0,
                    ),
                    child: Center(
                      child: submitState is AsyncLoading
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
                          : Text('Ajukan Bimbingan', style: AppTextStyles.titleSmall(context, color: AppColors.onPrimary)),
                    ),
                  ),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (_selectedTopic == null || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua field wajib terlebih dahulu!'), backgroundColor: AppColors.error),
      );
      return;
    }

    final success = await ref.read(counselingNotifierProvider.notifier).submit(
          topic: _selectedTopic!,
          scheduleDate: _formatDateForApi(_selectedDate!),
          scheduleTime: _selectedTime!,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal bimbingan berhasil diajukan! ✅'), backgroundColor: Colors.green),
      );
      // Refresh riwayat
      ref.invalidate(siswaKonsultasiProvider);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengajukan bimbingan, coba lagi.'), backgroundColor: AppColors.error),
      );
    }
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
          Text('Ajukan Bimbingan BK', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground));
  }
}
