import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/section_action_link.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../screens/kepsek_kpi_monitoring_screen.dart';

final kepsekKpiLeaderboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/kpi/leaderboard');
    if (response.data['status'] == 'success') {
      return response.data['data'] as Map<String, dynamic>;
    }
    return {};
  } catch (e) {
    return {};
  }
});

class KepsekPantauKpiWidget extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const KepsekPantauKpiWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsync = ref.watch(kepsekKpiLeaderboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pantau KPI Tendik',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  '5 KPI tendik paling rendah bulan ini',
                  style: AppTextStyles.labelSmall(context, color: AppColors.error.withValues(alpha: 0.8)).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SectionActionLink(
              text: 'Semua',
              onTap: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(3);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KepsekKpiMonitoringScreen()),
                  );
                }
              },
            ),
          ],
        ),
        Spacing.custom(context, 16),
        kpiAsync.when(
          loading: () => Container(
            height: 180.h(context),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            child: const CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, stack) => Container(
            padding: EdgeInsets.all(16.w(context)),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16.w(context)),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 20.w(context)),
                SizedBox(width: 8.w(context)),
                Expanded(
                  child: Text('Gagal memuat ranking KPI tendik', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                  onPressed: () => ref.refresh(kepsekKpiLeaderboardProvider),
                ),
              ],
            ),
          ),
          data: (data) {
            final List<dynamic> lowestFive = data['lowest_five'] ?? [];

            if (lowestFive.isEmpty) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                ),
                child: AniseEmptyState(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 24.h(context)),
                  icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  title: 'Semua Tendik Berkinerja Baik',
                  subtitle: 'Tidak ada tendik dengan catatan KPI kritis pada bulan ini.',
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 8.h(context)),
                itemCount: lowestFive.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.outline.withValues(alpha: 0.08),
                  indent: 16.w(context),
                  endIndent: 16.w(context),
                ),
                itemBuilder: (context, index) {
                  final tendik = lowestFive[index];
                  final String name = tendik['full_name'] ?? tendik['username'] ?? 'Tendik';
                  final String role = tendik['role_type'] ?? 'Staff';
                  final num kpiScore = tendik['kpi_score'] ?? 0;
                  final num presenceScore = tendik['presence_score'] ?? 0;
                  final int journalCount = tendik['journal_count'] ?? 0;

                  Color scoreColor = AppColors.error;
                  if (kpiScore >= 85) {
                    scoreColor = AppColors.success;
                  } else if (kpiScore >= 70) {
                    scoreColor = AppColors.warning;
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KepsekKpiMonitoringScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(16.w(context)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
                      child: Row(
                        children: [
                          // Ranking Badge (1, 2, 3...)
                          Container(
                            width: 26.w(context),
                            height: 26.w(context),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: index == 0 ? AppColors.error.withValues(alpha: 0.15) : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: AppTextStyles.labelSmall(
                                context,
                                color: index == 0 ? AppColors.error : AppColors.onSurfaceVariant,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 12.w(context)),
                          // Avatar Icon / Initials
                          CircleAvatar(
                            radius: 18.w(context),
                            backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: AppTextStyles.titleSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 12.w(context)),
                          // Info Tendik
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2.h(context)),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(6.w(context)),
                                      ),
                                      child: Text(
                                        role,
                                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w(context)),
                                    Text(
                                      'Presensi: ${presenceScore.toStringAsFixed(0)}% • Jurnal: $journalCount',
                                      style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.55)).copyWith(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          // Skor KPI
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
                                  style: AppTextStyles.titleMedium(context, color: scoreColor).copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Poin KPI',
                                  style: AppTextStyles.labelSmall(context, color: scoreColor).copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
