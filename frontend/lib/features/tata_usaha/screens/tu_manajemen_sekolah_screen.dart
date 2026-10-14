import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import 'tu_geofence_settings_screen.dart';
import '../widgets/custom_expandable_fab.dart';
import '../widgets/school_off_days_card.dart';
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
      'label': 'Hari Libur & Operasional',
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

      if (mounted) {
        setState(() {
          _roles = rolesRes.data['data'] ?? [];
          _kelas = kelasRes.data['data'] ?? [];
          _jabatans = jabatansRes.data['data'] ?? [];
          _holidays = holidaysData;
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
    } else if (_selectedCategory == 'Hari Libur') {
      TuManajemenSekolahDialogs.showAddHoliday(context, ref, _fetchMasterData);
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
              _buildFilterAndLocationBar(context),
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
            onAddHoliday: () => TuManajemenSekolahDialogs.showAddHoliday(context, ref, _fetchMasterData),
          );
        },
      ),
    );
  }

  /// 1. Dropdown Filter Kategori (2/3 width) & Tombol Setup Lokasi (1/3 width)
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

  /// 2. Header Ringkasan Jumlah Data
  Widget _buildQuickActionBar(BuildContext context) {
    String countText = '';
    if (_selectedCategory == 'Kelas') {
      countText = '${_kelas.length} Kelas';
    } else if (_selectedCategory == 'Jabatan') {
      countText = '${_jabatans.length} Jabatan';
    } else if (_selectedCategory == 'Hari Libur') {
      countText = '${_holidays.length} Hari Libur Khusus';
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

  /// 3. Search Bar
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

  /// 4. Konten Utama (Jika Hari Libur: Tampilkan SchoolOffDaysCard di atas, lalu list)
  Widget _buildDataContent(BuildContext context, String type) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    List<dynamic> dataSource = [];
    if (type == 'Role') dataSource = _roles;
    else if (type == 'Kelas') dataSource = _kelas;
    else if (type == 'Jabatan') dataSource = _jabatans;
    else if (type == 'Hari Libur') dataSource = _holidays;

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

    return ListView(
      padding: EdgeInsets.only(left: 24.w(context), right: 24.w(context), top: 8.h(context), bottom: 90.h(context)),
      children: [
        // Khusus Kategori Hari Libur: Tampilkan Card Pengaturan Hari Libur Rutin Mingguan
        if (type == 'Hari Libur') ...[
          SchoolOffDaysCard(
            onSaved: _fetchMasterData,
          ),
          SizedBox(height: 16.h(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w(context)),
            child: Text(
              'Kalender Libur Khusus / Tambahan:',
              style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 8.h(context)),
        ],

        if (dataSource.isEmpty)
          AniseStateFeedback(
            title: 'Belum Ada Data $type',
            subtitle: type == 'Role' 
                ? 'Role pengguna terisi otomatis oleh sistem.' 
                : 'Tambahkan data $type pertama Anda secara manual atau unggah berkas Excel.',
            icon: type == 'Kelas' 
                ? PhosphorIcons.chalkboard(PhosphorIconsStyle.bold) 
                : type == 'Hari Libur'
                    ? PhosphorIcons.calendarX(PhosphorIconsStyle.bold)
                    : PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
            actionButtonText: type == 'Role' ? null : 'Tambah $type Manual',
            onActionPressed: type == 'Role' ? null : _openAddModal,
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 8.h(context)),
            child: Column(
              children: List.generate(dataSource.length, (index) {
                final item = dataSource[index];
                return _buildStandardItemTile(context, type, item, isLast: index == dataSource.length - 1);
              }),
            ),
          ),
      ],
    );
  }

  /// 5. Standarisasi Baris Data Menggunakan `ItemListTile` (Model B: Minimal Flat Tile with Divider)
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
    } else if (type == 'Hari Libur') {
      final hType = (item['type'] ?? 'SEKOLAH').toString().replaceAll('_', ' ');
      category = 'Kalender Libur • $hType';
      title = item['name'] ?? '-';
      
      final sDateStr = item['start_date']?.toString() ?? '';
      final eDateStr = item['end_date']?.toString() ?? '';
      DateTime? sDate = DateTime.tryParse(sDateStr);
      DateTime? eDate = DateTime.tryParse(eDateStr);
      if (sDate != null && eDate != null) {
        if (sDateStr == eDateStr) {
          metadataText = DateFormat('dd MMM yyyy', 'id_ID').format(sDate);
        } else {
          metadataText = '${DateFormat('dd MMM', 'id_ID').format(sDate)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(eDate)}';
        }
      } else {
        metadataText = '$sDateStr s/d $eDateStr';
      }
      metadataIcon = PhosphorIcons.calendarBlank();

      if (item['description'] != null && item['description'].toString().trim().isNotEmpty) {
        statusText = item['description'].toString().trim();
        statusIcon = PhosphorIcons.note();
        statusColor = AppColors.onSurface.withValues(alpha: 0.6);
      }
    } else {
      category = 'Struktural Sekolah';
      title = item['name'] ?? '-';
      metadataIcon = PhosphorIcons.tag();
      metadataText = item['task_area'] != null && item['task_area'].toString().isNotEmpty
          ? 'Area: ${item['task_area']}'
          : 'Jabatan Organisasi';
    }

    final canModify = type != 'Role';

    return ItemListTile(
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
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Sunting Cepat
                InkWell(
                  onTap: () => TuManajemenSekolahDialogs.showEditDialog(context, ref, type, item, _fetchMasterData),
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
                SizedBox(width: 4.w(context)),

                // Popup Aksi (Hapus)
                PopupMenuButton<String>(
                  icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.onSurface.withValues(alpha: 0.5)),
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
            )
          : null,
    );
  }
}
