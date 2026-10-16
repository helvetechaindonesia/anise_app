import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../lapor/providers/report_provider.dart';

class TuKesiswaanScreen extends ConsumerWidget {
  const TuKesiswaanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(studentReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            const AniseSliverAppBar(title: 'Aduan Kesiswaan'),
            reportsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
              error: (e, st) => const SliverFillRemaining(
                child: AniseEmptyState(
                  title: 'Belum Ada Data Aduan',
                  subtitle: 'Belum ada aduan kesiswaan yang tercatat pada sistem.',
                ),
              ),
              data: (reports) {
                if (reports.isEmpty) {
                  return const SliverFillRemaining(
                    child: AniseEmptyState(
                      title: 'Belum Ada Data Aduan',
                      subtitle: 'Belum ada aduan kesiswaan yang tercatat pada sistem.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.all(20.w(context)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final report = reports[index];
                        final isAnon = report['is_anonymous'] == 1 || report['is_anonymous'] == true;
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h(context)),
                          padding: EdgeInsets.all(16.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16.w(context)),
                            border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(10.w(context)),
                                    ),
                                    child: Text(
                                      report['category'] ?? 'Umum',
                                      style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer),
                                    ),
                                  ),
                                  Text(
                                    isAnon ? 'Anonim' : (report['student']?['name'] ?? 'Siswa'),
                                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h(context)),
                              Text(
                                report['report_title'] ?? '',
                                style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                              ),
                              SizedBox(height: 8.h(context)),
                              Text(
                                report['report_text'] ?? '',
                                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.8)),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: reports.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
