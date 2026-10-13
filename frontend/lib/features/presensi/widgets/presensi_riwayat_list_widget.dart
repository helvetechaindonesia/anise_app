import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/item_list_tile.dart';
import '../providers/presensi_provider.dart';

class PresensiRiwayatListWidget extends ConsumerWidget {
  const PresensiRiwayatListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logDataAsync = ref.watch(presensiLogProvider);

    return logDataAsync.when(
      data: (logData) {
        if (logData.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h(context)),
              child: Text(
                'Belum ada riwayat presensi di periode ini.',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant),
              ),
            ),
          );
        }

        return Column(
          children: logData.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value as Map<String, dynamic>;
            final isLast = index == logData.length - 1;

            final bool isLate = log['isLate'] as bool? ?? false;
            final String status = log['status']?.toString() ?? 'Hadir';
            final bool isSiswa = log['role'] == 'SISWA';
            final String validator = log['validator']?.toString() ?? '';

            final Color statusColor = isLate
                ? AppColors.error
                : (status == 'Hadir' ? AppColors.secondary : AppColors.onBackground);

            return ItemListTile(
              category: log['hari']?.toString(),
              subcategory: log['lokasi'] != null ? 'Lokasi: ${log['lokasi']}' : null,
              title: log['tanggal']?.toString() ?? '',
              metadataIcon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
              metadataText: 'Jam Masuk: ${log['waktu'] ?? '-'}',
              statusText: 'Status: $status',
              statusIcon: isLate
                  ? PhosphorIcons.warningCircle(PhosphorIconsStyle.fill)
                  : PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
              statusColor: statusColor,
              showDivider: !isLast,
              dividerThickness: 2.0.h(context),
              trailing: (isSiswa && status != 'Hadir' && validator.isNotEmpty)
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.w(context)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                            size: 13.w(context),
                            color: AppColors.error,
                          ),
                          SizedBox(width: 4.w(context)),
                          Text(
                            validator,
                            style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            );
          }).toList(),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h(context)),
          child: const CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, st) => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h(context)),
          child: Text(
            'Gagal memuat riwayat: $e',
            style: AppTextStyles.bodyMedium(context, color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
