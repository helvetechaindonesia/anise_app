import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/file_download_helper.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
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

          // Keterangan Lokasi GPS Asli & Bukti Foto Wajah Auto Jepret
          if (item['latitude'] != null || item['face_snapshot_url'] != null) ...[
            SizedBox(height: 10.h(context)),
            Container(
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  // Thumbnail Foto Wajah
                  if (item['face_snapshot_url'] != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.w(context)),
                      child: Container(
                        width: 48.w(context),
                        height: 48.w(context),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: Image.network(
                          "${ApiConstants.baseUrl.replaceAll('/api', '')}/storage/${item['face_snapshot_url']}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            PhosphorIcons.user(PhosphorIconsStyle.bold),
                            size: 24.w(context),
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w(context)),
                  ],

                  // Detail Lokasi Koordinat Asli
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                              size: 14.w(context),
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w(context)),
                            Text(
                              'Lokasi Asli Pemohon',
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h(context)),
                        Text(
                          item['location_name'] ?? (item['latitude'] != null ? "GPS: ${item['latitude']}, ${item['longitude']}" : "Lokasi Tidak Terdeteksi"),
                          style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.75)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Lampiran Surat / Bukti jika diunggah (Bisa Didownload Terstandarisasi)
          if (item['attachment_path'] != null) ...[
            SizedBox(height: 8.h(context)),
            Builder(builder: (context) {
              final rawPath = item['attachment_path'].toString();
              final ext = rawPath.contains('.') ? rawPath.split('.').last : 'pdf';
              
              // Kategori (Izin, Sakit, Dispensasi)
              final formattedCategory = type.isNotEmpty ? "${type[0]}${type.substring(1).toLowerCase()}" : "Izin";
              // Siswa name
              final cleanStudentName = studentName.trim().replaceAll(RegExp(r'\s+'), '_');
              // Tingkat & Kelas
              final gradeLevel = item['user']?['student_class']?['grade_level'] ?? item['user']?['siswa_profile']?['school_class']?['grade_level'] ?? '';
              final tingkatStr = gradeLevel.toString().isNotEmpty ? "Kelas_${gradeLevel}" : "Kelas";
              final cleanClassName = (item['user']?['student_class']?['name'] ?? item['user']?['class_name'] ?? className).toString().trim().replaceAll(RegExp(r'\s+'), '_');
              
              // Tanggal DD_MM_YYYY
              String dateFormatted = '';
              try {
                final parsedDate = DateTime.parse(startDate);
                final d = parsedDate.day.toString().padLeft(2, '0');
                final m = parsedDate.month.toString().padLeft(2, '0');
                final y = parsedDate.year.toString();
                dateFormatted = "${d}_${m}_${y}";
              } catch (_) {
                final now = DateTime.now();
                dateFormatted = "${now.day.toString().padLeft(2, '0')}_${now.month.toString().padLeft(2, '0')}_${now.year}";
              }

              // Format yang diminta: {Kategori Perijinan}_{Nama Siswa}_{Tingkat}_{Nama Kelas}_{DD/MM/YYYY}.ext (menggunakan _ agar aman di file system)
              final standardFileName = "${formattedCategory}_${cleanStudentName}_${tingkatStr}_${cleanClassName}_${dateFormatted}.$ext";
              final downloadApiUrl = "/leaves/${item['id']}/download";

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.fileText(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
                    SizedBox(width: 8.w(context)),
                    Expanded(
                      child: Text(
                        standardFileName,
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        FileDownloadHelper.downloadFile(
                          context: context,
                          fileUrl: downloadApiUrl,
                          preferredFileName: standardFileName,
                        );
                      },
                      borderRadius: BorderRadius.circular(6.w(context)),
                      child: Padding(
                        padding: EdgeInsets.all(4.w(context)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.primary),
                            SizedBox(width: 4.w(context)),
                            Text(
                              'Unduh',
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

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
