import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_button.dart';

class TuManajemenSekolahDialogs {
  // =========================================================================
  // 1. ADD KELAS MODAL
  // =========================================================================
  static void showAddKelas(BuildContext context, WidgetRef ref, VoidCallback onSuccess) {
    final nameController = TextEditingController();
    int selectedGrade = 10;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final roman = selectedGrade == 10 ? 'X' : selectedGrade == 11 ? 'XI' : 'XII';
          final previewName = nameController.text.trim().isEmpty 
              ? '$roman [Nama Rombel]' 
              : '$roman ${nameController.text.trim().toUpperCase()}';

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
                Row(
                  children: [
                    Icon(PhosphorIcons.chalkboard(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),
                    SizedBox(width: 10.w(context)),
                    Text('Tambah Kelas Baru (Rombel)', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                  ],
                ),
                SizedBox(height: 16.h(context)),

                Text('Pilih Tingkat Kelas:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                SizedBox(height: 8.h(context)),
                Row(
                  children: [10, 11, 12].map((grade) {
                    final isSelected = selectedGrade == grade;
                    final gradeRoman = grade == 10 ? 'Kelas X' : grade == 11 ? 'Kelas XI' : 'Kelas XII';
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w(context)),
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              gradeRoman,
                              style: AppTextStyles.labelMedium(context, color: isSelected ? AppColors.onPrimary : AppColors.onSurface),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedGrade = grade);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h(context)),

                Text('Nama Rombel / Jurusan:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                SizedBox(height: 8.h(context)),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Contoh: RPL 1, MIPA 2, TKJ 1',
                    prefixIcon: Icon(PhosphorIcons.identificationBadge(PhosphorIconsStyle.bold), color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                  ),
                ),
                SizedBox(height: 14.h(context)),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 10.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.primary, size: 18.w(context)),
                      SizedBox(width: 8.w(context)),
                      Expanded(
                        child: Text(
                          'Nama Resmi di Sistem: $previewName',
                          style: AppTextStyles.bodySmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h(context)),

                AniseButton(
                  text: 'Simpan Kelas',
                  isLoading: isSubmitting,
                  icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final rawName = nameController.text.trim();
                          if (rawName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nama Rombel wajib diisi!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);
                          try {
                            final dio = ref.read(dioProvider);
                            await dio.post('/master/kelas', data: {
                              'grade_level': selectedGrade.toString(),
                              'name': rawName.toUpperCase(),
                            });

                            if (context.mounted) {
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kelas $previewName berhasil ditambahkan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              onSuccess();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan kelas: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 2. ADD JABATAN MODAL
  // =========================================================================
  static void showAddJabatan(BuildContext context, WidgetRef ref, VoidCallback onSuccess) {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
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
                Row(
                  children: [
                    Icon(PhosphorIcons.briefcase(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),
                    SizedBox(width: 10.w(context)),
                    Text('Tambah Jabatan Struktural', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                  ],
                ),
                SizedBox(height: 16.h(context)),

                Text('Nama Jabatan:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                SizedBox(height: 8.h(context)),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Contoh: KAPROGLI, WAKASEK_HUBIN',
                    prefixIcon: Icon(PhosphorIcons.identificationBadge(PhosphorIconsStyle.bold), color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                  ),
                ),
                SizedBox(height: 16.h(context)),

                Text('Area Tugas / Keterangan:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                SizedBox(height: 8.h(context)),
                TextField(
                  controller: areaController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Hubungan Industri dan BKK',
                    prefixIcon: Icon(PhosphorIcons.tag(PhosphorIconsStyle.bold), color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                  ),
                ),
                SizedBox(height: 24.h(context)),

                AniseButton(
                  text: 'Simpan Jabatan',
                  isLoading: isSubmitting,
                  icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final rawName = nameController.text.trim();
                          if (rawName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nama jabatan wajib diisi!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);
                          try {
                            final dio = ref.read(dioProvider);
                            await dio.post('/master/jabatans', data: {
                              'name': rawName,
                              'task_area': areaController.text.trim(),
                            });

                            if (context.mounted) {
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Jabatan $rawName berhasil ditambahkan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              onSuccess();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan jabatan: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // 3. ADD HOLIDAY MODAL
  // =========================================================================
  static void showAddHoliday(BuildContext context, WidgetRef ref, VoidCallback onSuccess) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    String selectedType = 'SEKOLAH';
    bool isSubmitting = false;

    final typeOptions = [
      {'val': 'SEKOLAH', 'label': 'Sekolah'},
      {'val': 'NASIONAL', 'label': 'Nasional'},
      {'val': 'CUTI_BERSAMA', 'label': 'Cuti Bersama'},
      {'val': 'KHUSUS', 'label': 'Khusus'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final sDateStr = DateFormat('dd MMM yyyy', 'id_ID').format(startDate);
          final eDateStr = DateFormat('dd MMM yyyy', 'id_ID').format(endDate);
          final durationDays = endDate.difference(startDate).inDays + 1;

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
                  Row(
                    children: [
                      Icon(PhosphorIcons.calendarX(PhosphorIconsStyle.bold), color: AppColors.primary, size: 24.w(context)),
                      SizedBox(width: 10.w(context)),
                      Text('Tambah Libur Kalender Sekolah', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                    ],
                  ),
                  SizedBox(height: 16.h(context)),

                  Text('Nama Hari Libur / Agenda:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Libur Akhir Semester Ganjil',
                      prefixIcon: Icon(PhosphorIcons.calendarPlus(PhosphorIconsStyle.bold), color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  Text('Tipe Hari Libur:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  Wrap(
                    spacing: 8.w(context),
                    runSpacing: 8.h(context),
                    children: typeOptions.map((opt) {
                      final isSelected = selectedType == opt['val'];
                      return ChoiceChip(
                        label: Text(
                          opt['label']!,
                          style: AppTextStyles.labelMedium(context, color: isSelected ? AppColors.onPrimary : AppColors.onSurface),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedType = opt['val']!);
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h(context)),

                  Text('Rentang Tanggal:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setModalState(() {
                                startDate = picked;
                                if (endDate.isBefore(startDate)) {
                                  endDate = startDate;
                                }
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12.w(context)),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 12.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12.w(context)),
                              border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mulai', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5))),
                                SizedBox(height: 4.h(context)),
                                Row(
                                  children: [
                                    Icon(PhosphorIcons.calendarBlank(), size: 16.w(context), color: AppColors.primary),
                                    SizedBox(width: 6.w(context)),
                                    Expanded(
                                      child: Text(
                                        sDateStr,
                                        style: AppTextStyles.bodySmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w(context)),
                        child: Icon(PhosphorIcons.arrowRight(), size: 16.w(context), color: AppColors.onSurface.withValues(alpha: 0.4)),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate.isBefore(startDate) ? startDate : endDate,
                              firstDate: startDate,
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setModalState(() {
                                endDate = picked;
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12.w(context)),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 12.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12.w(context)),
                              border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selesai', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5))),
                                SizedBox(height: 4.h(context)),
                                Row(
                                  children: [
                                    Icon(PhosphorIcons.calendarCheck(), size: 16.w(context), color: AppColors.primary),
                                    SizedBox(width: 6.w(context)),
                                    Expanded(
                                      child: Text(
                                        eDateStr,
                                        style: AppTextStyles.bodySmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h(context)),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10.w(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.clock(PhosphorIconsStyle.fill), color: AppColors.primary, size: 16.w(context)),
                        SizedBox(width: 8.w(context)),
                        Text(
                          'Total durasi: $durationDays hari libur',
                          style: AppTextStyles.bodySmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  Text('Keterangan (Opsional):', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Berdasarkan Kalender Akademik Sekolah',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 24.h(context)),
                        child: Icon(PhosphorIcons.note(PhosphorIconsStyle.bold), color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    ),
                  ),
                  SizedBox(height: 24.h(context)),

                  AniseButton(
                    text: 'Simpan Hari Libur',
                    isLoading: isSubmitting,
                    icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final rawName = nameController.text.trim();
                            if (rawName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nama hari libur wajib diisi!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);
                            try {
                              final dio = ref.read(dioProvider);
                              await dio.post('/master/holidays', data: {
                                'name': rawName,
                                'type': selectedType,
                                'start_date': DateFormat('yyyy-MM-dd').format(startDate),
                                'end_date': DateFormat('yyyy-MM-dd').format(endDate),
                                'description': descController.text.trim().isEmpty ? null : descController.text.trim(),
                              });

                              if (context.mounted) {
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hari libur "$rawName" berhasil ditambahkan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                onSuccess();
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal menyimpan hari libur: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                    backgroundColor: AppColors.error,
                                  ),
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
  // 4. EDIT MASTER DIALOG
  // =========================================================================
  static void showEditDialog(BuildContext context, WidgetRef ref, String type, Map<String, dynamic> item, VoidCallback onSuccess) {
    final TextEditingController nameController = TextEditingController(text: item['name'] ?? '');
    final TextEditingController areaController = TextEditingController(text: item['task_area'] ?? '');
    final TextEditingController descController = TextEditingController(text: item['description'] ?? '');
    int selectedGrade = int.tryParse(item['grade_level']?.toString() ?? '10') ?? 10;
    DateTime editStartDate = DateTime.tryParse(item['start_date']?.toString() ?? '') ?? DateTime.now();
    DateTime editEndDate = DateTime.tryParse(item['end_date']?.toString() ?? '') ?? DateTime.now();
    String editHolidayType = item['type']?.toString() ?? 'SEKOLAH';

    final holidayTypes = [
      {'val': 'SEKOLAH', 'label': 'Sekolah'},
      {'val': 'NASIONAL', 'label': 'Nasional'},
      {'val': 'CUTI_BERSAMA', 'label': 'Cuti Bersama'},
      {'val': 'KHUSUS', 'label': 'Khusus'},
    ];
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setEditState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
              title: Row(
                children: [
                  Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 22.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text('Sunting Data $type', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (type == 'Kelas') ...[
                      Text('Tingkat Kelas:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                      SizedBox(height: 8.h(context)),
                      Row(
                        children: [10, 11, 12].map((grade) {
                          final isSelected = selectedGrade == grade;
                          final gradeRoman = grade == 10 ? 'X' : grade == 11 ? 'XI' : 'XII';
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w(context)),
                              child: ChoiceChip(
                                label: Text(gradeRoman, style: AppTextStyles.labelSmall(context, color: isSelected ? AppColors.onPrimary : AppColors.onSurface)),
                                selected: isSelected,
                                selectedColor: AppColors.primary,
                                onSelected: (val) {
                                  if (val) setEditState(() => selectedGrade = grade);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 12.h(context)),
                    ],
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama $type',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      ),
                    ),
                    if (type == 'Jabatan') ...[
                      SizedBox(height: 12.h(context)),
                      TextField(
                        controller: areaController,
                        decoration: InputDecoration(
                          labelText: 'Area Tugas',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                        ),
                      ),
                    ],
                    if (type == 'Hari Libur') ...[
                      SizedBox(height: 14.h(context)),
                      Text('Tipe Libur:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                      SizedBox(height: 6.h(context)),
                      Wrap(
                        spacing: 6.w(context),
                        runSpacing: 6.h(context),
                        children: holidayTypes.map((opt) {
                          final isSelected = editHolidayType == opt['val'];
                          return ChoiceChip(
                            label: Text(opt['label']!, style: AppTextStyles.labelSmall(context, color: isSelected ? AppColors.onPrimary : AppColors.onSurface)),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            onSelected: (val) {
                              if (val) setEditState(() => editHolidayType = opt['val']!);
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 14.h(context)),
                      Text('Rentang Tanggal:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                      SizedBox(height: 6.h(context)),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: editStartDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setEditState(() {
                                    editStartDate = picked;
                                    if (editEndDate.isBefore(editStartDate)) {
                                      editEndDate = editStartDate;
                                    }
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(10.w(context)),
                              child: Container(
                                padding: EdgeInsets.all(10.w(context)),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(10.w(context)),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy', 'id_ID').format(editStartDate),
                                  style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w(context)),
                            child: Icon(PhosphorIcons.arrowRight(), size: 14.w(context), color: AppColors.onSurface.withValues(alpha: 0.5)),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: editEndDate.isBefore(editStartDate) ? editStartDate : editEndDate,
                                  firstDate: editStartDate,
                                  lastDate: DateTime(2035),
                                );
                                if (picked != null) {
                                  setEditState(() {
                                    editEndDate = picked;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(10.w(context)),
                              child: Container(
                                padding: EdgeInsets.all(10.w(context)),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(10.w(context)),
                                ),
                                child: Text(
                                  DateFormat('dd MMM yyyy', 'id_ID').format(editEndDate),
                                  style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h(context)),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Keterangan (Opsional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setEditState(() => isSaving = true);
                    try {
                      final dio = ref.read(dioProvider);
                      String endpoint = '';
                      Map<String, dynamic> payload = {'name': nameController.text.trim()};
                      
                      if (type == 'Role') {
                        endpoint = '/master/roles/${item['id']}';
                      } else if (type == 'Kelas') {
                        endpoint = '/master/kelas/${item['id']}';
                        payload['grade_level'] = selectedGrade.toString();
                      } else if (type == 'Jabatan') {
                        endpoint = '/master/jabatans/${item['id']}';
                        payload['task_area'] = areaController.text.trim();
                      } else if (type == 'Hari Libur') {
                        endpoint = '/master/holidays/${item['id']}';
                        payload = {
                          'name': nameController.text.trim(),
                          'type': editHolidayType,
                          'start_date': DateFormat('yyyy-MM-dd').format(editStartDate),
                          'end_date': DateFormat('yyyy-MM-dd').format(editEndDate),
                          'description': descController.text.trim().isEmpty ? null : descController.text.trim(),
                        };
                      }

                      await dio.put(endpoint, data: payload);
                      
                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data $type berhasil diperbarui', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)), backgroundColor: AppColors.success),
                        );
                        onSuccess();
                      }
                    } catch (e) {
                      setEditState(() => isSaving = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memperbarui: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
                  ),
                  child: isSaving 
                    ? SizedBox(width: 16.w(context), height: 16.w(context), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Simpan Perubahan', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary)),
                ),
              ],
            );
          },
        );
      }
    );
  }

  // =========================================================================
  // 5. CONFIRM DELETE DIALOG
  // =========================================================================
  static void confirmDelete(BuildContext context, WidgetRef ref, String type, Map<String, dynamic> item, VoidCallback onSuccess) {
    final itemName = item['name'] ?? 'Data';
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
        title: Row(
          children: [
            Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 24.w(context)),
            SizedBox(width: 10.w(context)),
            Text('Hapus $type?', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus $type "$itemName"? Tindakan ini tidak dapat dibatalkan.',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Batal', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final dio = ref.read(dioProvider);
                String endpoint = '';
                if (type == 'Kelas') endpoint = '/master/kelas/${item['id']}';
                else if (type == 'Jabatan') endpoint = '/master/jabatans/${item['id']}';
                else if (type == 'Hari Libur') endpoint = '/master/holidays/${item['id']}';

                if (endpoint.isNotEmpty) {
                  await dio.delete(endpoint);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type "$itemName" berhasil dihapus', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    onSuccess();
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus $type: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
            ),
            child: Text('Ya, Hapus', style: AppTextStyles.labelMedium(context, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 6. FAB ADD CHOICES BOTTOM SHEET
  // =========================================================================
  static void showAddChoices(
    BuildContext context, {
    required VoidCallback onAddKelas,
    required VoidCallback onAddJabatan,
    required VoidCallback onAddHoliday,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w(context),
                height: 5.h(context),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h(context)),
            Text(
              'Tambah Data Master',
              style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 6.h(context)),
            Text(
              'Pilih jenis data yang ingin ditambahkan secara manual:',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 16.h(context)),
            _buildChoiceTile(
              context,
              'Tambah Kelas / Rombel',
              PhosphorIcons.chalkboard(PhosphorIconsStyle.bold),
              () {
                Navigator.pop(ctx);
                onAddKelas();
              },
            ),
            _buildChoiceTile(
              context,
              'Tambah Jabatan Struktural',
              PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
              () {
                Navigator.pop(ctx);
                onAddJabatan();
              },
            ),
            _buildChoiceTile(
              context,
              'Tambah Libur Kalender Sekolah',
              PhosphorIcons.calendarX(PhosphorIconsStyle.bold),
              () {
                Navigator.pop(ctx);
                onAddHoliday();
              },
            ),
            SizedBox(height: 12.h(context)),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 7. EXCEL UPLOAD CHOICES BOTTOM SHEET
  // =========================================================================
  static void showUploadChoices(
    BuildContext context,
    WidgetRef ref,
    VoidCallback onUploaded,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w(context),
                height: 5.h(context),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h(context)),
            Text(
              'Unggah Berkas Excel',
              style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 6.h(context)),
            Text(
              'Pilih jenis data yang ingin diunggah secara kolektif:',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 16.h(context)),
            _buildChoiceTile(
              context,
              'Master Role',
              PhosphorIcons.shieldCheck(),
              () {
                Navigator.pop(ctx);
                _pickAndUploadExcel(context, ref, 'Master Role', onUploaded);
              },
            ),
            _buildChoiceTile(
              context,
              'Master Kelas',
              PhosphorIcons.chalkboard(),
              () {
                Navigator.pop(ctx);
                _pickAndUploadExcel(context, ref, 'Master Kelas', onUploaded);
              },
            ),
            _buildChoiceTile(
              context,
              'Master Jabatan',
              PhosphorIcons.briefcase(),
              () {
                Navigator.pop(ctx);
                _pickAndUploadExcel(context, ref, 'Master Jabatan', onUploaded);
              },
            ),
            SizedBox(height: 12.h(context)),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickAndUploadExcel(
    BuildContext context,
    WidgetRef ref,
    String title,
    VoidCallback onUploaded,
  ) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        PlatformFile picked = result.files.first;
        String fileName = picked.name;
        String filePath = picked.path!;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Mengunggah berkas $fileName...', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary))),
                ],
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(days: 1),
            ),
          );
        }

        String endpoint = '';
        if (title == 'Master Kelas') endpoint = '/parse/master-kelas';
        else if (title == 'Master Role') endpoint = '/parse/master-role';
        else if (title == 'Master Jabatan') endpoint = '/parse/master-jabatan';

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final dio = ref.read(dioProvider);
        final response = await dio.post(endpoint, data: formData);

        if (context.mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (response.statusCode == 200 || response.statusCode == 201) {
            String message = response.data['message'] ?? 'Data berhasil disimpan!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message, style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                backgroundColor: AppColors.success,
              ),
            );
            onUploaded();
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal unggah: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static Widget _buildChoiceTile(BuildContext context, String title, IconData icon, VoidCallback onSelected) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.w(context)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.w(context)),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.3), size: 16.w(context)),
      contentPadding: EdgeInsets.zero,
      onTap: onSelected,
    );
  }
}
