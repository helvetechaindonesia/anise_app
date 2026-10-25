import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_empty_state.dart';
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
          return const AniseEmptyState(
            title: 'Belum Ada Data Riwayat',
            subtitle: 'Tidak ada catatan kehadiran pada bulan & tahun ini.',
          );
        }

        return Column(
          children: logData.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value as Map<String, dynamic>;
            final isLast = index == logData.length - 1;

            final bool isLate = log['isLate'] as bool? ?? false;
            final String rawStatus = log['status']?.toString() ?? 'H';
            final String statusLabel = log['status_label']?.toString() ?? log['status']?.toString() ?? 'Hadir';
            final String validator = log['validator']?.toString() ?? '';
            final String waktu = log['waktu']?.toString() ?? '-';
            final String? jamPulang = log['jam_pulang']?.toString();
            final String? catatan = log['catatan']?.toString();

            Color statusColor;
            IconData statusIcon;

            final statusUpper = rawStatus.toUpperCase();
            final labelLower = statusLabel.toLowerCase();

            if (statusUpper == 'T' || labelLower.contains('terlambat')) {
              statusColor = AppColors.error;
              statusIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'TAM') {
              statusColor = AppColors.error;
              statusIcon = PhosphorIcons.clockClockwise(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'TAP') {
              statusColor = AppColors.error;
              statusIcon = PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'PA' || labelLower.contains('pulang awal')) {
              statusColor = AppColors.warning;
              statusIcon = PhosphorIcons.clockAfternoon(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'K' || labelLower.contains('kembali')) {
              statusColor = AppColors.info;
              statusIcon = PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.bold);
            } else if (statusUpper == 'S' || labelLower.contains('sakit')) {
              statusColor = AppColors.info;
              statusIcon = PhosphorIcons.firstAid(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'I' || labelLower.contains('izin')) {
              statusColor = AppColors.warning;
              statusIcon = PhosphorIcons.envelopeSimple(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'C' || labelLower.contains('cuti')) {
              statusColor = AppColors.tertiary;
              statusIcon = PhosphorIcons.calendarStar(PhosphorIconsStyle.fill);
            } else if (statusUpper == 'A' || labelLower.contains('alpha')) {
              statusColor = AppColors.error;
              statusIcon = PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
            } else {
              // H (Hadir Tepat) atau PULANG
              statusColor = AppColors.primary;
              statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
            }

            // Atur metadata icon & text (tampilkan catatan jika waktu kosong)
            IconData metaIcon = PhosphorIcons.clock(PhosphorIconsStyle.regular);
            String metaText = 'Waktu: $waktu';

            if (waktu != '-' && waktu.isNotEmpty) {
              metaIcon = PhosphorIcons.clock(PhosphorIconsStyle.regular);
              metaText = jamPulang != null ? 'Masuk: $waktu • Pulang: $jamPulang WIB' : 'Waktu: $waktu';
            } else if (catatan != null && catatan.isNotEmpty) {
              metaIcon = PhosphorIcons.notepad(PhosphorIconsStyle.regular);
              metaText = catatan;
            }

            return ItemListTile(
              category: log['hari']?.toString(),
              subcategory: log['lokasi'] != null ? 'Lokasi: ${log['lokasi']}' : null,
              title: log['tanggal']?.toString() ?? '',
              metadataIcon: metaIcon,
              metadataText: metaText,
              statusText: statusLabel,
              statusIcon: statusIcon,
              statusColor: statusColor,
              showDivider: !isLast,
              dividerThickness: 2.0.h(context),
              bottomWidget: (statusLower != 'hadir' && validator.isNotEmpty)
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.w(context)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                            size: 13.w(context),
                            color: badgeColor,
                          ),
                          SizedBox(width: 5.w(context)),
                          Text(
                            validator,
                            style: AppTextStyles.labelSmall(context, color: badgeColor).copyWith(
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
          padding: EdgeInsets.symmetric(vertical: 32.h(context)),
          child: const CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, st) => const AniseEmptyState(
        title: 'Belum Ada Data Riwayat',
        subtitle: 'Tidak dapat memuat catatan kehadiran saat ini.',
      ),
    );
  }
}
