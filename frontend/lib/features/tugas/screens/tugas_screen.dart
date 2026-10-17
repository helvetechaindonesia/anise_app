import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/api_constants.dart';
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.h(context)),
                            _buildHeader(context),
                            SizedBox(height: 20.h(context)),
                            _buildStatsCard(context, belumCount: belumCount, selesaiCount: selesaiCount, terlewatCount: terlewatCount),
                            SizedBox(height: 20.h(context)),
                            _buildCustomTabBar(context, belumCount: belumCount, selesaiCount: selesaiCount, terlewatCount: terlewatCount),
                            SizedBox(height: 16.h(context)),
                          ],
                        ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 2.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedMonth,
                isExpanded: true,
                icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMonth = newValue;
                    });
                  }
                },
                items: _months.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 2.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYear,
                isExpanded: true,
                icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
                dropdownColor: AppColors.surface,
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedYear = newValue;
                      if (!_months.contains(_selectedMonth)) {
                        _selectedMonth = 'Semua Bulan';
                      }
                    });
                  }
                },
                items: _years.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context, {required int belumCount, required int selesaiCount, required int terlewatCount}) {
    return Container(
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, belumCount.toString(), 'Belum', PhosphorIcons.hourglass(PhosphorIconsStyle.fill), AppColors.onPrimaryContainer),
          Container(width: 1, height: 36.h(context), color: AppColors.onPrimaryContainer.withValues(alpha: 0.2)),
          _buildStatItem(context, selesaiCount.toString(), 'Selesai', PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), AppColors.secondary),
          Container(width: 1, height: 36.h(context), color: AppColors.onPrimaryContainer.withValues(alpha: 0.2)),
          _buildStatItem(context, terlewatCount.toString(), 'Terlewat', PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), AppColors.error),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22.w(context)),
        SizedBox(height: 6.h(context)),
        Text(
          value,
          style: AppTextStyles.headlineMedium(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 2.h(context)),
        Text(
          label,
          style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar(BuildContext context, {required int belumCount, required int selesaiCount, required int terlewatCount}) {
    return Container(
      height: 44.h(context),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        labelColor: AppColors.surface,
        unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.6),
        labelStyle: AppTextStyles.labelMedium(context).copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.labelMedium(context),
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(100),
        tabs: const [
          Tab(text: 'Belum'),
          Tab(text: 'Selesai'),
          Tab(text: 'Terlewat'),
        ],
      ),
    );
  }
}
