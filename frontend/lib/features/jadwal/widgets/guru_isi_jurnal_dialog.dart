import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../providers/jurnal_provider.dart';

class GuruIsiJurnalDialog extends ConsumerStatefulWidget {
  final String journalId;
  final String subjectName;
  final String className;
  final String timeRange;

  const GuruIsiJurnalDialog({
    super.key,
    required this.journalId,
    required this.subjectName,
    required this.className,
    required this.timeRange,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String journalId,
    required String subjectName,
    required String className,
    required String timeRange,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuruIsiJurnalDialog(
        journalId: journalId,
        subjectName: subjectName,
        className: className,
        timeRange: timeRange,
      ),
    );
  }

  @override
  ConsumerState<GuruIsiJurnalDialog> createState() => _GuruIsiJurnalDialogState();
}

class _GuruIsiJurnalDialogState extends ConsumerState<GuruIsiJurnalDialog> {
  // Controller form
  final TextEditingController _teachingConditionController = TextEditingController();
  final TextEditingController _overallNotesController = TextEditingController();

  bool _isLoadingStudents = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _students = [];

  // 1. Siswa yang tidak hadir
  final List<String> _absentStudentIds = [];

  // 2. Catatan khusus siswa (terlambat, atribut tidak lengkap, lainnya)
  final List<Map<String, dynamic>> _studentDisciplineRecords = [];

  final List<String> _kategoriDisiplinList = [
    'Terlambat',
    'Atribut Tidak Lengkap',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _fetchClassStudents();
  }

  @override
  void dispose() {
    _teachingConditionController.dispose();
    _overallNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchClassStudents() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/journals/${widget.journalId}/class-students');
      if (response.data['status'] == 'success') {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        if (mounted) {
          setState(() {
            _students = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoadingStudents = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingStudents = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  void _addDisciplineRecord() {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar siswa kelas belum tersedia.')),
      );
      return;
    }

    setState(() {
      _studentDisciplineRecords.add({
        'student_id': _students.first['id']?.toString(),
        'category': _kategoriDisiplinList.first,
        'keterangan': '',
      });
    });
  }

  void _removeDisciplineRecord(int index) {
    setState(() {
      _studentDisciplineRecords.removeAt(index);
    });
  }

  Future<void> _submitIsiJurnal() async {
    final condition = _teachingConditionController.text.trim();
    final overall = _overallNotesController.text.trim();

    if (condition.isEmpty && overall.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi deskripsi kondisi mengajar atau catatan menyeluruh.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(dioProvider);
      final payload = {
        'teaching_condition': condition,
        'overall_notes': overall,
        'absent_student_ids': _absentStudentIds,
        'student_records': _studentDisciplineRecords.map((r) => {
          'student_id': r['student_id'],
          'category': r['category'] ?? 'Lainnya',
          'keterangan': (r['keterangan'] as String? ?? '').trim(),
        }).toList(),
      };

      final response = await dio.post('/journals/${widget.journalId}/fill', data: payload);

      if (mounted) {
        setState(() => _isSubmitting = false);
        ref.invalidate(allJournalsProvider);
        Navigator.pop(context, true);

        final msg = response.data['message'] ?? 'Laporan Jurnal KBM berhasil disimpan!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $msg'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        String errMsg = 'Gagal menyimpan jurnal mengajar.';
        if (e is DioException && e.response?.data != null && e.response?.data['message'] != null) {
          errMsg = e.response!.data['message'].toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $errMsg'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h(context), bottom: 12.h(context)),
              width: 40.w(context),
              height: 4.h(context),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2.w(context)),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Isi Jurnal Mengajar',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      '${widget.subjectName} • ${widget.className} (${widget.timeRange})',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 20.w(context)),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.outlineVariant, height: 16.h(context)),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Info
                  Container(
                    padding: EdgeInsets.all(12.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.w(context)),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 20.w(context)),
                        SizedBox(width: 10.w(context)),
                        Expanded(
                          child: Text(
                            'Presensi Cam Jurnal terverifikasi. Silakan lengkapi absensi kelas, dinamika mengajar, serta catatan khusus kedisiplinan siswa.',
                            style: AppTextStyles.labelSmall(context, color: AppColors.onSurface).copyWith(height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h(context)),

                  // BAGIAN A: SIAPA SAJA YANG TIDAK HADIR
                  Row(
                    children: [
                      Icon(PhosphorIcons.userMinus(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.error),
                      SizedBox(width: 6.w(context)),
                      Text(
                        'Siswa Tidak Hadir (Absen / Sakit / Izin)',
                        style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Pilih siswa yang tidak hadir dalam sesi KBM ini:',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                  ),
                  SizedBox(height: 8.h(context)),

                  if (_isLoadingStudents)
                    const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
                  else
                    _buildAbsentStudentsSelector(),

                  SizedBox(height: 20.h(context)),

                  // BAGIAN B: DESKRIPSI KONDISI MENGAJAR
                  Text(
                    'Deskripsi Kondisi Mengajar *',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  TextField(
                    controller: _teachingConditionController,
                    maxLines: 3,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Suasana kelas kondusif, siswa antusias mempraktikkan materi bab 3...',
                      hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: AppColors.surfaceVariant.withValues(alpha: 0.35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.all(14.w(context)),
                    ),
                  ),

                  SizedBox(height: 20.h(context)),

                  // BAGIAN C: CATATAN KHUSUS MENYELURUH
                  Text(
                    'Catatan Khusus Menyeluruh',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  TextField(
                    controller: _overallNotesController,
                    maxLines: 2,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Sebagian kelompok membutuhkan pendampingan tambahan pada pertemuan berikutnya.',
                      hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: AppColors.surfaceVariant.withValues(alpha: 0.35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.all(14.w(context)),
                    ),
                  ),

                  SizedBox(height: 24.h(context)),

                  // BAGIAN D: CATATAN KHUSUS SISWA (SINKRON DISIPLIN)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(PhosphorIcons.warning(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.warning),
                              SizedBox(width: 6.w(context)),
                              Text(
                                'Catatan Khusus Kedisiplinan Siswa',
                                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Terlambat, atribut tidak lengkap, atau lainnya',
                            style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoadingStudents ? null : _addDisciplineRecord,
                        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), size: 14.w(context)),
                        label: Text('Tambah Siswa', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h(context)),

                  if (_studentDisciplineRecords.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12.w(context)),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada catatan disiplin khusus (Semua siswa tertib).',
                          style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ..._studentDisciplineRecords.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final record = entry.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h(context)),
                        padding: EdgeInsets.all(14.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14.w(context)),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Catatan Disiplin #${idx + 1}',
                                  style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeDisciplineRecord(idx),
                                  child: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), color: AppColors.error, size: 18.w(context)),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h(context)),

                            // 1. Search Pick Dropdown Siswa
                            _buildSingleStudentSearchPicker(
                              currentStudentId: record['student_id'],
                              onSelected: (studentId) {
                                setState(() => record['student_id'] = studentId);
                              },
                            ),

                            SizedBox(height: 10.h(context)),

                            // 2. Dropdown Kategori (Terlambat, Atribut Tidak Lengkap, Lainnya)
                            DropdownButtonFormField<String>(
                              initialValue: record['category'],
                              decoration: InputDecoration(
                                labelText: 'Kategori Kedisiplinan',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
                              ),
                              items: _kategoriDisiplinList.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => record['category'] = val);
                              },
                            ),

                            SizedBox(height: 10.h(context)),

                            // 3. Form Menjabarkan Catatan Khusus
                            TextFormField(
                              initialValue: record['keterangan'],
                              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Uraikan catatan khusus/kronologi pelanggaran siswa...',
                                hintStyle: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
                              ),
                              onChanged: (val) => record['keterangan'] = val,
                            ),
                          ],
                        ),
                      );
                    }),

                  SizedBox(height: 24.h(context)),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.onBackground.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.h(context),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitIsiJurnal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w(context))),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.bold), color: AppColors.onPrimary, size: 20.w(context)),
                          SizedBox(width: 8.w(context)),
                          Text(
                            'Simpan & Selesaikan KBM',
                            style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search Pick Selector untuk Siswa Tidak Hadir
  Widget _buildAbsentStudentsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Map<String, dynamic>>(
          displayStringForOption: (option) => option['name'] ?? '',
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _students.where((s) => !_absentStudentIds.contains(s['id']?.toString()));
            }
            return _students.where((s) {
              final name = (s['name'] ?? '').toString().toLowerCase();
              final nis = (s['nis'] ?? '').toString().toLowerCase();
              final q = textEditingValue.text.toLowerCase();
              final isMatch = name.contains(q) || nis.contains(q);
              final notAlreadySelected = !_absentStudentIds.contains(s['id']?.toString());
              return isMatch && notAlreadySelected;
            });
          },
          onSelected: (Map<String, dynamic> selection) {
            final id = selection['id']?.toString();
            if (id != null && !_absentStudentIds.contains(id)) {
              setState(() => _absentStudentIds.add(id));
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Cari nama siswa tidak hadir...',
                hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.surface,
                isDense: true,
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onSurfaceVariant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.h(context), maxWidth: 300.w(context)),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        title: Text(option['name'] ?? '', style: AppTextStyles.bodyMedium(context)),
                        subtitle: Text(option['nis'] ?? '', style: AppTextStyles.labelSmall(context)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),

        // Daftar chip siswa yang ditandai tidak hadir
        if (_absentStudentIds.isNotEmpty) ...[
          SizedBox(height: 8.h(context)),
          Wrap(
            spacing: 6.w(context),
            runSpacing: 6.h(context),
            children: _absentStudentIds.map((id) {
              final student = _students.firstWhere(
                (s) => s['id']?.toString() == id,
                orElse: () => {'name': 'Siswa'},
              );

              return Chip(
                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                labelPadding: EdgeInsets.symmetric(horizontal: 4.w(context)),
                visualDensity: VisualDensity.compact,
                avatar: Icon(PhosphorIcons.userMinus(PhosphorIconsStyle.bold), color: AppColors.error, size: 14.w(context)),
                label: Text(
                  student['name'] ?? 'Siswa',
                  style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w700),
                ),
                deleteIcon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 12.w(context), color: AppColors.error),
                onDeleted: () {
                  setState(() => _absentStudentIds.remove(id));
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Search Pick Selector untuk 1 Siswa pada Catatan Khusus Disiplin
  Widget _buildSingleStudentSearchPicker({
    required String? currentStudentId,
    required ValueChanged<String?> onSelected,
  }) {
    final currentStudent = _students.firstWhere(
      (s) => s['id']?.toString() == currentStudentId,
      orElse: () => {'name': 'Pilih Siswa'},
    );

    return Autocomplete<Map<String, dynamic>>(
      displayStringForOption: (option) => option['name'] ?? '',
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _students;
        }
        return _students.where((s) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          final nis = (s['nis'] ?? '').toString().toLowerCase();
          final q = textEditingValue.text.toLowerCase();
          return name.contains(q) || nis.contains(q);
        });
      },
      onSelected: (Map<String, dynamic> selection) {
        onSelected(selection['id']?.toString());
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (controller.text.isEmpty && currentStudentId != null) {
          controller.text = currentStudent['name'] ?? '';
        }

        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Pilih Siswa Terkait',
            hintText: 'Ketik untuk mencari nama siswa...',
            isDense: true,
            suffixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), size: 16.w(context)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
          ),
        );
      },
      optionsViewBuilder: (context, onSelectOption, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12.w(context)),
            color: AppColors.surface,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200.h(context), maxWidth: 300.w(context)),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option['name'] ?? '', style: AppTextStyles.bodyMedium(context)),
                    subtitle: Text(option['nis'] ?? '', style: AppTextStyles.labelSmall(context)),
                    onTap: () => onSelectOption(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
