import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/anise_insight_card.dart';
import '../../../core/widgets/anise_time_filter_dropdowns.dart';
import '../../../core/widgets/anise_capsule_tab_bar.dart';
import '../widgets/tugas_list_tab.dart';
import '../providers/tugas_provider.dart';

class TugasScreen extends ConsumerStatefulWidget {
  const TugasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends ConsumerState<TugasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static final DateTime _releaseDate = ApiConstants.appReleaseDate; // 26 Oktober 2026

  List<String> get _years {
    final currentYear = DateTime.now().year;
    final releaseYear = _releaseDate.year;
    final maxYear = currentYear >= releaseYear ? currentYear + 1 : releaseYear + 1;
    final List<String> list = ['Semua Tahun'];
    for (int y = releaseYear; y <= maxYear; y++) {
      list.add(y.toString());
    }
    return list;
  }

  List<String> get _months {
    const allMonths = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final List<String> list = ['Semua Bulan'];
    if (_selectedYear == _releaseDate.year.toString()) {
      // Tidak boleh memilih bulan sebelum rilis aplikasi (Oktober 2026)
      list.addAll(allMonths.sublist(_releaseDate.month - 1));
    } else {
      list.addAll(allMonths);
    }
    return list;
  }

  late String _selectedMonth;
  late String _selectedYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _selectedYear = 'Semua Tahun';
    _selectedMonth = 'Semua Bulan';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterTasks(List<dynamic> rawTasks) {
    final uiTasks = rawTasks.map((t) {
      final taskMap = t is Map ? t : {};
      final String id = taskMap['id']?.toString() ?? '';
      final String subject = taskMap['subject']?.toString() ?? 'Mata Pelajaran';
      final String teacher = taskMap['teacher']?.toString() ?? 'Guru';
      final String title = taskMap['title']?.toString() ?? 'Tugas';
      final String dueDate = taskMap['due_date_formatted']?.toString() ?? taskMap['due_date']?.toString() ?? '-';
      final String rawDueDate = taskMap['due_date']?.toString() ?? '';
      final String status = taskMap['status']?.toString() ?? (taskMap['is_submitted'] == true ? 'Selesai Dikerjakan' : 'Belum Dikerjakan');
      final String description = taskMap['description']?.toString() ?? '';
      final Map<String, dynamic>? submission = taskMap['submission'] as Map<String, dynamic>?;
      final List<dynamic>? attachments = taskMap['attachments'] as List<dynamic>?;
      final dynamic score = submission != null ? submission['score'] : null;

      return {
        'id': id,
        'mata_pelajaran': subject,
        'teacher': teacher,
        'judul': title,
        'deadline': dueDate,
        'raw_due_date': rawDueDate,
        'status': status,
        'description': description,
        'submission': submission,
        'attachments': attachments,
        'nilai': score != null ? (score as num).toInt() : null,
      };
    }).toList();

    // Filter by Month and Year
    return uiTasks.where((task) {
      final rawDueDate = task['raw_due_date']?.toString() ?? '';
      if (rawDueDate.isEmpty) return true;

      final parsed = DateTime.tryParse(rawDueDate);
      if (parsed == null) return true;

      if (_selectedYear != 'Semua Tahun' && parsed.year.toString() != _selectedYear) {
        return false;
      }

      if (_selectedMonth != 'Semua Bulan') {
        const allCalendarMonths = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        final calMonthIndex = allCalendarMonths.indexOf(_selectedMonth) + 1;
        if (calMonthIndex > 0 && parsed.month != calMonthIndex) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(getTasksProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(getTasksProvider);
          },
          child: tasksAsync.when(
            data: (rawTasks) {
              final filteredTasks = _filterTasks(rawTasks);

              final belumCount = filteredTasks.where((t) => t['status'] == 'Belum Dikerjakan').length;
              final selesaiCount = filteredTasks.where((t) => t['status'] == 'Selesai Dikerjakan').length;
              final terlewatCount = filteredTasks.where((t) => t['status'] == 'Terlewat').length;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    _buildAppBar(context),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h(context)),

                          // 1. Standarisasi Filter Waktu (Dropdown Bulan & Tahun)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                            child: AniseTimeFilterDropdowns(
                              selectedMonth: _selectedMonth,
                              selectedYear: _selectedYear,
                              months: _months,
                              years: _years,
                              onMonthChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedMonth = newValue;
                                  });
                                }
                              },
                              onYearChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedYear = newValue;
                                    if (!_months.contains(_selectedMonth)) {
                                      _selectedMonth = 'Semua Bulan';
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 16.h(context)),

                          // 2. Standarisasi Card Insight Metrik
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                            child: AniseInsightCard(
                              items: [
                                AniseInsightItemData(
                                  label: 'Belum',
                                  value: belumCount.toString(),
                                  icon: PhosphorIcons.hourglass(PhosphorIconsStyle.fill),
                                  color: const Color(0xFFF59E0B),
                                ),
                                AniseInsightItemData(
                                  label: 'Selesai',
                                  value: selesaiCount.toString(),
                                  icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                                  color: AppColors.secondary,
                                ),
                                AniseInsightItemData(
                                  label: 'Terlewat',
                                  value: terlewatCount.toString(),
                                  icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                                  color: const Color(0xFFEF4444),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h(context)),

                          // 3. Standarisasi Filter Jenis (Capsule Tab Bar)
                          AniseCapsuleTabBar(
                            controller: _tabController,
                            tabTitles: const ['Belum', 'Selesai', 'Terlewat'],
                          ),
                          SizedBox(height: 16.h(context)),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    TugasListTab(status: 'Belum Dikerjakan', allTasks: filteredTasks),
                    TugasListTab(status: 'Selesai Dikerjakan', allTasks: filteredTasks),
                    TugasListTab(status: 'Terlewat', allTasks: filteredTasks),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (e, st) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), size: 48.w(context), color: AppColors.error),
                  SizedBox(height: 12.h(context)),
                  Text('Gagal memuat daftar tugas', style: AppTextStyles.titleMedium(context, color: AppColors.error)),
                  SizedBox(height: 8.h(context)),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(getTasksProvider),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Tugas & Evaluasi',
        style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
      ),
    );
  }
}
