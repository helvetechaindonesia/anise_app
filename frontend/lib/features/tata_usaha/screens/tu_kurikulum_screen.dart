import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_search_bar.dart';
import '../../../core/widgets/anise_dropdown.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../../../core/widgets/anise_slidable_tile.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/network/dio_client.dart';
import '../widgets/custom_expandable_fab.dart';
import '../widgets/tu_kurikulum_dialogs.dart';

class TuKurikulumScreen extends ConsumerStatefulWidget {
  const TuKurikulumScreen({super.key});

  @override
  ConsumerState<TuKurikulumScreen> createState() => _TuKurikulumScreenState();
}

class _TuKurikulumScreenState extends ConsumerState<TuKurikulumScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'wali_kelas';
  bool _isLoading = true;
  List<dynamic> _items = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'wali_kelas',
      'label': 'Wali Kelas',
      'icon': PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.fill),
    },
    {
      'value': 'guru_wali',
      'label': 'Guru Wali (BK / Siswa Asuh)',
      'icon': PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
    },
    {
      'value': 'penugasan',
      'label': 'Penugasan Tambahan',
      'icon': PhosphorIcons.briefcase(PhosphorIconsStyle.fill),
    },
    {
      'value': 'mapel',
      'label': 'Mata Pelajaran (Mapel)',
      'icon': PhosphorIcons.books(PhosphorIconsStyle.fill),
    },
    {
      'value': 'jadwal',
      'label': 'Jadwal KBM',
      'icon': PhosphorIcons.calendar(PhosphorIconsStyle.fill),
    },
    {
      'value': 'kalender_akademik',
      'label': 'Kalender Akademik',
      'icon': PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill),
    },
    {
      'value': 'hari_libur',
      'label': 'Hari Libur Nasional & Sekolah',
      'icon': PhosphorIcons.sun(PhosphorIconsStyle.fill),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getEndpoint(String category) {
    switch (category) {
      case 'wali_kelas':
        return '/curriculum/classes';
      case 'guru_wali':
        return '/curriculum/guru-wali';
      case 'penugasan':
        return '/curriculum/assignments';
      case 'mapel':
        return '/curriculum/subjects';
      case 'jadwal':
        return '/curriculum/schedules';
      case 'kalender_akademik':
        return '/curriculum/academic-calendars';
      case 'hari_libur':
        return '/curriculum/holidays';
      default:
        return '/curriculum/classes';
    }
  }

  List<dynamic> _groupHolidays(List<dynamic> rawHolidays) {
    if (rawHolidays.isEmpty) return [];

    // 1. Kelompokkan data mentah berdasarkan nama/keterangan yang sama
    final Map<String, List<Map<String, dynamic>>> groupedByName = {};

    for (final raw in rawHolidays) {
      if (raw is! Map<String, dynamic>) continue;
      final name = (raw['name'] ?? raw['description'] ?? 'Hari Libur').toString().trim();
      final key = name.toLowerCase();
      groupedByName.putIfAbsent(key, () => []).add(raw);
    }

    final List<Map<String, dynamic>> result = [];

    // 2. Untuk setiap nama, kelompokkan tanggal yang benar-benar berurutan (kontigu)
    // Jika ada gap hari kerja yang bolong (misal 25 Des kosong), maka otomatis terpotong menjadi 2 blok!
    groupedByName.forEach((key, list) {
      if (list.isEmpty) return;

      list.sort((a, b) {
        final dateA = (a['start_date'] ?? '').toString();
        final dateB = (b['start_date'] ?? '').toString();
        return dateA.compareTo(dateB);
      });

      List<Map<String, dynamic>> currentCluster = [];
      DateTime? clusterEnd;

      for (final item in list) {
        final startStr = (item['start_date'] ?? '').toString();
        final endStr = (item['end_date'] ?? item['start_date'] ?? '').toString();
        final startDate = DateTime.tryParse(startStr);
        final endDate = DateTime.tryParse(endStr) ?? startDate;

        if (startDate == null || endDate == null) {
          result.add(item);
          continue;
        }

        if (currentCluster.isEmpty) {
          currentCluster.add(item);
          clusterEnd = endDate;
        } else {
          if (_isContiguous(clusterEnd!, startDate)) {
            // Kontigu: masukkan ke dalam klaster yang sama
            currentCluster.add(item);
            if (endDate.isAfter(clusterEnd)) {
              clusterEnd = endDate;
            }
          } else {
            // Ada gap (hari kerja yang bolong / tidak diisi):
            // Selesaikan klaster saat ini dan mulai klaster baru terpotong
            result.add(_buildClusteredItem(currentCluster));
            currentCluster = [item];
            clusterEnd = endDate;
          }
        }
      }

      if (currentCluster.isNotEmpty) {
        result.add(_buildClusteredItem(currentCluster));
      }
    });

    // 3. Urutkan seluruh grup berdasarkan tanggal mulai
    result.sort((a, b) {
      final dateA = (a['start_date'] ?? '').toString();
      final dateB = (b['start_date'] ?? '').toString();
      return dateA.compareTo(dateB);
    });

    return result;
  }

  bool _isContiguous(DateTime end, DateTime nextStart) {
    final diff = nextStart.difference(end).inDays;
    if (diff <= 1) return true; // Hari yang sama atau hari berikutnya persis

    // Jika selisih lebih dari 1 hari, periksa apakah hari di antaranya hanya weekend (Sabtu/Minggu)
    DateTime cursor = end.add(const Duration(days: 1));
    while (cursor.isBefore(nextStart)) {
      if (cursor.weekday != DateTime.saturday && cursor.weekday != DateTime.sunday) {
        return false; // Ada hari kerja (Senin-Jumat) yang bolong!
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return true; // Hanya terlewati akhir pekan
  }

  Map<String, dynamic> _buildClusteredItem(List<Map<String, dynamic>> list) {
    final first = list.first;
    final last = list.last;

    final minStart = first['start_date']?.toString() ?? '';
    final maxEnd = (last['end_date'] ?? last['start_date'])?.toString() ?? minStart;
    final allIds = list.map((e) => e['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();

    return {
      'id': first['id'],
      'ids': allIds,
      'name': first['name'] ?? first['description'] ?? 'Hari Libur',
      'start_date': minStart,
      'end_date': maxEnd,
      'description': first['description'],
      'type': first['type'] ?? 'LIBUR',
      'total_entries': list.length,
      'raw_items': list,
    };
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = ref.read(dioProvider);
      final endpoint = _getEndpoint(_selectedCategory);
      final response = await dio.get(endpoint);

      if (mounted) {
        final rawData = response.data['data'] as List<dynamic>? ?? [];
        setState(() {
          _items = _selectedCategory == 'hari_libur'
              ? _groupHolidays(rawData)
              : rawData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getFilteredItems() {
    if (_searchQuery.trim().isEmpty) return _items;

    final q = _searchQuery.toLowerCase();
    return _items.where((item) {
      if (_selectedCategory == 'wali_kelas') {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final wali = (item['wali_kelas']?['full_name'] ?? '').toString().toLowerCase();
        final code = (item['code'] ?? '').toString().toLowerCase();
        return name.contains(q) || wali.contains(q) || code.contains(q);
      } else if (_selectedCategory == 'guru_wali') {
        final student = (item['student']?['full_name'] ?? '').toString().toLowerCase();
        final guru = (item['guru']?['full_name'] ?? '').toString().toLowerCase();
        return student.contains(q) || guru.contains(q);
      } else if (_selectedCategory == 'penugasan') {
        final guru = (item['guru']?['full_name'] ?? '').toString().toLowerCase();
        final jabatan = (item['jabatan']?['name'] ?? '').toString().toLowerCase();
        return guru.contains(q) || jabatan.contains(q);
      } else if (_selectedCategory == 'mapel') {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final code = (item['code'] ?? '').toString().toLowerCase();
        return name.contains(q) || code.contains(q);
      } else if (_selectedCategory == 'jadwal') {
        final subject = (item['subject']?['name'] ?? item['activity_name'] ?? '').toString().toLowerCase();
        final teacher = (item['teacher']?['full_name'] ?? '').toString().toLowerCase();
        final className = (item['class']?['name'] ?? '').toString().toLowerCase();
        final day = (item['day_of_week'] ?? '').toString().toLowerCase();
        return subject.contains(q) || teacher.contains(q) || className.contains(q) || day.contains(q);
      } else if (_selectedCategory == 'kalender_akademik') {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final start = (item['start_date'] ?? '').toString().toLowerCase();
        return name.contains(q) || start.contains(q);
      } else if (_selectedCategory == 'hari_libur') {
        final name = (item['name'] ?? '').toString().toLowerCase();
        final start = (item['start_date'] ?? '').toString().toLowerCase();
        final end = (item['end_date'] ?? '').toString().toLowerCase();
        final desc = (item['description'] ?? '').toString().toLowerCase();
        return name.contains(q) || start.contains(q) || end.contains(q) || desc.contains(q);
      }
      return false;
    }).toList();
  }

  void _handleManualAdd() {
    TuKurikulumDialogs.showManualAddChoiceSheet(context, ref, _fetchData);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredItems();
    final categoryMeta = _categories.firstWhere(
      (c) => c['value'] == _selectedCategory,
      orElse: () => _categories.first,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Kurikulum',
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 1. Search Bar Terstandarisasi
              AniseSearchBar(
                controller: _searchController,
                hintText: 'Cari data ${categoryMeta['label']}...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),

              // 2. Dropdown Kategori Terstandarisasi
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
                child: AniseDropdown<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat['value'] as String,
                      child: Row(
                        children: [
                          Icon(cat['icon'] as IconData, size: 18.w(context), color: AppColors.primary),
                          SizedBox(width: 10.w(context)),
                          Expanded(
                            child: Text(
                              cat['label'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleSmall(context, color: AppColors.onSurface),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newVal) {
                    if (newVal != null && newVal != _selectedCategory) {
                      setState(() {
                        _selectedCategory = newVal;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                      _fetchData();
                    }
                  },
                ),
              ),

              // 3. List Data Terstandarisasi dengan Pull-To-Refresh
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        color: AppColors.primary,
                        child: filtered.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(height: 60.h(context)),
                                  AniseEmptyState(
                                    title: 'Belum Ada Data ${categoryMeta['label']}',
                                    subtitle: _searchQuery.isNotEmpty
                                        ? 'Tidak ditemukan data yang cocok dengan kata kunci "$_searchQuery".'
                                        : 'Master data untuk kategori ini belum tersedia atau disinkronkan.',
                                  ),
                                ],
                              )
                            : ListView.separated(
                                padding: EdgeInsets.only(
                                  left: 24.w(context),
                                  right: 24.w(context),
                                  top: 8.h(context),
                                  bottom: 100.h(context),
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
                                itemBuilder: (context, index) {
                                  final item = filtered[index];
                                  final isLast = index == filtered.length - 1;
                                  return _buildItemRow(context, item, categoryMeta['label'] as String, isLast);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomExpandableFab(
        onUploadPressed: () {
          TuKurikulumDialogs.showUploadSheet(context, ref, _fetchData);
        },
        onAddPressed: _handleManualAdd,
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, Map<String, dynamic> item, String categoryLabel, bool isLast) {
    String title = '';
    String subtitle = '';
    String? detail;
    IconData icon = PhosphorIcons.file();
    IconData? secondaryIcon;

    VoidCallback? onEdit;
    VoidCallback? onDelete;

    if (_selectedCategory == 'wali_kelas') {
      title = 'Kelas ${item['name'] ?? '-'}';
      final waliName = item['wali_kelas']?['full_name'];
      subtitle = 'Wali: ${waliName ?? 'Belum Ditentukan'}';
      detail = 'Kode: ${item['code'] ?? '-'} • Jurusan: ${item['major']?['name'] ?? 'Umum'}';
      icon = PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.fill);
    } else if (_selectedCategory == 'guru_wali') {
      title = item['student']?['full_name'] ?? '-';
      subtitle = 'Guru Wali: ${item['guru']?['full_name'] ?? '-'}';
      detail = 'Tahun Ajaran: ${item['academic_year']?['name'] ?? '-'}';
      icon = PhosphorIcons.usersThree(PhosphorIconsStyle.fill);
      onDelete = () {
        TuKurikulumDialogs.confirmDelete(
          context,
          ref,
          'Guru Wali',
          '/curriculum/guru-wali',
          item['id'].toString(),
          title,
          _fetchData,
        );
      };
    } else if (_selectedCategory == 'penugasan') {
      title = item['guru']?['full_name'] ?? '-';
      subtitle = 'Jabatan: ${item['jabatan']?['name'] ?? '-'}';
      detail = 'Tahun: ${item['academic_year']?['name'] ?? '-'}';
      icon = PhosphorIcons.briefcase(PhosphorIconsStyle.fill);
      onDelete = () {
        TuKurikulumDialogs.confirmDelete(
          context,
          ref,
          'Penugasan',
          '/curriculum/assignments',
          item['id'].toString(),
          title,
          _fetchData,
        );
      };
    } else if (_selectedCategory == 'mapel') {
      title = item['name'] ?? '-';
      subtitle = 'Kode: ${item['code'] ?? '-'}';
      detail = 'KKM Kelulusan: ${item['passing_grade'] ?? '75'}';
      icon = PhosphorIcons.books(PhosphorIconsStyle.fill);
      onDelete = () {
        TuKurikulumDialogs.confirmDelete(
          context,
          ref,
          'Mata Pelajaran',
          '/curriculum/subjects',
          item['id'].toString(),
          title,
          _fetchData,
        );
      };
    } else if (_selectedCategory == 'jadwal') {
      final subjectName = item['subject']?['name'] ?? item['activity_name'] ?? 'Kegiatan';
      final className = item['class']?['name'] ?? '';
      title = '$subjectName ($className)';
      final day = item['day_of_week'] ?? '';
      final start = item['start_time'] ?? '';
      final end = item['end_time'] ?? '';
      subtitle = '$day • $start - $end';
      detail = 'Guru: ${item['teacher']?['full_name'] ?? 'Tanpa Guru'}';
      icon = PhosphorIcons.calendar(PhosphorIconsStyle.fill);
      onDelete = () {
        TuKurikulumDialogs.confirmDelete(
          context,
          ref,
          'Jadwal KBM',
          '/curriculum/schedules',
          item['id'].toString(),
          title,
          _fetchData,
        );
      };
    } else if (_selectedCategory == 'kalender_akademik') {
      title = item['name'] ?? '-';
      final type = item['type'] ?? 'KEGIATAN';
      final grade = item['target_grade'] ?? 'SEMUA';
      final isHoli = item['is_holiday'] == true;
      detail = 'Jenis: $type • Tingkat: $grade${isHoli ? ' • 🔴 Libur Presensi' : ''}';
      icon = PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill);
      onEdit = () {
        TuKurikulumDialogs.showKalenderAkademikForm(context, ref, item: item, onSuccess: _fetchData);
      };
      onDelete = () {
        TuKurikulumDialogs.confirmDelete(
          context,
          ref,
          'Kalender Akademik',
          '/curriculum/academic-calendars',
          item['id'].toString(),
          title,
          _fetchData,
        );
      };
    } else if (_selectedCategory == 'hari_libur') {
      title = item['name'] ?? '-';
      final start = item['start_date'] ?? '';
      final end = item['end_date'] ?? '';
      final totalEntries = item['total_entries'] as int? ?? 1;

      if (start == end || end.isEmpty) {
        subtitle = 'Tanggal: $start';
        icon = PhosphorIcons.calendar(PhosphorIconsStyle.fill);
        detail = item['description'] ?? 'Hari Libur Operasional';
        secondaryIcon = PhosphorIcons.sun(PhosphorIconsStyle.fill);
      } else {
        subtitle = 'Mulai: $start';
        icon = PhosphorIcons.calendarPlus(PhosphorIconsStyle.fill);
        detail = 'Selesai: $end${totalEntries > 1 ? ' ($totalEntries hari libur)' : ''}';
        secondaryIcon = PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill);
      }
      onEdit = () {
        TuKurikulumDialogs.showHariLiburForm(context, ref, item: item, onSuccess: _fetchData);
      };
      onDelete = () {
        final ids = (item['ids'] as List<dynamic>?)?.map((e) => e.toString()).toList();
        TuKurikulumDialogs.confirmDelete(
          context,
          ref,
          'Hari Libur',
          '/curriculum/holidays',
          item['id'].toString(),
          title,
          _fetchData,
          itemIds: ids,
        );
      };
    }

    final hasAction = onEdit != null || onDelete != null;

    final tile = ItemListTile(
      category: categoryLabel,
      title: title,
      metadataIcon: icon,
      metadataText: subtitle,
      secondaryMetadataIcon: secondaryIcon,
      secondaryMetadataText: detail,
      showDivider: !isLast,
      trailing: hasAction
          ? PopupMenuButton<String>(
              icon: Icon(
                PhosphorIcons.list(PhosphorIconsStyle.bold),
                color: AppColors.onSurface.withValues(alpha: 0.6),
                size: 22.w(context),
              ),
              color: AppColors.surface,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) {
                  onEdit();
                } else if (value == 'delete' && onDelete != null) {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.warning),
                        SizedBox(width: 10.w(context)),
                        Text('Edit', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                if (onDelete != null)
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

    if (!hasAction) {
      return tile;
    }

    return AniseSlidableTile(
      key: ValueKey(item['id'] ?? title),
      onEdit: onEdit,
      onDelete: onDelete,
      child: tile,
    );
  }
}
