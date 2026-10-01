import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';

final habitStatsProvider = FutureProvider.family<Map<String, dynamic>, String?>((ref, studentId) async {
  final dio = ref.watch(dioProvider);
  final queryParams = studentId != null ? '?student_id=$studentId' : '';
  final response = await dio.get('/habits/stats$queryParams');
  
  if (response.data['status'] == 'success') {
    return response.data['data'] as Map<String, dynamic>;
  }
  throw Exception(response.data['message']);
});

class AnalisisTabWidget extends ConsumerStatefulWidget {
  final String? studentId;

  const AnalisisTabWidget({Key? key, this.studentId}) : super(key: key);

  @override
  ConsumerState<AnalisisTabWidget> createState() => _AnalisisTabWidgetState();
}

class _AnalisisTabWidgetState extends ConsumerState<AnalisisTabWidget> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(habitStatsProvider(widget.studentId));

    return statsAsync.when(
      data: (data) {
        final summary = data['summary'];
        final List habits = data['habits'];
        
        return CustomScrollView(
          key: const PageStorageKey('analisis_tab'),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(left: 20.w(context), right: 20.w(context), bottom: 40.h(context)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: 16.h(context)),
                  _buildSummaryCards(context, summary),
                  SizedBox(height: 32.h(context)),
                  Text(
                    'Analisis Radar Pembiasaan',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 24.h(context)),
                  _buildRadarChart(context, habits),
                  SizedBox(height: 32.h(context)),
                  Text(
                    'Detail Kategori',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 16.h(context)),
                  ...habits.map((h) => _buildCategoryProgress(context, h)).toList(),
                ]),
              ),
            ),
          ],
        );
      },
      loading: () => const CustomScrollView(slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (e, st) => CustomScrollView(slivers: [SliverFillRemaining(child: Center(child: Text("Error: $e")))]),
    );
  }

  Widget _buildSummaryCards(BuildContext context, Map<String, dynamic> summary) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStatCard(
            context,
            'Total Input Pembiasaan',
            summary['total_submissions'].toString(),
            PhosphorIcons.listChecks(PhosphorIconsStyle.bold),
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.w(context)),
          SizedBox(height: 12.h(context)),
          Text(
            value,
            style: AppTextStyles.headlineMedium(context, color: color),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            title,
            style: AppTextStyles.bodySmall(context, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(BuildContext context, List habits) {
    if (habits.isEmpty) {
      return const Center(child: Text('Belum ada data untuk ditampilkan di Radar Chart.'));
    }

    return Container(
      height: 300.h(context),
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.primary.withValues(alpha: 0.3),
              borderColor: AppColors.primary,
              entryRadius: 4,
              dataEntries: habits.map((h) {
                return RadarEntry(value: (h['total_submissions'] as num).toDouble());
              }).toList(),
              borderWidth: 2,
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: AppTextStyles.labelSmall(context, color: AppColors.onBackground),
          getTitle: (index, angle) {
            if (index >= habits.length) return const RadarChartTitle(text: '');
            return RadarChartTitle(text: habits[index]['category']);
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 10),
          tickBorderData: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
          gridBorderData: BorderSide(color: AppColors.outline.withValues(alpha: 0.3), width: 1),
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget _buildCategoryProgress(BuildContext context, Map<String, dynamic> habit) {
    int total = habit['total_submissions'];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            habit['name'],
            style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Text(
              '$total Kali',
              style: AppTextStyles.labelMedium(context, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

