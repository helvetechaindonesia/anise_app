import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
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
            SliverAppBar(
              expandedHeight: 120.h(context),
              pinned: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.onSurface),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 56.w(context), bottom: 16.h(context)),
                title: Text(
                  'Aduan Kesiswaan',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                ),
              ),
            ),
            reportsAsync.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, st) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
              data: (reports) {
                if (reports.isEmpty) {
                  return SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.all(24.w(context)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.folderOpen(PhosphorIconsStyle.duotone), size: 100.w(context), color: AppColors.menuPastelPurple),
                          SizedBox(height: 24.h(context)),
                          Text('Belum ada aduan', style: AppTextStyles.titleLarge(context, color: AppColors.onBackground)),
                        ],
                      ),
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
