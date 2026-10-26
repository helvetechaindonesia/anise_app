import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../providers/leave_provider.dart';

class PerijinanScreen extends ConsumerStatefulWidget {
  const PerijinanScreen({super.key});

  @override
  ConsumerState<PerijinanScreen> createState() => _PerijinanScreenState();
}

class _PerijinanScreenState extends ConsumerState<PerijinanScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'IZIN', 'SAKIT', 'DISPENSASI'

  void _handleApproval(dynamic leaveId, String status) async {
    final success = await ref.read(leaveNotifierProvider.notifier).updateStatus(
      leaveId: leaveId,
      status: status,
    );

    if (success && mounted) {
      AniseFeedbackDialog.showSuccess(
        context,
        title: 'Status Diperbarui',
        message: 'Pengajuan perizinan berhasil ${status == 'APPROVED' ? 'disetujui' : 'ditolak'}.',
      );
    } else if (mounted) {
      AniseFeedbackDialog.showError(
        context,
        title: 'Gagal Memperbarui',
        message: 'Terjadi kendala saat memperbarui status perizinan.',
      );
    }
  }

  void _handleConfirmReturn(dynamic leaveId) async {
    final success = await ref.read(leaveNotifierProvider.notifier).confirmReturn(leaveId: leaveId);
    if (success && mounted) {
      AniseFeedbackDialog.showSuccess(
        context,
        title: 'Konfirmasi Berhasil',
        message: 'Siswa berhasil dikonfirmasi kembali dari dispensasi.',
      );
    } else if (mounted) {
      AniseFeedbackDialog.showError(
        context,
        title: 'Gagal Konfirmasi',
        message: 'Waktu konfirmasi lewat atau terjadi kendala.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inboxAsync = ref.watch(perijinanInboxProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Perijinan',
      ),
      body: Column(
        children: [
          // Filter Kategori
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 12.h(context)),
            color: AppColors.surface,
            child: Row(
              children: [
                _buildFilterChip('ALL', 'Semua'),
                SizedBox(width: 8.w(context)),
                _buildFilterChip('IZIN', 'Izin'),
                SizedBox(width: 8.w(context)),
                _buildFilterChip('SAKIT', 'Sakit'),
                SizedBox(width: 8.w(context)),
                _buildFilterChip('DISPENSASI', 'Dispensasi'),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.outline.withValues(alpha: 0.15)),

          // Daftar Item List
          Expanded(
            child: inboxAsync.when(
              data: (leaves) {
                final filteredLeaves = leaves.where((item) {
                  if (_selectedFilter == 'ALL') return true;
                  return item['type']?.toString().toUpperCase() == _selectedFilter;
                }).toList();

                if (filteredLeaves.isEmpty) {
                  return const AniseEmptyState(
                    title: 'Tidak Ada Permohonan',
                    subtitle: 'Belum ada permohonan perizinan siswa yang perlu diverifikasi.',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.refresh(perijinanInboxProvider),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                    itemCount: filteredLeaves.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h(context)),
                    itemBuilder: (context, index) {
                      final item = filteredLeaves[index];
                      return _buildLeaveItemTile(context, item);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, stack) => const AniseEmptyState(
                title: 'Gagal Memuat Data',
                subtitle: 'Terjadi kendala saat menghubungkan ke server perizinan.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String code, String label) {
    final isSelected = _selectedFilter == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = code),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 6.h(context)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20.w(context)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            context,
            color: isSelected ? AppColors.onPrimary : AppColors.primary,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildLeaveItemTile(BuildContext context, dynamic item) {
    final type = item['type']?.toString().toUpperCase() ?? 'IZIN';
    final status = item['status']?.toString().toUpperCase() ?? 'PENDING';
    final studentName = item['user']?['full_name'] ?? 'Siswa';
    final className = item['user']?['siswa_profile']?['school_class']?['name'] ?? 'Kelas';
    final reason = item['reason']?.toString() ?? '-';
    final startDate = item['start_date']?.toString() ?? '-';
    final endDate = item['end_date']?.toString() ?? '-';
    final dateRange = startDate == endDate ? startDate : "$startDate s/d $endDate";

    final Color badgeColor = type == 'DISPENSASI'
        ? AppColors.info
        : (type == 'SAKIT' ? AppColors.warning : AppColors.primary);

    final PhosphorIconData categoryIcon = type == 'DISPENSASI'
        ? PhosphorIcons.clockAfternoon(PhosphorIconsStyle.bold)
        : (type == 'SAKIT' ? PhosphorIcons.firstAid(PhosphorIconsStyle.bold) : PhosphorIcons.envelopeSimple(PhosphorIconsStyle.bold));

    final canConfirmReturn = item['can_confirm_return'] == true;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
      ),
      padding: EdgeInsets.all(14.w(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Kategori Terstandarisasi
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.w(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 14.w(context), color: badgeColor),
                    SizedBox(width: 4.w(context)),
                    Text(
                      type,
                      style: AppTextStyles.labelSmall(context, color: badgeColor).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              // Status Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: status == 'APPROVED'
                      ? AppColors.success.withValues(alpha: 0.15)
                      : (status == 'REJECTED' ? AppColors.error.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8.w(context)),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall(
                    context,
                    color: status == 'APPROVED' ? AppColors.success : (status == 'REJECTED' ? AppColors.error : AppColors.warning),
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),

          // Info Siswa & Kelas
          Text(
            studentName,
            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 2.h(context)),
          Text(
            "$className • $dateRange",
            style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
          ),
          SizedBox(height: 8.h(context)),

          // Alasan
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w(context)),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8.w(context)),
            ),
            child: Text(
              reason,
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
            ),
          ),

          // Tombol Aksi Approval / Konfirmasi Kembali
          if (status == 'PENDING') ...[
            SizedBox(height: 12.h(context)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
                    ),
                    icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 16.w(context)),
                    label: Text('Tolak', style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w700)),
                    onPressed: () => _handleApproval(item['id'], 'REJECTED'),
                  ),
                ),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
                    ),
                    icon: Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 16.w(context)),
                    label: Text('Setujui', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700)),
                    onPressed: () => _handleApproval(item['id'], 'APPROVED'),
                  ),
                ),
              ],
            ),
          ] else if (canConfirmReturn) ...[
            SizedBox(height: 12.h(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
                ),
                icon: Icon(PhosphorIcons.arrowBendDownLeft(PhosphorIconsStyle.bold), size: 16.w(context)),
                label: Text(
                  'Konfirmasi Siswa Kembali ke Sekolah',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700),
                ),
                onPressed: () => _handleConfirmReturn(item['id']),
              ),
            ),
          ] else if (item['returned_at'] != null) ...[
            SizedBox(height: 8.h(context)),
            Text(
              "Telah kembali ke sekolah: ${item['returned_at']}",
              style: AppTextStyles.labelSmall(context, color: AppColors.success).copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}
