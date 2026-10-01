import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../tugas/providers/tugas_provider.dart';
import '../../tugas/screens/guru_tugas_screen.dart';
import '../../tugas/widgets/tugas_item_card.dart';
import '../../tugas/screens/guru_tugas_penilaian_screen.dart';
import 'package:intl/intl.dart';

class GuruPantauPenugasanWidget extends ConsumerWidget {
  const GuruPantauPenugasanWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(getTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  'Pantau Penugasan',
                  style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
                ),
                SizedBox(width: 8.w(context)),
                tasksAsync.when(
                  data: (tasks) {
                    final activeCount = tasks.where((t) => DateTime.parse(t['due_date']).isAfter(DateTime.now())).length;
                    if (activeCount == 0) return const SizedBox();
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20.w(context)),
                      ),
                      child: Text(
                        '$activeCount',
                        style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary),
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuruTugasScreen()),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Lihat\nSemua',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(width: 4.w(context)),
                  Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground),
                ],
              ),
            ),
          ],
        ),
        Spacing.custom(context, 16),
        
        tasksAsync.when(
          data: (tasks) {
            final now = DateTime.now();
            final activeTasks = tasks.where((t) => DateTime.parse(t['due_date']).isAfter(now)).take(3).toList();
            
            if (activeTasks.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), color: AppColors.onBackground.withValues(alpha: 0.2), size: 48.w(context)),
                    SizedBox(height: 12.h(context)),
                    Text(
                      'Tidak ada penugasan aktif',
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: activeTasks.asMap().entries.map((entry) {
                final index = entry.key;
                final tugas = entry.value;
                final isLast = index == activeTasks.length - 1;
                
                final due = DateTime.parse(tugas['due_date']);
                final dateStr = DateFormat('dd MMM yyyy HH:mm').format(due);
                
                final submitted = tugas['submitted_count'] as int;
                final total = tugas['total_students'] as int;

                return Column(
                  children: [
                    TugasItemCard(
                      subject: tugas['subject_name'],
                      teacher: tugas['class_name'], // Show class name instead of teacher for Guru view
                      title: tugas['title'],
                      timeInfo: 'Tenggat: $dateStr',
                      statusText: '$submitted / $total Terkumpul',
                      statusColor: AppColors.primary,
                      statusIcon: PhosphorIcons.users(PhosphorIconsStyle.fill),
                      timeBgColor: AppColors.error.withValues(alpha: 0.1),
                      timeIconColor: AppColors.error,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuruTugasPenilaianScreen(
                              title: tugas['title'],
                              subject: tugas['subject_name'],
                              className: tugas['class_name'],
                            ),
                          ),
                        );
                      },
                    ),
                    if (!isLast)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 1,
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Gagal memuat tugas: $error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}
