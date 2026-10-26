import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_card.dart';
import '../../../../core/widgets/anise_empty_state.dart';
import '../../../../core/widgets/item_list_tile.dart';
import '../providers/poin_provider.dart';

class PoinActivityListWidget extends ConsumerStatefulWidget {
  const PoinActivityListWidget({super.key});

  @override
  ConsumerState<PoinActivityListWidget> createState() => _PoinActivityListWidgetState();
}

class _PoinActivityListWidgetState extends ConsumerState<PoinActivityListWidget> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Semua', 'Terlambat', 'Atribut Tidak Lengkap', 'Bolos', 'Lainnya'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActivityHeader(context),
        SizedBox(height: 16.h(context)),
        _buildFilterRow(context),
        SizedBox(height: 16.h(context)),
        _buildActivityCards(context),
      ],
    );
  }

  Widget _buildActivityHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Riwayat Pelanggaran & Pengurangan Poin',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Icon(PhosphorIcons.faders(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 14.w(context)),
            SizedBox(width: 4.w(context)),
            Text(
              'Filter',
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w(context)),
              padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                borderRadius: BorderRadius.circular(20.w(context)),
                border: Border.all(
                  color: isSelected ? AppColors.primaryContainer : AppColors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _filters[index],
                style: AppTextStyles.bodySmall(context,
                    color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActivityCards(BuildContext context) {
    final historyAsync = ref.watch(pointHistoryProvider);

    return historyAsync.when(
      data: (items) {
        List<dynamic> displayedList = items;

        if (_selectedFilterIndex != 0) {
          final filterCategory = _filters[_selectedFilterIndex].toLowerCase();
          displayedList = items.where((act) {
            final cat = (act['category'] ?? '').toString().toLowerCase();
            return cat.contains(filterCategory);
          }).toList();
        }

        if (displayedList.isEmpty) {
          return AniseCard(
            padding: EdgeInsets.symmetric(vertical: 24.h(context), horizontal: 16.w(context)),
            child: const AniseEmptyState(
              icon: PhosphorIconsRegular.shieldCheck,
              title: 'Tidak Ada Pelanggaran',
              subtitle: 'Luar biasa! Tidak ada catatan pelanggaran tata tertib pada kategori ini.',
            ),
          );
        }

        return AniseCard(
          padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 6.h(context)),
          child: Column(
            children: displayedList.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value as Map<String, dynamic>;
              final isLast = idx == displayedList.length - 1;

              final String category = item['category']?.toString() ?? 'Pelanggaran';
              final String title = item['title']?.toString() ?? 'Pelanggaran Tata Tertib';
              final String? desc = item['description']?.toString();
              final String date = item['date']?.toString() ?? '-';
              final String reporter = item['reporter_name']?.toString() ?? 'Petugas Piket / Guru';
              final String status = item['status']?.toString() ?? 'APPROVED';
              final num pointsDeducted = item['points_deducted'] ?? -1.1;

              // Format poin negatif (e.g. -1.1 Poin)
              final String pointBadgeText = '${pointsDeducted.toStringAsFixed(1)} Poin';

              Color statusBadgeColor = AppColors.error;
              IconData statusBadgeIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
              String statusBadgeLabel = 'Pelanggaran Sah';

              if (status == 'LAPORAN') {
                statusBadgeColor = AppColors.warning;
                statusBadgeIcon = PhosphorIcons.clock(PhosphorIconsStyle.fill);
                statusBadgeLabel = 'Menunggu Validasi';
              }

              return ItemListTile(
                category: 'KEDISIPLINAN SISWA',
                subcategory: category,
                title: title,
                metadataText: date,
                metadataIcon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
                secondaryMetadataText: 'Pencatat: $reporter',
                secondaryMetadataIcon: PhosphorIcons.user(PhosphorIconsStyle.bold),
                statusText: statusBadgeLabel,
                statusIcon: statusBadgeIcon,
                statusColor: statusBadgeColor,
                statusTrailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Text(
                    pointBadgeText,
                    style: AppTextStyles.labelMedium(context, color: AppColors.error).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                bottomWidget: (desc != null && desc.isNotEmpty && desc != 'Pelanggaran kedisiplinan tercatat dalam sistem.')
                    ? Container(
                        padding: EdgeInsets.all(8.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8.w(context)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(PhosphorIcons.chatText(PhosphorIconsStyle.regular),
                                size: 14.w(context), color: AppColors.textSecondary),
                            SizedBox(width: 6.w(context)),
                            Expanded(
                              child: Text(
                                desc,
                                style: AppTextStyles.bodySmall(context, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
                showDivider: !isLast,
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => AniseCard(
        padding: EdgeInsets.all(16.w(context)),
        child: Text('Gagal memuat riwayat pelanggaran: $err'),
      ),
    );
  }
}
