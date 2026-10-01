import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import 'jadwal_guru_detail_screen.dart';
import '../../home/providers/home_provider.dart';

class SemuaPengajarScreen extends ConsumerWidget {
  const SemuaPengajarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorsAsync = ref.watch(mentorsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.backgroundLight,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Semua Pengajar',
                style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(left: 20.w(context), right: 20.w(context), bottom: 20.h(context)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),
                    Text(
                      'Pilih pengajar untuk melihat jadwal detail dan modul mereka.',
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                    ),
                    SizedBox(height: 24.h(context)),
                  ],
                ),
              ),
            ),
            mentorsAsync.when(
              data: (mentors) {
                if (mentors.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada data pengajar', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant)),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h(context),
                      crossAxisSpacing: 16.w(context),
                      childAspectRatio: 0.70,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final mentor = mentors[index];
                        return Container(
                          padding: EdgeInsets.all(12.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(16.w(context)),
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 8.h(context)),
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 56.w(context),
                                    height: 56.w(context),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), color: AppColors.onPrimary, size: 32.w(context)),
                                  ),
                                  Container(
                                    width: 14.w(context),
                                    height: 14.w(context),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primaryContainer, width: 2),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h(context)),
                              Text(
                                mentor['name'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer),
                              ),
                              Text(
                                mentor['subject'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.8)),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JadwalGuruDetailScreen(
                                        teacherName: mentor['name'] as String,
                                        subject: mentor['subject'] as String,
                                        themeColor: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8.h(context)),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12.w(context)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(PhosphorIcons.calendar(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 14.w(context)),
                                      SizedBox(width: 6.w(context)),
                                      Text(
                                        'Jadwal',
                                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: mentors.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (e, st) => SliverFillRemaining(
                child: Center(
                  child: Text('Gagal memuat pengajar', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                ),
              ),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: 40.h(context))),
          ],
        ),
      ),
    );
  }
}
