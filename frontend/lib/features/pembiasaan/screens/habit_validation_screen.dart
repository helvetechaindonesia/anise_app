import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/habit_provider.dart';

class HabitValidationScreen extends ConsumerWidget {
  const HabitValidationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingLogsAsync = ref.watch(pendingLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Validasi Habit Siswa'),
        backgroundColor: AppColors.cardGlass,
      ),
      body: pendingLogsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(child: Text('Tidak ada laporan habit pending.', style: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                color: AppColors.cardGlass,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(log.studentName, style: AppTextStyles.titleMedium(context, color: AppColors.primary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(8)),
                            child: Text('PENDING', style: AppTextStyles.labelSmall(context, color: AppColors.surface)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Kegiatan: ${log.habitName}', style: AppTextStyles.bodyMedium(context, color: AppColors.textPrimary)),
                      if (log.notes != null && log.notes!.isNotEmpty)
                        Text('Catatan: ${log.notes}', style: AppTextStyles.bodyMedium(context, color: AppColors.textSecondary)),
                      
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {}, // Backend logic needed for reject
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                              child: Text('Tolak', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {}, // Backend logic needed for approve
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: Text('Setujui', style: AppTextStyles.bodyMedium(context, color: AppColors.surface)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString(), style: AppTextStyles.bodyMedium(context, color: AppColors.error))),
      ),
    );
  }
}

