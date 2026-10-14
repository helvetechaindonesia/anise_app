import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'tu_geofence_settings_screen.dart';
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
  bool _isUploading = false;
  bool _isLoadingData = true;

  List<dynamic> _roles = [];
  List<dynamic> _kelas = [];
  List<dynamic> _jabatans = [];

  final List<Map<String, dynamic>> _categoryOptions = [
    {
      'value': 'Kelas',
      'label': 'Data Kelas / Rombel',
      'icon': PhosphorIcons.chalkboard(PhosphorIconsStyle.bold),
    },
    {
      'value': 'Jabatan',
      'label': 'Data Jabatan Struktural',
      'icon': PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
    },
    {
      'value': 'Role',
      'label': 'Data Role Pengguna',
      'icon': PhosphorIcons.shieldCheck(PhosphorIconsStyle.bold),
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

      setState(() {
        _roles = rolesRes.data['data'] ?? [];
        _kelas = kelasRes.data['data'] ?? [];
        _jabatans = jabatansRes.data['data'] ?? [];
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
        
        setState(() {
          _isUploading = true;
        });
        
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

        setState(() {
          _isUploading = false;
        });
        
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
      setState(() => _isUploading = false);
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
      setState(() => _isUploading = false);
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
    int selectedGrade = int.tryParse(item['grade_level']?.toString() ?? '10') ?? 10;
    
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
        actions: [
          IconButton(
            tooltip: 'Pengaturan Geofence Presensi',
            icon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.bold), color: AppColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TUGeofenceSettingsScreen()));
            },
          ),
        ],
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              _buildFullWidthFilterDropdown(context),
              _buildQuickActionBar(context),
              Expanded(
                child: _buildDataList(context, _selectedCategory),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddModal(context),
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), color: AppColors.onPrimary),
        label: Text('Tambah $_selectedCategory', style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary)),
      ),
    );
  }

  /// Full-width Filter Dropdown (Menggantikan TabBar kaku)
  Widget _buildFullWidthFilterDropdown(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 6.h(context)),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: Icon(
            _selectedCategory == 'Kelas' 
                ? PhosphorIcons.chalkboard(PhosphorIconsStyle.bold)
                : _selectedCategory == 'Jabatan'
                    ? PhosphorIcons.briefcase(PhosphorIconsStyle.bold)
                    : PhosphorIcons.shieldCheck(PhosphorIconsStyle.bold),
            color: AppColors.primary,
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
        icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.6)),
        items: _categoryOptions.map<DropdownMenuItem<String>>((opt) {
          final String val = opt['value'];
          final String label = opt['label'];
          final IconData icon = opt['icon'];
          return DropdownMenuItem<String>(
            value: val,
            child: Row(
              children: [
                Icon(icon, size: 18.w(context), color: AppColors.primary),
                SizedBox(width: 10.w(context)),
                Text(
                  label,
                  style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                    fontWeight: _selectedCategory == val ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
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
    );
  }

  Widget _buildQuickActionBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 4.h(context)),
      child: Row(
        children: [
          Text(
            'Daftar $_selectedCategory',
            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showUploadOptions(context),
            icon: Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
            label: Text('Unggah Excel', style: AppTextStyles.labelMedium(context, color: AppColors.primary)),
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

    if (dataSource.isEmpty) {
      return AniseStateFeedback(
        title: 'Belum Ada Data $type',
        subtitle: type == 'Role' 
            ? 'Role pengguna terisi otomatis oleh sistem.' 
            : 'Tambahkan data $type pertama Anda secara manual atau unggah berkas Excel.',
        icon: type == 'Kelas' ? PhosphorIcons.chalkboard(PhosphorIconsStyle.bold) : PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
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
        return name.contains(searchQuery) || code.contains(searchQuery) || area.contains(searchQuery);
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
}
