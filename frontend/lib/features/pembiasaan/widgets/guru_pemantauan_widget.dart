import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../providers/habit_provider.dart';
import '../screens/detail_analisis_siswa_screen.dart';

class GuruPemantauanWidget extends ConsumerWidget {
  const GuruPemantauanWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoredAsync = ref.watch(monitoredStudentsProvider);
    final statsAsync = ref.watch(guruHabitStatsProvider);

    return SliverMainAxisGroup(
      slivers: [
        // 1. Chart Section
        SliverToBoxAdapter(
          child: statsAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (e, st) => Padding(padding: const EdgeInsets.all(24), child: Text('Gagal muat statistik: $e')),
            data: (stats) {
              final categories = stats['categories'] as Map<String, dynamic>;
              if (categories.isEmpty) return const SizedBox.shrink();

              // Bar chart data
              List<BarChartGroupData> barGroups = [];
              int index = 0;
              double maxY = 0;

              final cats = ['IBADAH', 'KEDISIPLINAN', 'KESEHATAN', 'AKADEMIK', 'SOSIAL'];
              for (var cat in cats) {
                final catData = categories[cat];
                if (catData != null) {
                  final total = (catData['total'] as num).toDouble();
                  
                  if (total > maxY) maxY = total;

                  barGroups.add(
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: total,
                          color: AppColors.primary,
                          width: 16.w(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                  index++;
                }
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Pembiasaan Kelas (${stats['total_students']} Siswa)',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                    ),
                    SizedBox(height: 16.h(context)),
                    Container(
                      height: 200.h(context),
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16.w(context)),
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                      ),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY == 0 ? 10 : maxY + (maxY * 0.2),
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const titles = ['Ibadah', 'Disiplin', 'Sehat', 'Akademik', 'Sosial'];
                                  if (value.toInt() < titles.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(titles[value.toInt()], style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontSize: 10)),
                                    );
                                  }
                                  return const Text('');
                                },
                                reservedSize: 28,
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxY == 0 ? 2 : (maxY / 4 > 0 ? maxY / 4 : 1),
                            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.outline.withValues(alpha: 0.1), strokeWidth: 1),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: barGroups,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h(context)),

                    Text(
                      'Daftar Siswa',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 2. Student List Section
        monitoredAsync.when(
          data: (students) {
            if (students.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h(context)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.users(PhosphorIconsStyle.fill), color: AppColors.onBackground.withValues(alpha: 0.2), size: 64.w(context)),
                        SizedBox(height: 16.h(context)),
                        Text(
                          'Belum ada siswa yang dipantau.',
                          style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final student = students[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailAnalisisSiswaScreen(
                              studentId: student['id'].toString(),
                              studentName: student['name'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h(context)),
                        padding: EdgeInsets.all(16.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.w(context)),
                          border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onBackground.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24.w(context),
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                student['name'].toString().substring(0, 1).toUpperCase(),
                                style: AppTextStyles.titleMedium(context, color: AppColors.onPrimaryContainer),
                              ),
                            ),
                            SizedBox(width: 16.w(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name'],
                                    style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                                  ),
                                  SizedBox(height: 4.h(context)),
                                  Text(
                                    'Username: ${student['username'] ?? '-'}',
                                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: students.length,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
          error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Terjadi kesalahan: $e'))),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w(context),
          height: 12.w(context),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(label, style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}

