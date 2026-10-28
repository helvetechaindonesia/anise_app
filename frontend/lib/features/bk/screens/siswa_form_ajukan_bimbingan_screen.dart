import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../providers/counseling_provider.dart';

class SiswaFormAjukanBimbinganScreen extends ConsumerStatefulWidget {
  const SiswaFormAjukanBimbinganScreen({super.key});

  @override
  ConsumerState<SiswaFormAjukanBimbinganScreen> createState() => _SiswaFormAjukanBimbinganScreenState();
}

class _SiswaFormAjukanBimbinganScreenState extends ConsumerState<SiswaFormAjukanBimbinganScreen> {
  final _descController = TextEditingController();
  String? _selectedGuruBkId;
  String? _selectedTopic;
  DateTime? _selectedDate;
  String? _selectedTime;

  final List<String> _topics = ['Karier', 'Akademik', 'Pribadi', 'Sosial', 'Kedisiplinan', 'Lainnya'];
  final List<String> _timeSlots = [
    '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:15', '10:45', '11:15', '11:45', '13:00',
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

  DateTime _getServerNow(Map<String, dynamic>? offDaysData) {
    final serverTimeStr = offDaysData?['server_time_iso'] ?? offDaysData?['server_time'];
    return (serverTimeStr != null ? DateTime.tryParse(serverTimeStr.toString()) : null) ?? DateTime.now();
  }

  Future<void> _submit(BuildContext context, Map<String, dynamic>? offDaysData) async {
    if (_selectedGuruBkId == null) {
      _showSnackbar('Silakan pilih Guru BK terlebih dahulu!', AppColors.error);
      return;
    }
    if (_selectedTopic == null || _selectedDate == null || _selectedTime == null) {
      _showSnackbar('Lengkapi topik, tanggal, dan waktu bimbingan!', AppColors.error);
      return;
    }

    final serverNow = _getServerNow(offDaysData);
    final timeParts = _selectedTime!.split(':');
    final targetDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      int.tryParse(timeParts[0]) ?? 0,
      int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
    );

    if (targetDateTime.isBefore(serverNow)) {
      _showSnackbar('Waktu bimbingan tidak boleh di waktu yang telah berlalu!', AppColors.error);
      return;
    }

    final success = await ref.read(counselingNotifierProvider.notifier).submit(
          guruBkId: _selectedGuruBkId!,
          topic: _selectedTopic!,
          scheduleDate: _formatDateForApi(_selectedDate!),
          scheduleTime: _selectedTime!,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      _showSnackbar('Pengajuan bimbingan berhasil dikirim ke Guru BK! ✅', Colors.green);
      Navigator.pop(context);
    } else {
      final errorMsg = ref.read(counselingNotifierProvider.notifier).lastErrorMessage;
      _showSnackbar(errorMsg ?? 'Gagal mengajukan bimbingan, silakan coba lagi.', AppColors.error);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.bodyMedium(context, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruBkListAsync = ref.watch(guruBkListProvider);
    final submitState = ref.watch(counselingNotifierProvider);
    final offDaysAsync = ref.watch(offDaysProvider);
    final offDaysData = offDaysAsync.valueOrNull;

    final serverNow = _getServerNow(offDaysData);
    final serverToday = DateTime(serverNow.year, serverNow.month, serverNow.day);
    final releaseDateStr = offDaysData?['app_release_date']?.toString();
    final releaseDate = (releaseDateStr != null ? DateTime.tryParse(releaseDateStr) : null) ?? ApiConstants.appReleaseDate;
    final minDate = serverToday.isBefore(releaseDate) ? releaseDate : serverToday;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Formulir Bimbingan BK',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Card
              Container(
                padding: EdgeInsets.all(14.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16.w(context)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.chats(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 24.w(context)),
                    SizedBox(width: 12.w(context)),
                    Expanded(
                      child: Text(
                        'Sesi bimbingan bersama Guru BK bersifat rahasia dan aman. Jangan ragu untuk bercerita dan berkonsultasi!',
                        style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h(context)),

              // 1. Dropdown Pilih Guru BK
              _buildSectionLabel(context, 'Pilih Guru BK'),
              SizedBox(height: 8.h(context)),
              guruBkListAsync.when(
                data: (guruList) {
                  if (guruList.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(14.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.w(context)),
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Belum ada data Guru BK tersedia di sistem.',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.w(context)),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGuruBkId,
                        hint: Text(
                          'Pilih Guru BK yang dituju',
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                        ),
                        isExpanded: true,
                        icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.6), size: 16.w(context)),
                        items: guruList.map((g) {
                          return DropdownMenuItem<String>(
                            value: g.id,
                            child: Row(
                              children: [
                                Icon(PhosphorIcons.userCircle(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                                SizedBox(width: 8.w(context)),
                                Expanded(
                                  child: Text(
                                    g.name,
                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedGuruBkId = val;
                          });
                        },
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
                error: (err, _) => Text('Gagal memuat Guru BK: $err', style: TextStyle(color: AppColors.error)),
              ),
              SizedBox(height: 18.h(context)),

              // 2. Dropdown Topik Bimbingan
              _buildSectionLabel(context, 'Topik Bimbingan'),
              SizedBox(height: 8.h(context)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTopic,
                    hint: Text('Pilih topik bimbingan',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
                    isExpanded: true,
                    icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.6), size: 16.w(context)),
                    items: _topics
                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedTopic = v),
                  ),
                ),
              ),
              SizedBox(height: 18.h(context)),

              // 3. Tanggal Konsultasi
              _buildSectionLabel(context, 'Tentukan Tanggal'),
              SizedBox(height: 8.h(context)),
              GestureDetector(
                onTap: () async {
                  final initial = _selectedDate != null && !_selectedDate!.isBefore(minDate)
                      ? _selectedDate!
                      : minDate;
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: minDate,
                    lastDate: minDate.add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                      // Jika ganti tanggal dan jam sebelumnya jadi lampau, reset jam
                      if (_selectedTime != null) {
                        final parts = _selectedTime!.split(':');
                        final checkDt = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          int.tryParse(parts[0]) ?? 0,
                          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                        );
                        if (checkDt.isBefore(serverNow)) {
                          _selectedTime = null;
                        }
                      }
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(16.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.w(context)),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.6), size: 20.w(context)),
                      SizedBox(width: 12.w(context)),
                      Text(
                        _selectedDate != null ? _formatDate(_selectedDate!) : 'Pilih tanggal konsultasi',
                        style: AppTextStyles.bodyMedium(context, color: _selectedDate != null ? AppColors.onBackground : AppColors.onBackground.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h(context)),

              // 4. Waktu / Jam
              _buildSectionLabel(context, 'Pilih Waktu (Jam)'),
              SizedBox(height: 8.h(context)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTime,
                    hint: Text('Tentukan jam konsultasi',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
                    isExpanded: true,
                    icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.6), size: 16.w(context)),
                    items: _timeSlots.map((t) {
                      bool isPastSlot = false;
                      if (_selectedDate != null) {
                        final parts = t.split(':');
                        final slotDt = DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                          int.tryParse(parts[0]) ?? 0,
                          int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
                        );
                        if (slotDt.isBefore(serverNow)) {
                          isPastSlot = true;
                        }
                      }
                      return DropdownMenuItem(
                        value: isPastSlot ? null : t,
                        enabled: !isPastSlot,
                        child: Text(
                          isPastSlot ? '$t (Telah Berlalu)' : t,
                          style: AppTextStyles.bodyMedium(
                            context,
                            color: isPastSlot ? AppColors.textSecondary.withValues(alpha: 0.4) : AppColors.onBackground,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedTime = v);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 18.h(context)),

              // 5. Deskripsi Singkat
              _buildSectionLabel(context, 'Deskripsi Singkat / Keluhan'),
              SizedBox(height: 8.h(context)),
              TextField(
                controller: _descController,
                maxLines: 4,
                style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.onBackground),
                decoration: InputDecoration(
                  hintText: 'Tuliskan sedikit keluhan atau topik yang ingin dibahas bersama Guru BK...',
                  hintStyle: GoogleFonts.outfit(fontSize: 13.sp(context), color: AppColors.onBackground.withValues(alpha: 0.45)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                  ),
                  contentPadding: EdgeInsets.all(16.w(context)),
                ),
              ),
              SizedBox(height: 32.h(context)),

              // 6. Tombol Kirim Pengajuan
              ElevatedButton(
                onPressed: submitState is AsyncLoading ? null : () => _submit(context, offDaysData),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w(context))),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Center(
                  child: submitState is AsyncLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Kirim Pengajuan Bimbingan', style: AppTextStyles.titleMedium(context, color: Colors.white)),
                ),
              ),
              SizedBox(height: 30.h(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
    );
  }
}
