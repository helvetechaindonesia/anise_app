import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import 'tu_geofence_settings_screen.dart';
import 'tu_hari_nonaktif_settings_screen.dart';
import '../widgets/custom_expandable_fab.dart';
import '../widgets/tu_manajemen_sekolah_dialogs.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_state_feedback.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/responsive.dart';

class TuManajemenSekolahScreen extends ConsumerStatefulWidget {
  const TuManajemenSekolahScreen({super.key});

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

      if (mounted) {
        setState(() {
          _roles = rolesRes.data['data'] ?? [];
          _kelas = kelasRes.data['data'] ?? [];
          _jabatans = jabatansRes.data['data'] ?? [];
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
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

  void _openAddModal() {
    if (_selectedCategory == 'Kelas') {
      TuManajemenSekolahDialogs.showAddKelas(context, ref, _fetchMasterData);
    } else if (_selectedCategory == 'Jabatan') {
      TuManajemenSekolahDialogs.showAddJabatan(context, ref, _fetchMasterData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role pengguna dikelola secara baku oleh sistem.', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
          backgroundColor: AppColors.secondary,
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
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              _buildTopActionButtons(context),
              _buildFullWidthDropdown(context),
              _buildQuickActionBar(context),
              Expanded(
                child: _buildDataContent(context, _selectedCategory),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomExpandableFab(
        onUploadPressed: () {
          TuManajemenSekolahDialogs.showUploadChoices(context, ref, _fetchMasterData);
        },
        onAddPressed: () {
          TuManajemenSekolahDialogs.showAddChoices(
            context,
            onAddKelas: () => TuManajemenSekolahDialogs.showAddKelas(context, ref, _fetchMasterData),
            onAddJabatan: () => TuManajemenSekolahDialogs.showAddJabatan(context, ref, _fetchMasterData),
          );
        },
      ),
    );
  }

  /// 1. Dua Tombol Aksi di Atas Dropdown (Proporsi 50:50 Width)
  Widget _buildTopActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 4.h(context)),
      child: Row(
        children: [
          // Button 1: Setup Lokasi (50% width)
          Expanded(
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
                    SizedBox(width: 8.w(context)),
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
          SizedBox(width: 12.w(context)),

          // Button 2: Hari Nonaktif (50% width)
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TUHariNonaktifSettingsScreen()));
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
                    Icon(PhosphorIcons.calendarSlash(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                    SizedBox(width: 8.w(context)),
                    Flexible(
                      child: Text(
                        'Hari Nonaktif',
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

  /// 2. Dropdown Filter Kategori (FULL WIDTH)
  Widget _buildFullWidthDropdown(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 6.h(context)),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
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
    );
  }

  /// 3. Header Ringkasan Jumlah Data
  Widget _buildQuickActionBar(BuildContext context) {
    String countText = '';
    if (_selectedCategory == 'Kelas') {
      countText = '${_kelas.length} Kelas';
    } else if (_selectedCategory == 'Jabatan') {
      countText = '${_jabatans.length} Jabatan';
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

  /// 4. Search Bar
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

  /// 5. Konten Utama
  Widget _buildDataContent(BuildContext context, String type) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    List<dynamic> dataSource = [];
    if (type == 'Role') {
      dataSource = _roles;
    } else if (type == 'Kelas') {
      dataSource = _kelas;
    } else if (type == 'Jabatan') {
      dataSource = _jabatans;
    }

    String searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      dataSource = dataSource.where((item) {
        String name = (item['name'] ?? '').toString().toLowerCase();
        String code = (item['code'] ?? '').toString().toLowerCase();
        String area = (item['task_area'] ?? '').toString().toLowerCase();
        return name.contains(searchQuery) || 
               code.contains(searchQuery) || 
               area.contains(searchQuery);
      }).toList();
    }

    return ListView(
      padding: EdgeInsets.only(left: 24.w(context), right: 24.w(context), top: 8.h(context), bottom: 90.h(context)),
      children: [
        if (dataSource.isEmpty)
          AniseStateFeedback(
            title: 'Belum Ada Data $type',
            subtitle: type == 'Role' 
                ? 'Role pengguna terisi otomatis oleh sistem.' 
                : 'Tambahkan data $type pertama Anda secara manual atau unggah berkas Excel.',
            icon: type == 'Kelas' 
                ? PhosphorIcons.chalkboard(PhosphorIconsStyle.bold) 
                : PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
            actionButtonText: type == 'Role' ? null : 'Tambah $type Manual',
            onActionPressed: type == 'Role' ? null : _openAddModal,
          )
        else
          ...List.generate(dataSource.length, (index) {
            final item = dataSource[index];
            return _buildStandardItemTile(context, type, item, isLast: index == dataSource.length - 1);
          }),
      ],
    );
  }

  /// 5. Standarisasi Baris Data Menggunakan `ItemListTile` & `Slidable` Swipe
  Widget _buildStandardItemTile(BuildContext context, String type, Map<String, dynamic> item, {required bool isLast}) {
    String category = '';
    String subcategory = '';
    String title = '';
    String metadataText = '';
    IconData metadataIcon = PhosphorIcons.info();
    Color? statusColor;
    String? statusText;
    IconData? statusIcon;

    if (type == 'Kelas') {
      String gradeRaw = item['grade_level']?.toString() ?? '';
      String romanGrade = gradeRaw == '10' ? 'X' : gradeRaw == '11' ? 'XI' : gradeRaw == '12' ? 'XII' : gradeRaw;
      category = 'Rombel Tingkat $romanGrade';
      title = '$romanGrade ${item['name']}';
      metadataIcon = PhosphorIcons.identificationBadge();
      metadataText = 'Kode: ${item['code'] ?? '-'}';
    } else if (type == 'Role') {
      category = 'Hak Akses Sistem';
      title = item['name'] ?? '-';
      metadataIcon = PhosphorIcons.shieldCheck();
      metadataText = (item['is_guru_wali'] == 1 || item['is_guru_wali'] == true) ? 'Akses: Guru Wali' : 'Akses: Standar';
    } else {
      category = 'Struktural Sekolah';
      title = item['name'] ?? '-';
      metadataIcon = PhosphorIcons.tag();
      metadataText = item['task_area'] != null && item['task_area'].toString().isNotEmpty
          ? 'Area: ${item['task_area']}'
          : 'Jabatan Organisasi';
    }

    final canModify = type != 'Role';

    final tile = ItemListTile(
      category: category,
      subcategory: subcategory.isNotEmpty ? subcategory : null,
      title: title,
      metadataIcon: metadataIcon,
      metadataText: metadataText,
      statusIcon: statusIcon,
      statusText: statusText,
      statusColor: statusColor,
      showDivider: !isLast,
      onTap: canModify
          ? () => TuManajemenSekolahDialogs.showEditDialog(context, ref, type, item, _fetchMasterData)
          : null,
      trailing: canModify
          ? PopupMenuButton<String>(
              icon: Icon(
                PhosphorIcons.list(PhosphorIconsStyle.bold), // Hamburger Menu Icon
                color: AppColors.onSurface.withValues(alpha: 0.6),
                size: 22.w(context),
              ),
              color: AppColors.surface,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
              onSelected: (value) {
                if (value == 'edit') {
                  TuManajemenSekolahDialogs.showEditDialog(context, ref, type, item, _fetchMasterData);
                } else if (value == 'delete') {
                  TuManajemenSekolahDialogs.confirmDelete(context, ref, type, item, _fetchMasterData);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                      SizedBox(width: 10.w(context)),
                      Text('Edit', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.error),
                      SizedBox(width: 10.w(context)),
                      Text('Hapus', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );

    if (!canModify) {
      return tile;
    }

    // Swipe Menu untuk Aksi Cepat Edit & Hapus
    return Slidable(
      key: ValueKey(item['id'] ?? title),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.45,
        children: [
          SlidableAction(
            onPressed: (_) => TuManajemenSekolahDialogs.showEditDialog(context, ref, type, item, _fetchMasterData),
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
            label: 'Edit',
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.w(context))),
          ),
          SlidableAction(
            onPressed: (_) => TuManajemenSekolahDialogs.confirmDelete(context, ref, type, item, _fetchMasterData),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
            label: 'Hapus',
            borderRadius: BorderRadius.horizontal(right: Radius.circular(12.w(context))),
          ),
        ],
      ),
      child: tile,
    );
  }
}
