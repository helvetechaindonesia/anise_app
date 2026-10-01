import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'tu_geofence_settings_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/network/dio_client.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TuManajemenSekolahScreen extends ConsumerStatefulWidget {
  const TuManajemenSekolahScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TuManajemenSekolahScreen> createState() => _TuManajemenSekolahScreenState();
}

class _TuManajemenSekolahScreenState extends ConsumerState<TuManajemenSekolahScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isUploading = false;
  bool _isLoadingData = true;

  List<dynamic> _roles = [];
  List<dynamic> _kelas = [];
  List<dynamic> _jabatans = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          SnackBar(content: Text('Gagal memuat data master: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile(String title) async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.path != null) {
        String fileName = result.name;
        String filePath = result.path!;
        
        setState(() {
          _isUploading = true;
        });
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(child: Text('Mengunggah dan membaca file $fileName...', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary))),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(days: 1), // Biarkan terbuka selama upload
          ),
        );

        String endpoint = '';
        if (title == 'Master Kelas') endpoint = '/parse/master-kelas';
        else if (title == 'Master Role') endpoint = '/parse/master-role';
        else if (title == 'Master Jabatan') endpoint = '/parse/master-jabatan';

        if (endpoint.isEmpty) {
            throw Exception('Endpoint belum tersedia untuk $title');
        }

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final dio = ref.read(dioProvider);
        final response = await dio.post(endpoint, data: formData);

        setState(() {
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (response.statusCode == 200) {
           String message = response.data['message'] ?? 'Data berhasil disimpan!';
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(message, style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
               backgroundColor: AppColors.success,
             ),
           );

           // Auto-refresh the data list
           _fetchMasterData();
        }

      }
    } on DioException catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      String errorMsg = e.message ?? 'Unknown error';
      if (e.response != null) {
          if (e.response?.data is Map && e.response?.data['message'] != null) {
              errorMsg = e.response?.data['message'];
          } else {
              errorMsg = 'Status: ${e.response?.statusCode}';
          }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal unggah: $errorMsg', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

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
              _buildTabBar(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDataList(context, 'Role'),
                    _buildDataList(context, 'Kelas'),
                    _buildDataList(context, 'Jabatan'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUploadOptions(context);
        },
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.upload(PhosphorIconsStyle.bold), color: AppColors.onPrimary),
        label: Text('Upload Excel', style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary)),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Manajemen Sekolah',
              style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih jenis data wadah yang ingin diupload.',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            _buildUploadOption(context, 'Master Role', PhosphorIcons.shieldCheck()),
            _buildUploadOption(context, 'Master Kelas', PhosphorIcons.chalkboard()),
            _buildUploadOption(context, 'Master Jabatan', PhosphorIcons.briefcase()),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.3)),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.pop(context);
        _pickExcelFile(title);
      },
    );
  }



  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
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
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari data...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.onPrimary,
        unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
        labelStyle: AppTextStyles.labelMedium(context),
        unselectedLabelStyle: AppTextStyles.labelMedium(context),
        tabs: const [
          Tab(text: 'Role'),
          Tab(text: 'Kelas'),
          Tab(text: 'Jabatan'),
        ],
      ),
    );
  }

  Widget _buildDataList(BuildContext context, String type) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    List<dynamic> dataSource = [];
    if (type == 'Role') dataSource = _roles;
    else if (type == 'Kelas') dataSource = _kelas;
    else if (type == 'Jabatan') dataSource = _jabatans;

    if (dataSource.isEmpty) {
      return Center(
        child: Text('Belum ada data $type', style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
      );
    }

    String searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      dataSource = dataSource.where((item) {
        String name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    }

    if (dataSource.isEmpty) {
      return Center(
        child: Text('Tidak ditemukan hasil untuk pencarian ini.', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
      itemCount: dataSource.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
          subtitle = 'Kode: ${item['code'] ?? '-'}';
        } else if (type == 'Role') {
          itemIcon = PhosphorIcons.shieldCheck();
          titlePrefix = item['name'] ?? '-';
          subtitle = (item['is_guru_wali'] == 1 || item['is_guru_wali'] == true) ? 'Dapat menjadi Guru Wali' : 'Bukan Guru Wali';
        } else {
          itemIcon = PhosphorIcons.briefcase();
          titlePrefix = item['name'] ?? '-';
          subtitle = item['task_area'] != null ? 'Area Tugas: ${item['task_area']}' : 'Tidak ada area tugas';
        }

        return Slidable(
          key: ValueKey(item['id'] ?? index),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  _showEditDialog(context, type, item);
                },
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
                label: 'Edit',
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: AppColors.menuPastelBlue,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.snowflake(PhosphorIconsStyle.fill),
                label: 'Freeze',
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
                label: 'Hapus',
                borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(itemIcon, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titlePrefix,
                        style: AppTextStyles.titleSmall(context, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.onSurface.withValues(alpha: 0.5)),
                  color: AppColors.surface,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditDialog(context, type, item);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.pencilSimple(), size: 18, color: AppColors.onSurface),
                          const SizedBox(width: 8),
                          Text('Edit', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'freeze',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.snowflake(), size: 18, color: AppColors.menuPastelBlue),
                          const SizedBox(width: 8),
                          Text('Freeze', style: AppTextStyles.bodyMedium(context, color: AppColors.menuPastelBlue)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.trash(), size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Hapus', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String type, Map<String, dynamic> item) {
    final TextEditingController nameController = TextEditingController(text: item['name'] ?? '');
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit $type', style: AppTextStyles.titleMedium(context)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama $type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setState(() => isSaving = true);
                    try {
                      final dio = ref.read(dioProvider);
                      String endpoint = '';
                      if (type == 'Role') endpoint = '/master/roles/${item['id']}';
                      else if (type == 'Kelas') endpoint = '/master/kelas/${item['id']}';
                      else if (type == 'Jabatan') endpoint = '/master/jabatans/${item['id']}';

                      await dio.put(endpoint, data: {'name': nameController.text});
                      
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$type berhasil diperbarui'), backgroundColor: AppColors.success),
                        );
                        _fetchMasterData(); // Refresh list
                      }
                    } catch (e) {
                      setState(() => isSaving = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memperbarui data'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    );
  }
}
