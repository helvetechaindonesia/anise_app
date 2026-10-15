import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';

class TuKurikulumDialogs {
  // =========================================================================
  // 1. UPLOAD EXCEL BOTTOM SHEET
  // =========================================================================
  static void showUploadSheet(BuildContext context, WidgetRef ref, VoidCallback onSuccess) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          top: 20.h(context),
          left: 24.w(context),
          right: 24.w(context),
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w(context),
                    height: 5.h(context),
                    decoration: BoxDecoration(
                      color: AppColors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 18.h(context)),
                Text(
                  'Upload Data Kurikulum',
                  style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  'Pilih jenis master data yang ingin diimpor secara massal via file Excel/XLSX.',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
                SizedBox(height: 16.h(context)),
                _buildUploadOption(context, ref, 'Master Wali Kelas', 'wali_kelas', PhosphorIcons.chalkboardTeacher(), onSuccess),
                _buildUploadOption(context, ref, 'Master Guru Wali (BK)', 'guru_wali', PhosphorIcons.usersThree(), onSuccess),
                _buildUploadOption(context, ref, 'Master Penugasan Struktural', 'penugasan', PhosphorIcons.briefcase(), onSuccess),
                _buildUploadOption(context, ref, 'Master Mata Pelajaran (Mapel)', 'mapel', PhosphorIcons.books(), onSuccess),
                _buildUploadOption(context, ref, 'Master Jadwal KBM', 'jurnal_mengajar', PhosphorIcons.calendar(), onSuccess),
                _buildUploadOption(context, ref, 'Kalender Akademik (Agenda)', 'kalender_akademik', PhosphorIcons.calendarCheck(), onSuccess),
                _buildUploadOption(context, ref, 'Hari Libur Nasional & Sekolah', 'hari_libur', PhosphorIcons.sun(), onSuccess),
                SizedBox(height: 12.h(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildUploadOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String type,
    IconData icon,
    VoidCallback onSuccess,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12.w(context)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.w(context)),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.4), size: 18.w(context)),
      contentPadding: EdgeInsets.symmetric(vertical: 4.h(context)),
      onTap: () {
        Navigator.pop(context);
        _handleUploadFile(context, ref, title, type, onSuccess);
      },
    );
  }

  static Future<void> _handleUploadFile(
    BuildContext context,
    WidgetRef ref,
    String title,
    String type,
    VoidCallback onSuccess,
  ) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      final filePath = picked.path;
      final fileName = picked.name;
      if (filePath == null) return;

      if (!context.mounted) return;

      // Tampilkan loading modal
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w(context))),
            child: Padding(
              padding: EdgeInsets.all(24.w(context)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 20.h(context)),
                  Text(
                    'Mengunggah & Menyinkronkan...',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    'File $fileName sedang diproses.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final dio = ref.read(dioProvider);
      final response = await dio.post('/curriculum/parse/$type', data: formData);

      if (context.mounted) {
        Navigator.pop(context); // Tutup loading dialog
      }

      if (context.mounted) {
        AniseFeedbackDialog.showSuccess(
          context,
          title: 'Sinkronisasi Berhasil',
          message: response.data['message'] ?? 'Data $title berhasil diperbarui ke database.',
          onConfirm: onSuccess,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Tutup loading jika masih terbuka
      }

      String errorMsg = 'Terjadi kesalahan saat memproses file Excel.';
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMsg = e.response!.data['message'].toString();
        }
      }

      if (context.mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Sinkronisasi',
          message: errorMsg,
        );
      }
    }
  }

  // =========================================================================
  // 2. MODAL PILIHAN TAMBAH DATA MANUAL
  // =========================================================================
  static void showManualAddChoiceSheet(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onSuccess,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.only(
          top: 20.h(context),
          left: 24.w(context),
          right: 24.w(context),
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44.w(context),
                    height: 5.h(context),
                    decoration: BoxDecoration(
                      color: AppColors.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 18.h(context)),
                Text(
                  'Tambah Data Manual',
                  style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  'Pilih jenis data yang ingin diinput secara manual. Data master lainnya diinput secara massal via file Excel.',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
                SizedBox(height: 16.h(context)),
                _buildChoiceTile(
                  context,
                  title: 'Kalender Akademik',
                  subtitle: 'Tambah agenda kegiatan sekolah, jadwal PTS, PAS, atau hari aktif',
                  icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
                  iconBgColor: AppColors.menuPastelPurple,
                  iconColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    showKalenderAkademikForm(context, ref, onSuccess: onSuccess);
                  },
                ),
                SizedBox(height: 10.h(context)),
                _buildChoiceTile(
                  context,
                  title: 'Hari Libur Nasional & Sekolah',
                  subtitle: 'Tambah hari libur nasional, libur khusus, atau cuti bersama',
                  icon: PhosphorIcons.sun(PhosphorIconsStyle.fill),
                  iconBgColor: AppColors.error.withValues(alpha: 0.12),
                  iconColor: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    showHariLiburForm(context, ref, onSuccess: onSuccess);
                  },
                ),
                SizedBox(height: 16.h(context)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 12.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14.w(context)),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.primary, size: 20.w(context)),
                      SizedBox(width: 10.w(context)),
                      Expanded(
                        child: Text(
                          'Catatan: Data Wali Kelas, Siswa Asuh, Penugasan, Mapel, dan Jadwal KBM diinput secara massal melalui tombol "Upload Excel".',
                          style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildChoiceTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.w(context)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14.w(context)),
              ),
              child: Icon(icon, color: iconColor, size: 22.w(context)),
            ),
            SizedBox(width: 14.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.3), size: 18.w(context)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 3. MODAL FORM: KALENDER AKADEMIK
  // =========================================================================
  static void showKalenderAkademikForm(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? item,
    required VoidCallback onSuccess,
  }) {
    final isEdit = item != null;
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final startDateCtrl = TextEditingController(text: item?['start_date'] ?? '');
    final endDateCtrl = TextEditingController(text: item?['end_date'] ?? '');
    String selectedType = item?['type'] ?? 'KEGIATAN';
    
    // Inisialisasi Checkbox Tingkat (X, XI, XII)
    final initialGrade = (item?['target_grade'] ?? 'SEMUA').toString().toUpperCase().trim();
    final gradeTokens = initialGrade.split('+').map((s) => s.trim()).toList();
    bool gradeX = initialGrade == 'SEMUA' || initialGrade == '#' || gradeTokens.contains('X') || gradeTokens.contains('10');
    bool gradeXI = initialGrade == 'SEMUA' || initialGrade == '#' || gradeTokens.contains('XI') || gradeTokens.contains('11');
    bool gradeXII = initialGrade == 'SEMUA' || initialGrade == '#' || gradeTokens.contains('XII') || gradeTokens.contains('12');

    bool isHoliday = item?['is_holiday'] == true;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24.w(context),
              right: 24.w(context),
              top: 20.h(context),
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w(context),
                      height: 5.h(context),
                      decoration: BoxDecoration(
                        color: AppColors.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h(context)),
                  Text(
                    isEdit ? 'Edit Agenda Kalender' : 'Tambah Agenda Kalender Baru',
                    style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16.h(context)),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Agenda Kegiatan / Ujian',
                      hintText: 'Contoh: Penilaian Akhir Semester (PAS)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                  ),
                  SizedBox(height: 14.h(context)),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Jenis Agenda',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ASESMEN', child: Text('Asesmen / Ujian')),
                      DropdownMenuItem(value: 'KEGIATAN', child: Text('Kegiatan Sekolah')),
                      DropdownMenuItem(value: 'SEREMONIAL', child: Text('Seremonial / Upacara')),
                      DropdownMenuItem(value: 'ADMINISTRASI', child: Text('Administrasi / Rapor')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  SizedBox(height: 14.h(context)),
                  Text(
                    'Sasaran Tingkat Kelas',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.8)),
                  ),
                  SizedBox(height: 6.h(context)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14.w(context)),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGradeCheckbox(context, 'Tingkat X', gradeX, (val) => setModalState(() => gradeX = val ?? false)),
                        _buildGradeCheckbox(context, 'Tingkat XI', gradeXI, (val) => setModalState(() => gradeXI = val ?? false)),
                        _buildGradeCheckbox(context, 'Tingkat XII', gradeXII, (val) => setModalState(() => gradeXII = val ?? false)),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h(context)),
                  TextField(
                    controller: startDateCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Mulai (YYYY-MM-DD)',
                      suffixIcon: Icon(PhosphorIcons.calendar()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() {
                          startDateCtrl.text = picked.toIso8601String().split('T').first;
                          if (endDateCtrl.text.isEmpty) {
                            endDateCtrl.text = startDateCtrl.text;
                          }
                        });
                      }
                    },
                  ),
                  SizedBox(height: 14.h(context)),
                  TextField(
                    controller: endDateCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Selesai (YYYY-MM-DD)',
                      suffixIcon: Icon(PhosphorIcons.calendar()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(startDateCtrl.text) ?? DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() {
                          endDateCtrl.text = picked.toIso8601String().split('T').first;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 14.h(context)),
                  SwitchListTile(
                    title: Text('Liburkan Presensi Kegiatan?', style: AppTextStyles.titleSmall(context)),
                    subtitle: Text('Jika aktif, presensi tidak memicu sanksi alfa selama agenda berlangsung.', style: AppTextStyles.bodySmall(context)),
                    value: isHoliday,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setModalState(() => isHoliday = val),
                  ),
                  SizedBox(height: 20.h(context)),
                  AniseButton(
                    text: isEdit ? 'Simpan Agenda' : 'Tambah Agenda',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final start = startDateCtrl.text.trim();
                            final end = endDateCtrl.text.trim();
                            if (name.isEmpty || start.isEmpty || end.isEmpty) {
                              AniseFeedbackDialog.showError(
                                context,
                                title: 'Input Tidak Lengkap',
                                message: 'Nama agenda, tanggal mulai, dan tanggal selesai wajib diisi.',
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);
                            try {
                              final dio = ref.read(dioProvider);
                              final List<String> activeGrades = [];
                              if (gradeX) activeGrades.add('X');
                              if (gradeXI) activeGrades.add('XI');
                              if (gradeXII) activeGrades.add('XII');

                              String targetGrade;
                              if (activeGrades.isEmpty || activeGrades.length == 3) {
                                targetGrade = 'SEMUA';
                              } else {
                                targetGrade = activeGrades.join(' + ');
                              }

                              final payload = {
                                'name': name,
                                'type': selectedType,
                                'start_date': start,
                                'end_date': end,
                                'target_grade': targetGrade,
                                'is_holiday': isHoliday,
                              };

                              if (isEdit) {
                                await dio.put('/curriculum/academic-calendars/${item['id']}', data: payload);
                              } else {
                                await dio.post('/curriculum/academic-calendars', data: payload);
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                                AniseFeedbackDialog.showSuccess(
                                  context,
                                  title: isEdit ? 'Agenda Diperbarui' : 'Agenda Ditambahkan',
                                  message: 'Agenda "$name" berhasil disimpan ke kalender akademik.',
                                  onConfirm: onSuccess,
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                AniseFeedbackDialog.showError(
                                  context,
                                  title: 'Gagal Menyimpan',
                                  message: 'Terjadi kesalahan saat menyimpan kalender akademik.',
                                );
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 4. MODAL FORM: HARI LIBUR
  // =========================================================================
  static void showHariLiburForm(
    BuildContext context,
    WidgetRef ref, {
    Map<String, dynamic>? item,
    required VoidCallback onSuccess,
  }) {
    final isEdit = item != null;
    final ketCtrl = TextEditingController(text: item?['name'] ?? item?['description'] ?? '');
    final waktuCtrl = TextEditingController(text: item?['start_date'] ?? '');
    String selectedType = item?['type'] ?? 'SEKOLAH';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24.w(context),
              right: 24.w(context),
              top: 20.h(context),
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w(context),
                      height: 5.h(context),
                      decoration: BoxDecoration(
                        color: AppColors.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h(context)),
                  Text(
                    isEdit ? 'Edit Hari Libur' : 'Tambah Hari Libur Baru',
                    style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16.h(context)),
                  TextField(
                    controller: waktuCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Waktu (DD/MM/YYYY)',
                      hintText: 'Pilih tanggal hari libur',
                      suffixIcon: Icon(PhosphorIcons.calendar()),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(waktuCtrl.text) ?? DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() {
                          waktuCtrl.text = picked.toIso8601String().split('T').first;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 14.h(context)),
                  TextField(
                    controller: ketCtrl,
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      hintText: 'Contoh: Hari Raya Natal / Libur Akhir Semester',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                  ),
                  SizedBox(height: 14.h(context)),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Kategori Hari Libur',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.w(context))),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SEKOLAH', child: Text('Libur Sekolah (Semester / Jeda)')),
                      DropdownMenuItem(value: 'NASIONAL', child: Text('Libur Nasional')),
                      DropdownMenuItem(value: 'CUTI_BERSAMA', child: Text('Cuti Bersama')),
                      DropdownMenuItem(value: 'KHUSUS', child: Text('Libur Khusus / Insidental')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  SizedBox(height: 20.h(context)),
                  AniseButton(
                    text: isEdit ? 'Simpan Hari Libur' : 'Tambah Hari Libur',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final waktu = waktuCtrl.text.trim();
                            final keterangan = ketCtrl.text.trim();
                            if (waktu.isEmpty || keterangan.isEmpty) {
                              AniseFeedbackDialog.showError(
                                context,
                                title: 'Input Tidak Lengkap',
                                message: 'Waktu (tanggal) dan Keterangan hari libur wajib diisi.',
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);
                            try {
                              final dio = ref.read(dioProvider);
                              final payload = {
                                'name': keterangan,
                                'start_date': waktu,
                                'end_date': waktu,
                                'type': selectedType,
                                'description': keterangan,
                              };

                              if (isEdit) {
                                await dio.put('/curriculum/holidays/${item['id']}', data: payload);
                              } else {
                                await dio.post('/curriculum/holidays', data: payload);
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                                AniseFeedbackDialog.showSuccess(
                                  context,
                                  title: isEdit ? 'Hari Libur Diperbarui' : 'Hari Libur Ditambahkan',
                                  message: 'Hari libur "$keterangan" berhasil disimpan.',
                                  onConfirm: onSuccess,
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                AniseFeedbackDialog.showError(
                                  context,
                                  title: 'Gagal Menyimpan',
                                  message: 'Terjadi kesalahan saat menyimpan hari libur.',
                                );
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 5. HELPER WIDGET CHECKBOX TINGKAT
  // =========================================================================
  static Widget _buildGradeCheckbox(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8.w(context)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w(context), vertical: 4.h(context)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              onChanged: onChanged,
            ),
            Text(label, style: AppTextStyles.titleSmall(context, color: AppColors.onSurface)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 6. KONFIRMASI HAPUS DATA
  // =========================================================================
  static void confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String categoryLabel,
    String endpoint,
    String itemId,
    String itemName,
    VoidCallback onSuccess,
  ) async {
    final confirm = await AniseFeedbackDialog.showConfirm(
      context,
      title: 'Hapus $categoryLabel?',
      message: 'Apakah Anda yakin ingin menghapus "$itemName"? Data yang dihapus tidak dapat dipulihkan kembali.',
      confirmText: 'Ya, Hapus Data',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirm != true || !context.mounted) return;

    try {
      final dio = ref.read(dioProvider);
      await dio.delete('$endpoint/$itemId');

      if (context.mounted) {
        AniseFeedbackDialog.showSuccess(
          context,
          title: 'Berhasil Dihapus',
          message: '$categoryLabel "$itemName" berhasil dihapus dari sistem.',
          onConfirm: onSuccess,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Menghapus',
          message: 'Terjadi kesalahan pada server saat menghapus data.',
        );
      }
    }
  }
}
