import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';

// Helper Provider untuk nge-track habit mana aja yang udah dicentang (dikirim hari ini)
// Di real world, harus nge-fetch status per hari dari API, tapi ini simple state
final checkedHabitsProvider = StateProvider<Set<String>>((ref) => {});

class HarianTabWidget extends ConsumerWidget {
  const HarianTabWidget({Key? key}) : super(key: key);

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah': return PhosphorIcons.handsPraying(PhosphorIconsStyle.fill);
      case 'kesehatan': return PhosphorIcons.sneaker(PhosphorIconsStyle.fill);
      case 'sosial': return PhosphorIcons.users(PhosphorIconsStyle.fill);
      case 'akademik': return PhosphorIcons.bookOpen(PhosphorIconsStyle.fill);
      case 'disiplin': return PhosphorIcons.clock(PhosphorIconsStyle.fill);
      default: return PhosphorIcons.star(PhosphorIconsStyle.fill);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(masterHabitsProvider);
    final checkedHabits = ref.watch(checkedHabitsProvider);

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const CustomScrollView(
            slivers: [
              SliverFillRemaining(child: Center(child: Text("Belum ada data master pembiasaan.")))
            ],
          );
        }

        return CustomScrollView(
          key: const PageStorageKey('harian_tab'),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(left: 20.w(context), right: 20.w(context), bottom: 40.h(context)),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return _buildProgressCard(context, ref, habits, checkedHabits.length);
                    }
                    
                    final habit = habits[index - 1];
                    final isChecked = checkedHabits.contains(habit.id);

                    return GestureDetector(
                      onTap: () async {
                        if (!isChecked) {
                          // Submit API
                          final success = await ref.read(habitSubmitProvider.notifier).submitLog(habitId: habit.id);
                          if (success) {
                            ref.read(checkedHabitsProvider.notifier).update((state) => {...state, habit.id});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pembiasaan berhasil dicatat!')),
                            );
                          }
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.only(bottom: 12.h(context)),
                        padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
                        decoration: BoxDecoration(
                          color: isChecked ? AppColors.secondary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20.w(context)),
                          border: Border.all(
                            color: isChecked ? AppColors.secondary : AppColors.outline,
                            width: isChecked ? 2 : 1,
                          ),
                          boxShadow: [
                            if (!isChecked)
                              BoxShadow(
                                color: AppColors.onBackground.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w(context)),
                              decoration: BoxDecoration(
                                color: isChecked ? AppColors.onSecondary.withValues(alpha: 0.2) : AppColors.backgroundLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForCategory(habit.category),
                                color: isChecked ? AppColors.onSecondary : AppColors.onSurface,
                                size: 24.w(context),
                              ),
                            ),
                            SizedBox(width: 16.w(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.name,
                                    style: AppTextStyles.bodyMedium(context, color: isChecked ? AppColors.onSecondary : AppColors.onSurface),
                                  ),
                                  SizedBox(height: 4.h(context)),
                                  Text(
                                    habit.category,
                                    style: AppTextStyles.bodySmall(context, color: isChecked ? AppColors.onSecondary.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.7)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w(context)),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28.w(context),
                              height: 28.w(context),
                              decoration: BoxDecoration(
                                color: isChecked ? AppColors.onSecondary : AppColors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isChecked ? AppColors.onSecondary : AppColors.outline,
                                  width: 2,
                                ),
                              ),
                              child: isChecked
                                  ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.secondary, size: 16.w(context))
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: habits.length + 1,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const CustomScrollView(slivers: [SliverFillRemaining(child: Center(child: CircularProgressIndicator()))]),
      error: (e, st) => CustomScrollView(slivers: [SliverFillRemaining(child: Center(child: Text("Error: $e")))]),
    );
  }

  Widget _buildProgressCard(BuildContext context, WidgetRef ref, List<HabitModel> habits, int checkedCount) {
    double progress = habits.isEmpty ? 0 : checkedCount / habits.length;

    return Container(
      margin: EdgeInsets.only(bottom: 24.h(context), top: 8.h(context)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Hari Ini',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.8)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(color: AppColors.onPrimaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)),
                child: Text(
                  '${checkedCount}/${habits.length}',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.onPrimaryContainer.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.onPrimaryContainer),
              minHeight: 8.h(context),
            ),
          ),
          SizedBox(height: 12.h(context)),
          Text(
            progress == 1.0 ? 'Luar biasa! Semua tercapai! ??' : 'Ayo, selesaikan kebiasaan baikmu!',
            style: AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
