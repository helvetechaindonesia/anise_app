import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../providers/counseling_provider.dart';
import '../providers/disiplin_provider.dart';

class BkInputBimbinganScreen extends ConsumerStatefulWidget {
  const BkInputBimbinganScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BkInputBimbinganScreen> createState() => _BkInputBimbinganScreenState();
}

class _BkInputBimbinganScreenState extends ConsumerState<BkInputBimbinganScreen> {
  // Jenis Bimbingan: 'KLASIKAL', 'INDIVIDU', 'KELOMPOK'
  String _selectedType = 'KLASIKAL';
  final List<Map<String, String>> _typeOptions = [
    {'value': 'KLASIKAL', 'label': 'Bimbingan Klasikal (Di Kelas)'},
    {'value': 'INDIVIDU', 'label': 'Bimbingan Individu (Di Ruang BK)'},
    {'value': 'KELOMPOK', 'label': 'Bimbingan Kelompok (Di Ruang BK)'},
  ];

  // Form Klasikal
  String? _selectedClassId;
  String? _selectedScheduleId;

  // Form Individu / Kelompok
  final List<Map<String, dynamic>> _selectedStudents = [];

  // Form Umum
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void dispose() {
    _topicController.dispose();
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

  Future<void> _submit(Map<String, dynamic>? offDaysData) async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      _showSnackbar('Topik / Agenda bimbingan wajib diisi!', AppColors.error);
      return;
    }

    if (_selectedType == 'KLASIKAL') {
      if (_selectedClassId == null) {
        _showSnackbar('Pilih kelas terlebih dahulu!', AppColors.error);
        return;
      }
      if (_selectedScheduleId == null) {
        _showSnackbar('Pilih jadwal mapel/guru yang akan diganti!', AppColors.error);
        return;
      }
    } else {
      // Individu atau Kelompok
      if (_selectedStudents.isEmpty) {
        _showSnackbar('Pilih minimal 1 siswa!', AppColors.error);
        return;
      }
      if (_selectedDate == null) {
        _showSnackbar('Pilih tanggal pelaksanaan!', AppColors.error);
        return;
      }
      if (_selectedTime == null) {
        _showSnackbar('Pilih jam pelaksanaan!', AppColors.error);
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
        _showSnackbar('Waktu pelaksanaan tidak boleh di waktu yang telah berlalu!', AppColors.error);
        return;
      }
    }

    final dateStr = _selectedDate != null ? _formatDateForApi(_selectedDate!) : '';
    final studentIds = _selectedStudents.map((s) => s['id'].toString()).toList();

    final ok = await ref.read(counselingNotifierProvider.notifier).createByGuruBk(
          type: _selectedType,
          topic: topic,
          scheduleDate: dateStr.isNotEmpty ? dateStr : null,
          scheduleTime: _selectedTime,
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          classId: _selectedClassId,
          scheduleId: _selectedScheduleId,
          studentIds: studentIds,
        );

    if (!mounted) return;

    if (ok) {
      _showSnackbar('Jadwal bimbingan berhasil dibuat dan disimpan!', Colors.green);
      Navigator.pop(context);
    } else {
      final errorMsg = ref.read(counselingNotifierProvider.notifier).lastErrorMessage;
      _showSnackbar(errorMsg ?? 'Gagal menyimpan jadwal bimbingan, coba lagi.', AppColors.error);
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
    final classesAsync = ref.watch(bkKlasikalClassesProvider);
    final studentsAsync = ref.watch(allSiswaProvider);
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Jadwalkan Bimbingan BK',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 20.h(context)),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Jenis Bimbingan
            _buildSectionLabel('Jenis Bimbingan'),
            SizedBox(height: 8.h(context)),
            _buildDropdown(
              value: _selectedType,
              items: _typeOptions
                  .map((t) => DropdownMenuItem(value: t['value'], child: Text(t['label']!)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                    _selectedClassId = null;
                    _selectedScheduleId = null;
                    _selectedStudents.clear();
                  });
                }
              },
            ),
            SizedBox(height: 18.h(context)),

            // 2A. FORM KHUSUS BIMBINGAN KLASIKAL
            if (_selectedType == 'KLASIKAL') ...[
              _buildKlasikalSection(classesAsync),
            ]
            // 2B. FORM KHUSUS BIMBINGAN INDIVIDU & KELOMPOK
            else ...[
              _buildStudentSearchSection(studentsAsync),
            ],

            SizedBox(height: 18.h(context)),

            // 3. Topik / Agenda Bimbingan
            _buildSectionLabel('Topik / Agenda Bimbingan'),
            SizedBox(height: 8.h(context)),
            TextField(
              controller: _topicController,
              style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.onBackground),
              decoration: _inputDecoration('Contoh: Motivasi Belajar, Sosialisasi Karir, Mediasi'),
            ),
            SizedBox(height: 18.h(context)),

            // 4 & 5. Tanggal & Jam Pelaksanaan (HANYA UNTUK INDIVIDU & KELOMPOK)
            // (Untuk Klasikal otomatis mengikuti jadwal mapel KBM yang diganti)
            if (_selectedType != 'KLASIKAL') ...[
              // Tanggal Pelaksanaan (Kalender Picker)
              _buildSectionLabel('Tanggal Pelaksanaan'),
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
                      Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                      SizedBox(width: 12.w(context)),
                      Text(
                        _selectedDate != null ? _formatDate(_selectedDate!) : 'Pilih tanggal bimbingan',
                        style: AppTextStyles.bodyMedium(context,
                            color: _selectedDate != null ? AppColors.onBackground : AppColors.onBackground.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h(context)),

              // Jam Pelaksanaan (Input Jam)
              _buildSectionLabel('Jam Pelaksanaan'),
              SizedBox(height: 8.h(context)),
              GestureDetector(
                onTap: () async {
                  final initial = _selectedTime != null && _selectedTime!.contains(':')
                      ? TimeOfDay(
                          hour: int.tryParse(_selectedTime!.split(':')[0]) ?? serverNow.hour,
                          minute: int.tryParse(_selectedTime!.split(':')[1]) ?? serverNow.minute,
                        )
                      : TimeOfDay(hour: serverNow.hour, minute: serverNow.minute);

                  final picked = await showTimePicker(
                    context: context,
                    initialTime: initial,
                  );
                  if (picked != null) {
                    final h = picked.hour.toString().padLeft(2, '0');
                    final m = picked.minute.toString().padLeft(2, '0');
                    final checkDate = _selectedDate ?? serverToday;
                    final pickedDt = DateTime(checkDate.year, checkDate.month, checkDate.day, picked.hour, picked.minute);
                    if (pickedDt.isBefore(serverNow)) {
                      _showSnackbar('Jam pelaksanaan tidak boleh di waktu yang telah berlalu!', AppColors.error);
                      return;
                    }
                    setState(() => _selectedTime = '$h:$m');
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
                      Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                      SizedBox(width: 12.w(context)),
                      Text(
                        _selectedTime != null ? '$_selectedTime WIB' : 'Pilih jam pelaksanaan',
                        style: AppTextStyles.bodyMedium(context,
                            color: _selectedTime != null ? AppColors.onBackground : AppColors.onBackground.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18.h(context)),
            ],

            // 6. Deskripsi / Catatan Khusus
            _buildSectionLabel('Deskripsi / Catatan Tambahan (Opsional)'),
            SizedBox(height: 8.h(context)),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.onBackground),
              decoration: _inputDecoration('Tuliskan rincian atau catatan persiapan bimbingan...'),
            ),
            SizedBox(height: 32.h(context)),

            // 7. Tombol Simpan Jadwal
            SizedBox(
              width: double.infinity,
              height: 52.h(context),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w(context))),
                  elevation: 0,
                ),
                onPressed: submitState is AsyncLoading ? null : () => _submit(offDaysData),
                child: submitState is AsyncLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Simpan & Terbitkan Jadwal',
                        style: AppTextStyles.titleMedium(context, color: Colors.white).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 40.h(context)),
          ],
        ),
      ),
    );
  }

  // Widget Bagian Bimbingan Klasikal
  Widget _buildKlasikalSection(AsyncValue<List<Map<String, dynamic>>> classesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.w(context)),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.primary, size: 20.w(context)),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Text(
                  'Bimbingan Klasikal akan mengganti jam KBM guru bersangkutan dan otomatis menimpa jurnal kelas menjadi Jurnal Bimbingan BK.',
                  style: GoogleFonts.outfit(fontSize: 12.sp(context), color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h(context)),

        // 1. Pilih Kelas
        _buildSectionLabel('Pilih Kelas'),
        SizedBox(height: 8.h(context)),
        classesAsync.when(
          data: (classes) {
            return _buildDropdown(
              value: _selectedClassId,
              hint: 'Pilih kelas sasaran',
              items: classes
                  .map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'])))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _selectedClassId = val;
                  _selectedScheduleId = null;
                });
              },
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
          error: (err, _) => Text('Gagal memuat kelas: $err', style: const TextStyle(color: AppColors.error)),
        ),

        // 2. Pilih Jadwal KBM (Guru, Mapel & Jam) yang Diganti
        if (_selectedClassId != null) ...[
          SizedBox(height: 16.h(context)),
          _buildSectionLabel('Pilih Guru, Mapel & Jam yang Diganti'),
          SizedBox(height: 8.h(context)),
          Consumer(
            builder: (context, ref, _) {
              final schedulesAsync = ref.watch(bkKlasikalSchedulesProvider(_selectedClassId!));
              return schedulesAsync.when(
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(14.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.w(context)),
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'Tidak ditemukan jadwal KBM aktif untuk kelas ini.',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return _buildDropdown(
                    value: _selectedScheduleId,
                    hint: 'Pilih jadwal mapel yang akan diganti',
                    items: schedules.map((s) {
                      return DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text(
                          "${s['teacher_name']} • ${s['subject_name']} (${s['time_label']})",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      final selectedItem = schedules.firstWhere((s) => s['id'].toString() == val, orElse: () => {});
                      setState(() {
                        _selectedScheduleId = val;
                        if (selectedItem['start_time'] != null) {
                          _selectedTime = substrTime(selectedItem['start_time']);
                        }
                      });
                    },
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
                error: (err, _) => Text('Gagal memuat jadwal: $err', style: const TextStyle(color: AppColors.error)),
              );
            },
          ),
        ],
      ],
    );
  }

  String substrTime(dynamic time) {
    final str = time.toString();
    if (str.length >= 5) {
      return str.substring(0, 5);
    }
    return str;
  }

  // Widget Bagian Search Pick Siswa (Individu & Kelompok)
  Widget _buildStudentSearchSection(AsyncValue<List<dynamic>> studentsAsync) {
    final isKelompok = _selectedType == 'KELOMPOK';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(isKelompok ? 'Pilih Siswa (Bisa Multiple)' : 'Pilih Nama Siswa'),
        SizedBox(height: 8.h(context)),
        studentsAsync.when(
          data: (students) {
            return Autocomplete<Map<String, dynamic>>(
              displayStringForOption: (option) => option['full_name'] ?? '',
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                return students
                    .map((e) => Map<String, dynamic>.from(e as Map))
                    .where((s) => (s['full_name'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (Map<String, dynamic> selection) {
                setState(() {
                  final id = selection['id'].toString();
                  if (!isKelompok) {
                    _selectedStudents.clear();
                    _selectedStudents.add(selection);
                  } else {
                    if (!_selectedStudents.any((s) => s['id'].toString() == id)) {
                      _selectedStudents.add(selection);
                    }
                  }
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: isKelompok ? 'Ketik nama untuk menambah siswa...' : 'Ketik nama siswa...',
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
                    prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onBackground.withValues(alpha: 0.5)),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12.w(context)),
                    color: AppColors.surface,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40.w(context),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final opt = options.elementAt(index);
                          return ListTile(
                            leading: Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                            title: Text(opt['full_name'] ?? '', style: AppTextStyles.bodyMedium(context)),
                            subtitle: Text('Kelas: ${opt['class_name'] ?? '-'}', style: AppTextStyles.labelSmall(context, color: AppColors.textSecondary)),
                            onTap: () => onSelected(opt),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
          error: (err, _) => Text('Gagal memuat siswa: $err', style: const TextStyle(color: AppColors.error)),
        ),

        // Chips daftar siswa terpilih
        if (_selectedStudents.isNotEmpty) ...[
          SizedBox(height: 10.h(context)),
          Wrap(
            spacing: 8.w(context),
            runSpacing: 6.h(context),
            children: _selectedStudents.map((s) {
              return Chip(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                label: Text(
                  s['full_name'] ?? '',
                  style: GoogleFonts.outfit(fontSize: 12.sp(context), color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                onDeleted: () {
                  setState(() {
                    _selectedStudents.removeWhere((item) => item['id'] == s['id']);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: hint != null
              ? Text(hint, style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.45)))
              : null,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}
