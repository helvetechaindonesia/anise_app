import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/tugas_list_tab.dart';
import '../providers/tugas_provider.dart';

class TugasScreen extends ConsumerStatefulWidget {
  const TugasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends ConsumerState<TugasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _dummyTugas = [
    {
      'id': '1',
      'mata_pelajaran': 'Matematika Peminatan',
      'teacher': 'IBU RATNA S.PD',
      'judul': 'Latihan Soal Limit Fungsi Trigonometri',
      'deadline': '25 Okt 2025, 23:59',
      'status': 'Belum Dikerjakan',
      'kategori': 'Tugas Individu',
      'prioritas': 'Tinggi',
    },
    {
      'id': '2',
      'mata_pelajaran': 'Fisika',
      'teacher': 'PAK HARYANTO',
      'judul': 'Laporan Praktikum Gelombang Bunyi',
      'deadline': '26 Okt 2025, 12:00',
      'status': 'Belum Dikerjakan',
      'kategori': 'Tugas Kelompok',
      'prioritas': 'Sedang',
    },
    {
      'id': '3',
      'mata_pelajaran': 'Bahasa Indonesia',
      'teacher': 'PAK BUDI HARTONO',
      'judul': 'Menulis Teks Anekdot',
      'deadline': '20 Okt 2025, 23:59',
      'status': 'Selesai Dikerjakan',
      'kategori': 'Tugas Individu',
      'prioritas': 'Rendah',
      'nilai': 85,
    },
    {
      'id': '4',
      'mata_pelajaran': 'Sejarah Indonesia',
      'teacher': 'IBU SITI AMINAH',
      'judul': 'Resume Perang Diponegoro',
      'deadline': '15 Okt 2025, 23:59',
      'status': 'Terlewat',
      'kategori': 'Tugas Individu',
      'prioritas': 'Tinggi',
    },
  ];

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _years = ['2024', '2025', '2026', '2027'];

  String _selectedMonth = 'Oktober';
  String _selectedYear = '2025';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),
                    _buildHeader(context),
                    SizedBox(height: 24.h(context)),
                    _buildStatsCard(context),
                    SizedBox(height: 24.h(context)),
                    _buildCustomTabBar(context),
                    SizedBox(height: 16.h(context)),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: _buildTabBarView(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView(BuildContext context) {
    final tasksAsync = ref.watch(getTasksProvider);
    
    return tasksAsync.when(
      data: (tasks) {
        final uiTasks = tasks.map((t) => {
          'id': t['id'].toString(),
          'mata_pelajaran': t['subject'] ?? '-',
          'teacher': t['teacher'] ?? '-',
          'judul': t['title'] ?? '-',
          'deadline': t['due_date'] ?? '-',
          'status': 'Belum Dikerjakan', 
          'kategori': 'Tugas',
          'prioritas': 'Tinggi',
        }).toList().cast<Map<String, dynamic>>();

        if (uiTasks.isEmpty) {
          return Center(
            child: Text('Tidak ada tugas untuk saat ini', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)),
          );
        }

        return TabBarView(
          controller: _tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            TugasListTab(status: 'Belum Dikerjakan', allTasks: uiTasks),
            TugasListTab(status: 'Selesai Dikerjakan', allTasks: uiTasks),
            TugasListTab(status: 'Terlewat', allTasks: uiTasks),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, st) => Center(
        child: Text('Gagal memuat data tugas', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
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
                    child: Text('Bulan: $value', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
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
                    });
                  }
                },
                items: _years.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Tahun: $value', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final tasksAsync = ref.watch(getTasksProvider);
    
    return tasksAsync.when(
      data: (tasks) {
        int belum = tasks.length; // For now all are 'Belum' since status isn't fully implemented
        int terlewat = 0; // Calculate later if due_date is passed
        int mingguIni = 0; // Calculate later based on due_date
        
        return Container(
          padding: EdgeInsets.all(20.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(24.w(context)),
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
              _buildStatItem(context, belum.toString(), 'Belum', PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill), AppColors.onPrimaryContainer),
              Container(width: 1, height: 40.h(context), color: AppColors.onPrimaryContainer.withValues(alpha: 0.2)),
              _buildStatItem(context, terlewat.toString(), 'Terlewat', PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), AppColors.error),
              Container(width: 1, height: 40.h(context), color: AppColors.onPrimaryContainer.withValues(alpha: 0.2)),
              _buildStatItem(context, mingguIni.toString(), 'Minggu Ini', PhosphorIcons.calendarCheck(PhosphorIconsStyle.fill), AppColors.onPrimaryContainer),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 100.h(context),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24.w(context)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Container(
        height: 100.h(context),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24.w(context)),
        ),
        child: Center(
          child: Text('Gagal memuat statistik', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24.w(context)),
        SizedBox(height: 8.h(context)),
        Text(
          value,
          style: AppTextStyles.headlineMedium(context, color: AppColors.onPrimaryContainer),
        ),
        SizedBox(height: 2.h(context)),
        Text(
          label,
          style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      height: 46.h(context),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        labelColor: AppColors.surface,
        unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.5),
        labelStyle: AppTextStyles.bodySmall(context),
        unselectedLabelStyle: AppTextStyles.bodySmall(context),
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(100),
        tabs: const [
          Tab(text: 'Belum\nDikerjakan'),
          Tab(text: 'Selesai\nDikerjakan'),
          Tab(text: 'Terlewat'),
        ],
      ),
    );
  }
}


