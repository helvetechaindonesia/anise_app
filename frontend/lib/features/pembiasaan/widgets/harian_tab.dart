import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';

// State provider lokal untuk centang habit harian
final checkedHabitsProvider = StateProvider<Set<String>>((ref) => {});

// State provider lokal untuk centang shalat / al-quran bagi user Muslim
final prayerLogStateProvider = StateProvider<Map<String, bool>>((ref) => {
  'is_subuh': false,
  'is_dhuhur': false,
  'is_asar': false,
  'is_maghrib': false,
  'is_isya': false,
  'is_quran': false,
});

class HarianTabWidget extends ConsumerStatefulWidget {
  const HarianTabWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<HarianTabWidget> createState() => _HarianTabWidgetState();
}

class _HarianTabWidgetState extends ConsumerState<HarianTabWidget> {
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ibadah': return PhosphorIcons.handsPraying(PhosphorIconsStyle.fill);
      case 'kesehatan': return PhosphorIcons.sneaker(PhosphorIconsStyle.fill);
      case 'sosial': return PhosphorIcons.users(PhosphorIconsStyle.fill);
      case 'akademik': return PhosphorIcons.bookOpen(PhosphorIconsStyle.fill);
      case 'disiplin':
      case 'kedisiplinan': return PhosphorIcons.clock(PhosphorIconsStyle.fill);
      default: return PhosphorIcons.star(PhosphorIconsStyle.fill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(masterHabitsProvider);
    final user = ref.watch(authProvider).user;
    final religion = (user?.religion ?? '').trim().toLowerCase();
    final isMuslim = religion == 'islam';

    return habitsAsync.when(
      data: (response) {
        final habits = response.habits;

        final checkedHabits = {
          ...response.todayLoggedHabitIds,
          ...ref.watch(checkedHabitsProvider),
        };
        final prayerState = {
          ...response.todayPrayerLog,
          ...ref.watch(prayerLogStateProvider),
        };

        if (habits.isEmpty) {
          return const CustomScrollView(
            slivers: [
              SliverFillRemaining(child: Center(child: Text("Belum ada data master G7-KAIH.")))
            ],
          );
        }

        // Hitung total item & checked item untuk progress bar
        int totalTargetItems = 0;
        int currentCheckedItems = 0;

        for (var h in habits) {
          if (isMuslim && (h.name.toLowerCase().contains('ibadah') || h.category.toUpperCase() == 'IBADAH')) {
            // Beribadah dijabarkan jadi 6 sub-item
            totalTargetItems += 6;
            currentCheckedItems += prayerState.values.where((v) => v).length;
          } else {
            totalTargetItems += 1;
            if (checkedHabits.contains(h.id)) {
              currentCheckedItems += 1;
            }
          }
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
                      return _buildProgressCard(context, totalTargetItems, currentCheckedItems);
                    }
                    
                    final habit = habits[index - 1];
                    final isIbadah = habit.name.toLowerCase().contains('ibadah') || habit.category.toUpperCase() == 'IBADAH';

                    // 1. JIKA MUSLIM & ITEM BERIBADAH -> EXTEND JADI 6 JENIS
                    if (isMuslim && isIbadah) {
                      return _buildExtendIbadahCard(context, habit, prayerState);
                    }

                    // 2. ITEM UMUM ATAU NON-MUSLIM
                    final isChecked = checkedHabits.contains(habit.id);

                    return GestureDetector(
                      onTap: () async {
                        if (!isChecked) {
                          // Optimistic UI checklist langsung aktif & tetap terchecklist
                          ref.read(checkedHabitsProvider.notifier).update((state) => {...state, habit.id});
                          
                          final success = await ref.read(habitSubmitProvider.notifier).submitLog(habitId: habit.id);
                          if (success) {
                            ref.invalidate(masterHabitsProvider);
                            ref.invalidate(personalHabitStatsProvider);
                            ref.invalidate(guruHabitStatsProvider);
                          } else {
                            // Revert jika gagal kirim ke server
                            ref.read(checkedHabitsProvider.notifier).update((state) => state.where((id) => id != habit.id).toSet());
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
                                    style: AppTextStyles.bodyMedium(context, color: isChecked ? AppColors.onSecondary : AppColors.onSurface).copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
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
      error: (e, st) => CustomScrollView(slivers: [SliverFillRemaining(child: Center(child: Text("Gagal memuat data: $e")))]),
    );
  }

  /// Card Khusus Extend Beribadah Muslim (Subuh, Dzuhur, Asar, Maghrib, Isya, Membaca Al-Quran)
  Widget _buildExtendIbadahCard(BuildContext context, HabitModel habit, Map<String, bool> prayerState) {
    final subPrayers = [
      {'key': 'is_subuh', 'title': 'Shalat Subuh', 'time': 'Pagi'},
      {'key': 'is_dhuhur', 'title': 'Shalat Dzuhur', 'time': 'Siang'},
      {'key': 'is_asar', 'title': 'Shalat Asar', 'time': 'Sore'},
      {'key': 'is_maghrib', 'title': 'Shalat Maghrib', 'time': 'Petang'},
      {'key': 'is_isya', 'title': 'Shalat Isya', 'time': 'Malam'},
      {'key': 'is_quran', 'title': 'Membaca Al-Qur\'an', 'time': 'Tadarus'},
    ];

    final completedCount = prayerState.values.where((v) => v).length;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h(context)),
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22.w(context)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.handsPraying(PhosphorIconsStyle.fill),
                  color: AppColors.primary,
                  size: 22.w(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Beribadah (Muslim)',
                          style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(width: 6.w(context)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.w(context)),
                          ),
                          child: Text(
                            '$completedCount/6',
                            style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      'Shalat 5 Waktu & Membaca Al-Qur\'an',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h(context)),
          const Divider(height: 1),
          SizedBox(height: 10.h(context)),

          // 6 Sub-item Checklist
          ...subPrayers.map((p) {
            final key = p['key']!;
            final title = p['title']!;
            final time = p['time']!;
            final isChecked = prayerState[key] ?? false;

            return InkWell(
              borderRadius: BorderRadius.circular(12.w(context)),
              onTap: () async {
                final newValue = !isChecked;
                // Optimistic UI update
                final updatedState = {...prayerState, key: newValue};
                ref.read(prayerLogStateProvider.notifier).state = updatedState;

                final success = await ref.read(habitSubmitProvider.notifier).submitPrayerLog({key: newValue});
                if (success) {
                  ref.invalidate(masterHabitsProvider);
                  ref.invalidate(personalHabitStatsProvider);
                  ref.invalidate(guruHabitStatsProvider);
                } else {
                  // Revert if failed
                  ref.read(prayerLogStateProvider.notifier).state = prayerState;
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h(context), horizontal: 4.w(context)),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24.w(context),
                      height: 24.w(context),
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6.w(context)),
                        border: Border.all(
                          color: isChecked ? AppColors.primary : AppColors.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: isChecked
                          ? Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: Colors.white, size: 16.w(context))
                          : null,
                    ),
                    SizedBox(width: 12.w(context)),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(
                          fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                          decoration: isChecked ? TextDecoration.none : null,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, int totalCount, int checkedCount) {
    double progress = totalCount == 0 ? 0 : (checkedCount / totalCount).clamp(0.0, 1.0);

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
                'Progress G7-KAIH Hari Ini',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.8)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(color: AppColors.onPrimaryContainer.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(100)),
                child: Text(
                  '$checkedCount/$totalCount',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w700),
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
            progress >= 1.0 ? 'Luar biasa! Seluruh G7-KAIH tercapai hari ini! 🎉' : 'Konsistensi adalah kunci karakter mulia, ayo lanjutkan!',
            style: AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
