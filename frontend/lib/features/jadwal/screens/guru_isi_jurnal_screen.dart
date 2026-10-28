import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../providers/jurnal_provider.dart';

class GuruIsiJurnalScreen extends ConsumerStatefulWidget {
  final String journalId;
  final String subjectName;
  final String className;
  final String timeRange;

  const GuruIsiJurnalScreen({
    super.key,
    required this.journalId,
    required this.subjectName,
    required this.className,
    required this.timeRange,
  });

  @override
  ConsumerState<GuruIsiJurnalScreen> createState() => _GuruIsiJurnalScreenState();
}

class _GuruIsiJurnalScreenState extends ConsumerState<GuruIsiJurnalScreen> {
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
        final existing = response.data['existing'] as Map<String, dynamic>?;

        if (mounted) {
          setState(() {
            _students = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
            _isLoadingStudents = false;

            if (existing != null) {
              if (existing['teaching_condition'] != null && existing['teaching_condition'].toString().isNotEmpty) {
                _teachingConditionController.text = existing['teaching_condition'].toString();
              }
              if (existing['overall_notes'] != null && existing['overall_notes'].toString().isNotEmpty) {
                _overallNotesController.text = existing['overall_notes'].toString();
              } else if (existing['class_notes'] != null && existing['class_notes'].toString().isNotEmpty && _teachingConditionController.text.isEmpty) {
                _overallNotesController.text = existing['class_notes'].toString();
              }

              if (existing['absent_student_ids'] is List) {
                _absentStudentIds.clear();
                for (var id in existing['absent_student_ids']) {
                  _absentStudentIds.add(id.toString());
                }
              }

              if (existing['student_records'] is List) {
                _studentDisciplineRecords.clear();
                for (var rec in existing['student_records']) {
                  if (rec is Map) {
                    _studentDisciplineRecords.add({
                      'student_id': rec['student_id']?.toString(),
                      'category': rec['category']?.toString() ?? 'Lainnya',
                      'keterangan': rec['keterangan']?.toString() ?? '',
                    });
                  }
                }
              }
            }
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Isi Jurnal Mengajar',
        subtitle: '${widget.subjectName} • ${widget.className} (${widget.timeRange})',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Ringkasan Mata Pelajaran & Kelas (Nama kelas di bawah nama mapel)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.w(context)),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.7)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.onBackground.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12.w(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.w(context)),
                            ),
                            child: Icon(
                              PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.bold),
                              color: AppColors.primary,
                              size: 24.w(context),
                            ),
                          ),
                          SizedBox(width: 14.w(context)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama Mapel di atas
                                Text(
                                  widget.subjectName,
                                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4.h(context)),
                                // Nama Kelas di baris kedua
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.usersThree(PhosphorIconsStyle.regular),
                                      size: 14.w(context),
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 5.w(context)),
                                    Text(
                                      widget.className,
                                      style: AppTextStyles.bodyMedium(context, color: AppColors.primary).copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h(context)),
                                // Jam Pelajaran di baris ketiga (tepat di bawah nama kelas)
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.clock(PhosphorIconsStyle.regular),
                                      size: 13.w(context),
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                    SizedBox(width: 5.w(context)),
                                    Text(
                                      widget.timeRange,
                                      style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant).copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h(context)),

                    // A. SISWA TIDAK HADIR
                    Row(
                      children: [
                        Icon(PhosphorIcons.userMinus(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.error),
                        SizedBox(width: 6.w(context)),
                        Text(
                          'Siswa Tidak Hadir',
                          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Pilih siswa yang absen/tidak berada di kelas pada jam pelajaran ini',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    SizedBox(height: 8.h(context)),

                    if (_isLoadingStudents)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h(context)),
                        child: Row(
                          children: [
                            SizedBox(width: 16.w(context), height: 16.w(context), child: const CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 8.w(context)),
                            Text('Memuat daftar siswa kelas...', style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
                    else
                      _buildAbsentStudentsSelector(),

                    SizedBox(height: 20.h(context)),

                    // B. DESKRIPSI KONDISI MENGAJAR
                    Row(
                      children: [
                        Icon(PhosphorIcons.presentation(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
                        SizedBox(width: 6.w(context)),
                        Text(
                          'Deskripsi Kondisi Mengajar',
                          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Jelaskan suasana kelas, kemajuan materi, atau metode pembelajaran yang digunakan',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    SizedBox(height: 8.h(context)),
                    TextFormField(
                      controller: _teachingConditionController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Contoh: Kelas berlangsung interaktif, siswa aktif mempraktikkan materi di lab...',
                        hintStyle: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                        contentPadding: EdgeInsets.all(12.w(context)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      ),
                    ),

                    SizedBox(height: 20.h(context)),

                    // C. CATATAN KHUSUS MENYELURUH
                    Row(
                      children: [
                        Icon(PhosphorIcons.notebook(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.secondary),
                        SizedBox(width: 6.w(context)),
                        Text(
                          'Catatan Khusus Menyeluruh',
                          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Catatan umum kelas, kendala fasilitas, atau hal yang perlu ditindaklanjuti',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    SizedBox(height: 8.h(context)),
                    TextFormField(
                      controller: _overallNotesController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Contoh: LCD proyektor sempat bermasalah, materi bab 3 perlu diulang pada pertemuan berikutnya...',
                        hintStyle: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                        contentPadding: EdgeInsets.all(12.w(context)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      ),
                    ),

                    SizedBox(height: 24.h(context)),

                    // D. CATATAN KHUSUS KEDISIPLINAN SISWA
                    // Header section
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
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Catat pelanggaran disiplin (terlambat, atribut tidak lengkap, dll). Jika Anda guru wali siswa, langsung terinput. Jika bukan, diteruskan ke guru wali sebagai laporan.',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),

                    SizedBox(height: 10.h(context)),

                    // Tombol Tambah Siswa ditaruh tepat di bawah judul section agar lebih rapih
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoadingStudents ? null : _addDisciplineRecord,
                        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
                        label: Text(
                          'Tambah Siswa Bermasalah / Berperingatan',
                          style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          padding: EdgeInsets.symmetric(vertical: 10.h(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                        ),
                      ),
                    ),

                    SizedBox(height: 14.h(context)),

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
                                    child: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.error),
                                  ),
                                ],
                              ),
                              Divider(color: AppColors.outlineVariant, height: 16.h(context)),

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
