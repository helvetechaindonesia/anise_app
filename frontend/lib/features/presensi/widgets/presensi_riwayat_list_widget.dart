import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../providers/presensi_provider.dart';

class PresensiRiwayatListWidget extends ConsumerWidget {
  const PresensiRiwayatListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logDataAsync = ref.watch(presensiLogProvider);
    
    return logDataAsync.when(
      data: (logData) {
        if (logData.isEmpty) {
          return const Center(child: Text('Belum ada riwayat presensi.'));
        }
        return Column(
          children: logData.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            final isLast = index == logData.length - 1;
            return Column(
              children: [
                _buildLogItem(context, log),
                if (!isLast)
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 1,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Gagal memuat: $e')),
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> log) {
    bool isLate = log['isLate'] as bool? ?? false;
    Color statusColor = isLate ? AppColors.error : AppColors.primary;
    bool isSiswa = log['role'] == 'SISWA';
    String status = log['status'].toString();
    String validator = log['validator']?.toString() ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h(context), horizontal: 16.w(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log['hari'].toString(),
                      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      log['tanggal'].toString(),
                      style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      status,
                      style: AppTextStyles.labelLarge(context, color: statusColor),
                    ),
                    if (isSiswa && status != 'Hadir' && validator.isNotEmpty) ...[
                      SizedBox(height: 2.h(context)),
                      Text(
                        'Validasi: $validator',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                        textAlign: TextAlign.right,
                      ),
                    ] else if (!isSiswa) ...[
                      SizedBox(height: 2.h(context)),
                      Text(
                        log['waktu'].toString(),
                        style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.8)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

