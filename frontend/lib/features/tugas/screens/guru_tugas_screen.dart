import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import 'guru_tugas_penilaian_screen.dart';
import 'guru_input_tugas_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tugas_provider.dart';

class GuruTugasScreen extends ConsumerStatefulWidget {
  const GuruTugasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GuruTugasScreen> createState() => _GuruTugasScreenState();
}

class _GuruTugasScreenState extends ConsumerState<GuruTugasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manajemen Tugas',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuruInputTugasScreen()),
              );
            },
            icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacing.custom(context, 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
            child: Row(
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
            ),
          ),
          Spacing.custom(context, 24),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTugasList(context, isActive: true),
                _buildTugasList(context, isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
      child: Container(
        height: 46.h(context),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(24.w(context)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24.w(context)),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onBackground.withValues(alpha: 0.6),
          labelStyle: AppTextStyles.labelLarge(context).copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: AppTextStyles.labelLarge(context),
          tabs: const [
            Tab(text: 'Tugas Aktif'),
            Tab(text: 'Tugas Selesai'),
          ],
        ),
      ),
    );
  }

  Widget _buildTugasList(BuildContext context, {required bool isActive}) {
    final tasksAsync = ref.watch(getTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        // Filter out active vs completed
        // For now, let's say a task is active if due_date is in the future.
        final now = DateTime.now();
        final filteredTasks = tasks.where((t) {
          final due = DateTime.parse(t['due_date']);
          if (isActive) {
            return due.isAfter(now);
          } else {
            return due.isBefore(now);
          }
        }).toList();

        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), color: AppColors.onBackground.withValues(alpha: 0.2), size: 64.w(context)),
                SizedBox(height: 16.h(context)),
                Text(
                  isActive ? 'Tidak ada tugas aktif' : 'Tidak ada tugas selesai',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  'Buat tugas baru menggunakan tombol + di pojok kanan atas.',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final colors = [AppColors.menuPastelPurple, AppColors.menuPastelBlue, AppColors.menuPastelGreen, AppColors.menuPastelBlue];

        return ListView.builder(
          padding: EdgeInsets.only(top: 24.h(context), bottom: 40.h(context), left: 24.w(context), right: 24.w(context)),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final item = filteredTasks[index];
            final mappedItem = {
              'id': item['id'],
              'title': item['title'],
              'subject': item['subject_name'],
              'class': item['class_name'],
              'deadline': item['due_date'],
              'submitted': item['submitted_count'],
              'total': item['total_students'],
              'color': colors[index % colors.length],
            };
            return _buildGuruTugasCard(context, mappedItem, isActive);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Gagal memuat tugas: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildGuruTugasCard(BuildContext context, Map<String, dynamic> data, bool isActive) {
    final submitted = data['submitted'] as int;
    final total = data['total'] as int;
    final progress = submitted / total;
    final color = data['color'] as Color;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8.w(context)),
                      ),
                      child: Text(
                        data['subject'],
                        style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.9)), 
                      ),
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      data['title'],
                      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      '${data['class']} â€¢ Tenggat: ${data['deadline']}',
                      style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIcons.dotsThree(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.4)),
            ],
          ),
          Spacing.custom(context, 20),
          
          // Progress Pengumpulan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengumpulan',
                style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8)),
              ),
              Text(
                '$submitted / $total Siswa',
                style: AppTextStyles.labelMedium(context, color: AppColors.primary),
              ),
            ],
          ),
          SizedBox(height: 8.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.w(context)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h(context),
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          Spacing.custom(context, 20),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 42.h(context),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuruTugasPenilaianScreen(
                      title: data['title'],
                      subject: data['subject'],
                      className: data['class'],
                    ),
                  ),
                );
              },
              icon: Icon(PhosphorIcons.checks(PhosphorIconsStyle.bold), size: 18.w(context)),
              label: Text(
                'Beri Nilai',
                style: AppTextStyles.labelLarge(context).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


