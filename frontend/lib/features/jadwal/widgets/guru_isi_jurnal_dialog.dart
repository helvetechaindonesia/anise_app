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
    Key? key,
    required this.journalId,
    required this.subjectName,
    required this.className,
    required this.timeRange,
  }) : super(key: key);

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
  final TextEditingController _notesController = TextEditingController();
  bool _isLoadingStudents = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _studentRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchClassStudents();
  }

  @override
  void dispose() {
    _notesController.dispose();
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
    } catch (e) {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  void _addStudentRecord() {
    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar siswa kelas belum tersedia.')),
      );
      return;
    }

    setState(() {
      _studentRecords.add({
        'student_id': _students.first['id'],
        'record_type': 'ABSENCE',
        'keterangan': '',
      });
    });
  }

  void _removeStudentRecord(int index) {
    setState(() {
      _studentRecords.removeAt(index);
    });
  }

  Future<void> _submitIsiJurnal() async {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan KBM / Dinamika Kelas wajib diisi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(dioProvider);
      final payload = {
        'class_notes': notes,
        'student_records': _studentRecords.map((r) => {
          'student_id': r['student_id'],
          'record_type': r['record_type'],
          'keterangan': (r['keterangan'] as String).trim().isNotEmpty 
              ? (r['keterangan'] as String).trim() 
              : 'Dicatat oleh guru saat KBM',
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
            backgroundColor: Colors.green,
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
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
                      'Isi Laporan Jurnal KBM',
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
                            'Presensi Cam Anda telah terverifikasi. Silakan isi catatan dinamika kelas & anomali siswa (bolos, pelanggaran, atau prestasi).',
                            style: AppTextStyles.labelSmall(context, color: AppColors.onSurface).copyWith(height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h(context)),

                  // Field 1: Catatan KBM
                  Text(
                    'Catatan Dinamika KBM & Materi *',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Materi Bab 3 tersampaikan tuntas. Siswa aktif berdiskusi kelompok, evaluasi berjalan lancar...',
                      hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
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
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.all(14.w(context)),
                    ),
                  ),

                  SizedBox(height: 24.h(context)),

                  // Field 2: Catatan Anomali Siswa Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Khusus Siswa',
                            style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Bolos mapel, pelanggaran kelas, atau prestasi',
                            style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoadingStudents ? null : _addStudentRecord,
                        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), size: 14.w(context)),
                        label: Text('Tambah Siswa', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary)),
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

                  if (_isLoadingStudents)
                    Center(child: Padding(padding: EdgeInsets.all(16.h(context)), child: const CircularProgressIndicator()))
                  else if (_studentRecords.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12.w(context)),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Center(
                        child: Text(
                          'Tidak ada anomali siswa (Semua siswa hadir tertib)',
                          style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    ..._studentRecords.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final record = entry.value;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h(context)),
                        padding: EdgeInsets.all(14.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.4),
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
                                  'Catatan #${idx + 1}',
                                  style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeStudentRecord(idx),
                                  child: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), color: AppColors.error, size: 18.w(context)),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h(context)),

                            // Pilih Siswa
                            DropdownButtonFormField<String>(
                              value: record['student_id'],
                              decoration: InputDecoration(
                                labelText: 'Pilih Siswa',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
                              ),
                              items: _students.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s['id']?.toString(),
                                  child: Text(
                                    s['name'] ?? 'Siswa',
                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => record['student_id'] = val);
                              },
                            ),

                            SizedBox(height: 8.h(context)),

                            // Tipe Anomali
                            DropdownButtonFormField<String>(
                              value: record['record_type'],
                              decoration: InputDecoration(
                                labelText: 'Tipe Catatan',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'ABSENCE', child: Text('🔴 Siswa Bolos Mapel')),
                                DropdownMenuItem(value: 'VIOLATION', child: Text('⚠️ Pelanggaran Kelas (Sinkron Disiplin)')),
                                DropdownMenuItem(value: 'ACHIEVEMENT', child: Text('🌟 Prestasi / Keaktifan Ekstra')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => record['record_type'] = val);
                              },
                            ),

                            SizedBox(height: 8.h(context)),

                            // Keterangan
                            TextFormField(
                              initialValue: record['keterangan'],
                              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Keterangan rinci...',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.w(context))),
                              ),
                              onChanged: (val) => record['keterangan'] = val,
                            ),
                          ],
                        ),
                      );
                    }).toList(),

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
}
