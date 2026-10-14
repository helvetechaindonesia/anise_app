import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'tu_geofence_settings_screen.dart';
import '../widgets/custom_expandable_fab.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_state_feedback.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/responsive.dart';

class TuManajemenSekolahScreen extends ConsumerStatefulWidget {
  const TuManajemenSekolahScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TuManajemenSekolahScreen> createState() => _TuManajemenSekolahScreenState();
}

class _TuManajemenSekolahScreenState extends ConsumerState<TuManajemenSekolahScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Kelas'; // Default ke 'Kelas'
  bool _isLoadingData = true;

  List<dynamic> _roles = [];
  List<dynamic> _kelas = [];
  List<dynamic> _jabatans = [];
  List<dynamic> _holidays = [];

  final List<Map<String, dynamic>> _categoryOptions = [
    {
      'value': 'Kelas',
      'label': 'Kelas / Rombel',
    },
    {
      'value': 'Jabatan',
      'label': 'Jabatan Struktural',
    },
    {
      'value': 'Hari Libur',
      'label': 'Hari Libur',
    },
    {
      'value': 'Role',
      'label': 'Role Pengguna',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMasterData();
    });
  }

  Future<void> _fetchMasterData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final dio = ref.read(dioProvider);
      
      final rolesRes = await dio.get('/master/roles');
      final kelasRes = await dio.get('/master/kelas');
      final jabatansRes = await dio.get('/master/jabatans');
      
      dynamic holidaysData = [];
      try {
        final holidaysRes = await dio.get('/master/holidays');
        holidaysData = holidaysRes.data['data'] ?? [];
      } catch (_) {}

      setState(() {
        _roles = rolesRes.data['data'] ?? [];
        _kelas = kelasRes.data['data'] ?? [];
        _jabatans = jabatansRes.data['data'] ?? [];
        _holidays = holidaysData;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data master: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================================
  // EXCEL PICKER & UPLOAD
  // =========================================================================
  Future<void> _pickExcelFile(String title) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        PlatformFile picked = result.files.first;
        String fileName = picked.name;
        String filePath = picked.path!;
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
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

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (response.statusCode == 200 || response.statusCode == 201) {
            String message = response.data['message'] ?? 'Data berhasil disimpan!';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message, style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                backgroundColor: AppColors.success,
              ),
            );
            _fetchMasterData();
          }
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        String errorMsg = e.response?.data is Map && e.response?.data['message'] != null
            ? e.response?.data['message']
            : (e.message ?? 'Gagal mengunggah berkas');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal unggah: $errorMsg', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // =========================================================================
  // TAMBAH DATA MANUAL BOTTOM SHEET
  // =========================================================================
  void _openAddModal(BuildContext context) {
    if (_selectedCategory == 'Kelas') {
      _showAddKelasModal(context);
    } else if (_selectedCategory == 'Jabatan') {
      _showAddJabatanModal(context);
    } else if (_selectedCategory == 'Hari Libur') {
      _showAddHolidayModal(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role pengguna dikelola secara baku oleh sistem.', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  void _showAddKelasModal(BuildContext context) {
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

                // Tingkat Kelas
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

                // Nama Rombel
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

                // Live Preview Badge
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

                // Tombol Simpan
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

                            if (mounted) {
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Kelas $previewName berhasil ditambahkan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _fetchMasterData();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
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

  void _showAddJabatanModal(BuildContext context) {
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

                            if (mounted) {
                              Navigator.pop(sheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Jabatan $rawName berhasil ditambahkan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _fetchMasterData();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
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

  void _showAddHolidayModal(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    String selectedType = 'NASIONAL';
    bool isSubmitting = false;

    final typeOptions = [
      {'val': 'NASIONAL', 'label': 'Nasional'},
      {'val': 'SEKOLAH', 'label': 'Sekolah'},
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
                      Text('Tambah Hari Libur', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                    ],
                  ),
                  SizedBox(height: 16.h(context)),

                  // Nama Hari Libur
                  Text('Nama Hari Libur / Agenda:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Libur Hari Raya Idul Fitri',
                      prefixIcon: Icon(PhosphorIcons.calendarPlus(PhosphorIconsStyle.bold), color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Jenis Libur
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

                  // Rentang Tanggal
                  Text('Rentang Tanggal:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  Row(
                    children: [
                      // Tanggal Mulai
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
                      // Tanggal Selesai
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

                  // Preview Durasi
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

                  // Keterangan / Deskripsi
                  Text('Keterangan (Opsional):', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 8.h(context)),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Berdasarkan SKB 3 Menteri atau Kalender Pendidikan',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 24.h(context)),
                        child: Icon(PhosphorIcons.note(PhosphorIconsStyle.bold), color: AppColors.primary),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    ),
                  ),
                  SizedBox(height: 24.h(context)),

                  // Tombol Simpan
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

                              if (mounted) {
                                Navigator.pop(sheetContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Hari libur "$rawName" berhasil ditambahkan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                _fetchMasterData();
                              }
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                              if (mounted) {
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
  // EDIT & DELETE ACTIONS (SUNTING DATA)
  // =========================================================================
  void _confirmDelete(BuildContext context, String type, Map<String, dynamic> item) {
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$type "$itemName" berhasil dihapus', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _fetchMasterData();
                  }
                }
              } catch (e) {
                if (mounted) {
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

  void _showEditDialog(BuildContext context, String type, Map<String, dynamic> item) {
    final TextEditingController nameController = TextEditingController(text: item['name'] ?? '');
    final TextEditingController areaController = TextEditingController(text: item['task_area'] ?? '');
    final TextEditingController descController = TextEditingController(text: item['description'] ?? '');
    int selectedGrade = int.tryParse(item['grade_level']?.toString() ?? '10') ?? 10;
    DateTime editStartDate = DateTime.tryParse(item['start_date']?.toString() ?? '') ?? DateTime.now();
    DateTime editEndDate = DateTime.tryParse(item['end_date']?.toString() ?? '') ?? DateTime.now();
    String editHolidayType = item['type']?.toString() ?? 'NASIONAL';

    final holidayTypes = [
      {'val': 'NASIONAL', 'label': 'Nasional'},
      {'val': 'SEKOLAH', 'label': 'Sekolah'},
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
                      
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data $type berhasil diperbarui', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)), backgroundColor: AppColors.success),
                        );
                        _fetchMasterData();
                      }
                    } catch (e) {
                      setEditState(() => isSaving = false);
                      if (mounted) {
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
  // BUILD METHOD & UI
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manajemen Sekolah',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              _buildFilterAndLocationBar(context),
              _buildQuickActionBar(context),
              Expanded(
                child: _buildDataList(context, _selectedCategory),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomExpandableFab(
        onUploadPressed: () {
          _showUploadOptions(context);
        },
        onAddPressed: () {
          _showAddOptions(context);
        },
      ),
    );
  }

  /// Baris Filter Kategori (2/3 width) & Tombol Setup Lokasi (1/3 width)
  Widget _buildFilterAndLocationBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 6.h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Dropdown Filter Kategori (2/3 width)
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 14.h(context)),
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: Icon(
                  _selectedCategory == 'Kelas' 
                      ? PhosphorIcons.chalkboard(PhosphorIconsStyle.bold)
                      : _selectedCategory == 'Jabatan'
                          ? PhosphorIcons.briefcase(PhosphorIconsStyle.bold)
                          : _selectedCategory == 'Hari Libur'
                              ? PhosphorIcons.calendarX(PhosphorIconsStyle.bold)
                              : PhosphorIcons.shieldCheck(PhosphorIconsStyle.bold),
                  color: AppColors.primary,
                  size: 20.w(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w(context)),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w(context)),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.w(context)),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
              dropdownColor: AppColors.surface,
              icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onSurface.withValues(alpha: 0.6)),
              items: _categoryOptions.map<DropdownMenuItem<String>>((opt) {
                final String val = opt['value'];
                final String label = opt['label'];
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                      fontWeight: _selectedCategory == val ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null && newValue != _selectedCategory) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
          SizedBox(width: 10.w(context)),

          // 2. Tombol Setup Lokasi / Geofence (1/3 width)
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TUGeofenceSettingsScreen()));
              },
              borderRadius: BorderRadius.circular(16.w(context)),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h(context), horizontal: 8.w(context)),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                    SizedBox(width: 6.w(context)),
                    Flexible(
                      child: Text(
                        'Lokasi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall(context, color: AppColors.primary).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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

  Widget _buildQuickActionBar(BuildContext context) {
    String countText = '';
    if (_selectedCategory == 'Kelas') {
      countText = '${_kelas.length} Kelas';
    } else if (_selectedCategory == 'Jabatan') {
      countText = '${_jabatans.length} Jabatan';
    } else if (_selectedCategory == 'Hari Libur') {
      countText = '${_holidays.length} Hari Libur';
    } else {
      countText = '${_roles.length} Role';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 4.h(context)),
      child: Row(
        children: [
          Text(
            'Daftar Data $_selectedCategory',
            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.w(context)),
            ),
            child: Text(
              countText,
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.onSurface.withValues(alpha: 0.5)),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari data $_selectedCategory...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), size: 18.w(context), color: AppColors.onSurface.withValues(alpha: 0.4)),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataList(BuildContext context, String type) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    List<dynamic> dataSource = [];
    if (type == 'Role') dataSource = _roles;
    else if (type == 'Kelas') dataSource = _kelas;
    else if (type == 'Jabatan') dataSource = _jabatans;
    else if (type == 'Hari Libur') dataSource = _holidays;

    if (dataSource.isEmpty) {
      return AniseStateFeedback(
        title: 'Belum Ada Data $type',
        subtitle: type == 'Role' 
            ? 'Role pengguna terisi otomatis oleh sistem.' 
            : 'Tambahkan data $type pertama Anda secara manual.',
        icon: type == 'Kelas' 
            ? PhosphorIcons.chalkboard(PhosphorIconsStyle.bold) 
            : type == 'Hari Libur'
                ? PhosphorIcons.calendarX(PhosphorIconsStyle.bold)
                : PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
        actionButtonText: type == 'Role' ? null : 'Tambah $type Manual',
        onActionPressed: type == 'Role' ? null : () => _openAddModal(context),
      );
    }

    String searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      dataSource = dataSource.where((item) {
        String name = (item['name'] ?? '').toString().toLowerCase();
        String code = (item['code'] ?? '').toString().toLowerCase();
        String area = (item['task_area'] ?? '').toString().toLowerCase();
        String hType = (item['type'] ?? '').toString().toLowerCase();
        String desc = (item['description'] ?? '').toString().toLowerCase();
        String sDate = (item['start_date'] ?? '').toString().toLowerCase();
        String eDate = (item['end_date'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery) || 
               code.contains(searchQuery) || 
               area.contains(searchQuery) ||
               hType.contains(searchQuery) ||
               desc.contains(searchQuery) ||
               sDate.contains(searchQuery) ||
               eDate.contains(searchQuery);
      }).toList();
    }

    if (dataSource.isEmpty) {
      return Center(
        child: Text('Tidak ditemukan hasil untuk pencarian ini.', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(left: 24.w(context), right: 24.w(context), top: 8.h(context), bottom: 90.h(context)),
      itemCount: dataSource.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h(context)),
      itemBuilder: (context, index) {
        final item = dataSource[index];
        IconData itemIcon;
        String titlePrefix = '';
        String subtitle = '';

        if (type == 'Kelas') {
          itemIcon = PhosphorIcons.chalkboard();
          String gradeRaw = item['grade_level']?.toString() ?? '';
          String romanGrade = gradeRaw == '10' ? 'X' : gradeRaw == '11' ? 'XI' : gradeRaw == '12' ? 'XII' : gradeRaw;
          titlePrefix = '$romanGrade ${item['name']}';
          subtitle = 'Kode Rombel: ${item['code'] ?? '-'}';
        } else if (type == 'Role') {
          itemIcon = PhosphorIcons.shieldCheck();
          titlePrefix = item['name'] ?? '-';
          subtitle = (item['is_guru_wali'] == 1 || item['is_guru_wali'] == true) ? 'Hak Akses: Guru Wali' : 'Hak Akses: Standar';
        } else if (type == 'Hari Libur') {
          itemIcon = PhosphorIcons.calendarX();
          titlePrefix = item['name'] ?? '-';
          final sDateStr = item['start_date']?.toString() ?? '';
          final eDateStr = item['end_date']?.toString() ?? '';
          DateTime? sDate = DateTime.tryParse(sDateStr);
          DateTime? eDate = DateTime.tryParse(eDateStr);
          String dateLabel = '';
          if (sDate != null && eDate != null) {
            if (sDateStr == eDateStr) {
              dateLabel = DateFormat('dd MMM yyyy', 'id_ID').format(sDate);
            } else {
              dateLabel = '${DateFormat('dd MMM', 'id_ID').format(sDate)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(eDate)}';
            }
          } else {
            dateLabel = '$sDateStr s/d $eDateStr';
          }
          final hType = (item['type'] ?? 'NASIONAL').toString().replaceAll('_', ' ');
          final desc = (item['description'] ?? '').toString().trim();
          subtitle = desc.isNotEmpty ? '$dateLabel • $hType\n$desc' : '$dateLabel • $hType';
        } else {
          itemIcon = PhosphorIcons.briefcase();
          titlePrefix = item['name'] ?? '-';
          subtitle = item['task_area'] != null && item['task_area'].toString().isNotEmpty
              ? 'Area Tugas: ${item['task_area']}' 
              : 'Struktural Sekolah';
        }

        final canModify = type != 'Role';

        return Slidable(
          key: ValueKey(item['id'] ?? index),
          endActionPane: canModify
              ? ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (ctx) => _showEditDialog(context, type, item),
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
                      label: 'Sunting',
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16.w(context)), bottomLeft: Radius.circular(16.w(context))),
                    ),
                    SlidableAction(
                      onPressed: (ctx) => _confirmDelete(context, type, item),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
                      label: 'Hapus',
                      borderRadius: BorderRadius.only(topRight: Radius.circular(16.w(context)), bottomRight: Radius.circular(16.w(context))),
                    ),
                  ],
                )
              : null,
          child: Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Icon(itemIcon, color: AppColors.primary, size: 24.w(context)),
                ),
                SizedBox(width: 16.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titlePrefix,
                        style: AppTextStyles.titleSmall(context, color: AppColors.onSurface),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                if (canModify) ...[
                  // Tombol Sunting Cepat (Sesuai gaya Manajemen User)
                  InkWell(
                    onTap: () => _showEditDialog(context, type, item),
                    borderRadius: BorderRadius.circular(8.w(context)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.w(context)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.primary),
                          SizedBox(width: 4.w(context)),
                          Text(
                            'Sunting',
                            style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.onSurface.withValues(alpha: 0.5)),
                    color: AppColors.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context, type, item);
                      } else if (value == 'delete') {
                        _confirmDelete(context, type, item);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.pencilSimple(), size: 18.w(context), color: AppColors.onSurface),
                            SizedBox(width: 8.w(context)),
                            Text('Sunting Data', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.trash(), size: 18.w(context), color: AppColors.error),
                            SizedBox(width: 8.w(context)),
                            Text('Hapus', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            _buildUploadOption(context, 'Master Role', PhosphorIcons.shieldCheck()),
            _buildUploadOption(context, 'Master Kelas', PhosphorIcons.chalkboard()),
            _buildUploadOption(context, 'Master Jabatan', PhosphorIcons.briefcase()),
            SizedBox(height: 12.h(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(BuildContext context, String title, IconData icon) {
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
      onTap: () {
        Navigator.pop(context);
        _pickExcelFile(title);
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            _buildAddOption(
              context,
              'Tambah Kelas / Rombel',
              PhosphorIcons.chalkboard(PhosphorIconsStyle.bold),
              () => _showAddKelasModal(context),
            ),
            _buildAddOption(
              context,
              'Tambah Jabatan Struktural',
              PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
              () => _showAddJabatanModal(context),
            ),
            _buildAddOption(
              context,
              'Tambah Hari Libur',
              PhosphorIcons.calendarX(PhosphorIconsStyle.bold),
              () => _showAddHolidayModal(context),
            ),
            SizedBox(height: 12.h(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(BuildContext context, String title, IconData icon, VoidCallback onSelected) {
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
      onTap: () {
        Navigator.pop(context);
        onSelected();
      },
    );
  }
}
