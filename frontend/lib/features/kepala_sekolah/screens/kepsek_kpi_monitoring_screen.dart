import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/main_header.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../widgets/kepsek_pantau_kpi_widget.dart';

class KepsekKpiMonitoringScreen extends ConsumerStatefulWidget {
  const KepsekKpiMonitoringScreen({super.key});

  @override
  ConsumerState<KepsekKpiMonitoringScreen> createState() => _KepsekKpiMonitoringScreenState();
}

class _KepsekKpiMonitoringScreenState extends ConsumerState<KepsekKpiMonitoringScreen> {
  String _selectedRoleFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kpiAsync = ref.watch(kepsekKpiLeaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          const MainHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacing.custom(context, 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MONITORING EKSEKUTIF',
                            style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4.h(context)),
                          Text(
                            'Pantau KPI Tendik',
                            style: AppTextStyles.headlineMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => ref.refresh(kepsekKpiLeaderboardProvider),
                        icon: Icon(PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold), color: AppColors.primary),
                        tooltip: 'Muat Ulang',
                      ),
                    ],
                  ),
                  Spacing.custom(context, 16),

                  // Ringkasan KPI Card
                  kpiAsync.maybeWhen(
                    data: (data) => _buildSummaryCard(context, data),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  Spacing.custom(context, 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.w(context)),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14.w(context)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                      decoration: InputDecoration(
                        icon: Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.onSurfaceVariant, size: 20.w(context)),
                        hintText: 'Cari nama atau NIP tendik...',
                        hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Spacing.custom(context, 12),

                  // Role Chips (Semua, Guru, BK, TU)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'Semua'),
                        SizedBox(width: 8.w(context)),
                        _buildFilterChip('GURU', 'Guru Mapel'),
                        SizedBox(width: 8.w(context)),
                        _buildFilterChip('GURU_BK', 'Guru BK'),
                        SizedBox(width: 8.w(context)),
                        _buildFilterChip('TATA_USAHA', 'Staf TU'),
                      ],
                    ),
                  ),
                  Spacing.custom(context, 16),
                ],
              ),
            ),
          ),

          // List Seluruh Tendik
          kpiAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Gagal memuat data KPI: $err', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
              ),
            ),
            data: (data) {
              final List<dynamic> allTendik = data['all_tendik'] ?? [];

              final filtered = allTendik.where((t) {
                final String name = (t['full_name'] ?? '').toString().toLowerCase();
                final String nip = (t['nip'] ?? '').toString().toLowerCase();
                final String role = (t['role_type'] ?? '').toString();

                final matchQuery = _searchQuery.isEmpty || name.contains(_searchQuery) || nip.contains(_searchQuery);
                final matchRole = _selectedRoleFilter == 'ALL' || role == _selectedRoleFilter;

                return matchQuery && matchRole;
              }).toList();

              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AniseEmptyState(
                    title: 'Belum Ada Data Tendik',
                    subtitle: 'Tidak ada tenaga pendidik yang sesuai dengan filter pencarian.',
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tendik = filtered[index];
                      return _buildTendikKpiCard(context, tendik, index);
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: 32.h(context))),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedRoleFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTextStyles.labelSmall(
          context,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
        ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.15),
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedRoleFilter = value);
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, dynamic> data) {
    final int totalTendik = data['total_tendik'] ?? 0;
    final num averageKpi = data['average_kpi'] ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.w(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '$totalTendik',
                style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4.h(context)),
              Text('Total Tendik', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary.withValues(alpha: 0.8))),
            ],
          ),
          Container(height: 40.h(context), width: 1, color: AppColors.onPrimary.withValues(alpha: 0.3)),
          Column(
            children: [
              Text(
                averageKpi.toStringAsFixed(1),
                style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4.h(context)),
              Text('Rata-rata KPI', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTendikKpiCard(BuildContext context, dynamic tendik, int index) {
    final String name = tendik['full_name'] ?? tendik['username'] ?? 'Tendik';
    final String nip = tendik['nip'] ?? '-';
    final String role = tendik['role_type'] ?? 'Staff';
    final num kpiScore = tendik['kpi_score'] ?? 0;
    final num presenceScore = tendik['presence_score'] ?? 0;
    final int journalCount = tendik['journal_count'] ?? 0;
    final int hadir = tendik['hadir_count'] ?? 0;
    final int terlambat = tendik['terlambat_count'] ?? 0;
    final int alpha = tendik['alpha_count'] ?? 0;

    Color scoreColor = AppColors.error;
    if (kpiScore >= 85) {
      scoreColor = AppColors.success;
    } else if (kpiScore >= 70) {
      scoreColor = AppColors.warning;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h(context)),
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.w(context),
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      'NIP: $nip • $role',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.w(context)),
                  border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      kpiScore.toStringAsFixed(1),
                      style: AppTextStyles.titleMedium(context, color: scoreColor).copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Skor KPI',
                      style: AppTextStyles.labelSmall(context, color: scoreColor).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          Divider(height: 1, thickness: 1, color: AppColors.outline.withValues(alpha: 0.08)),
          SizedBox(height: 10.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Presensi: ${presenceScore.toStringAsFixed(0)}% (H: $hadir, T: $terlambat, A: $alpha)',
                style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.65)),
              ),
              Text(
                'Jurnal KBM: $journalCount',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
