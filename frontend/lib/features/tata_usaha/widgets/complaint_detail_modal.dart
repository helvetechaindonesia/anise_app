import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/file_download_helper.dart';
import '../../lapor/models/complaint_model.dart';
import '../../lapor/providers/report_provider.dart';

class ComplaintDetailModal extends ConsumerStatefulWidget {
  final ComplaintModel complaint;
  final VoidCallback? onUpdated;

  const ComplaintDetailModal({
    super.key,
    required this.complaint,
    this.onUpdated,
  });

  static void show(BuildContext context, ComplaintModel complaint, {VoidCallback? onUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ComplaintDetailModal(
        complaint: complaint,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  ConsumerState<ComplaintDetailModal> createState() => _ComplaintDetailModalState();
}

class _ComplaintDetailModalState extends ConsumerState<ComplaintDetailModal> {
  late String _currentStatus;
  late TextEditingController _responseNoteController;
  bool _isSaving = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'PENDING', 'label': 'Menunggu'},
    {'value': 'IN_PROGRESS', 'label': 'Diproses'},
    {'value': 'RESOLVED', 'label': 'Selesai'},
    {'value': 'REJECTED', 'label': 'Ditolak'},
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.complaint.status;
    _responseNoteController = TextEditingController(text: widget.complaint.responseNote ?? '');
  }

  @override
  void dispose() {
    _responseNoteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final service = ref.read(complaintServiceProvider);
      await service.updateStatus(
        complaintId: widget.complaint.id,
        status: _currentStatus,
        responseNote: _responseNoteController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status dan tanggapan berhasil diperbarui'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      widget.onUpdated?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final dateStr = complaint.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(complaint.createdAt!)
        : '-';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12.h(context)),
              width: 44.w(context),
              height: 4.h(context),
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Category & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                        decoration: BoxDecoration(
                          color: complaint.categoryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.w(context)),
                        ),
                        child: Text(
                          complaint.categoryLabel,
                          style: AppTextStyles.labelSmall(context, color: complaint.categoryColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                        decoration: BoxDecoration(
                          color: complaint.statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.w(context)),
                        ),
                        child: Text(
                          complaint.statusLabel,
                          style: AppTextStyles.labelSmall(context, color: complaint.statusColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h(context)),

                  // Title
                  Text(
                    complaint.title,
                    style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 12.h(context)),

                  // Reporter Info & Date
                  Container(
                    padding: EdgeInsets.all(12.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12.w(context)),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          complaint.isAnonymous
                              ? PhosphorIcons.eyeSlash(PhosphorIconsStyle.bold)
                              : PhosphorIcons.user(PhosphorIconsStyle.bold),
                          color: complaint.isAnonymous ? AppColors.warning : AppColors.primary,
                          size: 20.w(context),
                        ),
                        SizedBox(width: 10.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complaint.isAnonymous
                                    ? 'Identitas Dirahasiakan (Anonim)'
                                    : (complaint.userName ?? 'Siswa Pelapor'),
                                style: AppTextStyles.bodyMedium(context,
                                    color: AppColors.onBackground,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Dikirim pada: $dateStr',
                                style: AppTextStyles.labelSmall(context,
                                    color: AppColors.onBackground.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Description
                  Text(
                    'Rincian Laporan',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 8.h(context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12.w(context)),
                      border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      complaint.description,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Attachment preview if exists
                  if (complaint.fullAttachmentUrl != null) ...[
                    Text(
                      'Foto Bukti Lampiran',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                    ),
                    SizedBox(height: 8.h(context)),
                    GestureDetector(
                      onTap: () {
                        // Open zoomable image dialog
                        showDialog(
                          context: context,
                          builder: (imgCtx) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.all(12.w(imgCtx)),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                InteractiveViewer(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.w(imgCtx)),
                                    child: Image.network(
                                      complaint.fullAttachmentUrl!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                                  onPressed: () => Navigator.pop(imgCtx),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.w(context)),
                        child: Container(
                          width: double.infinity,
                          height: 180.h(context),
                          color: AppColors.backgroundLight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                complaint.fullAttachmentUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(PhosphorIcons.warning(PhosphorIconsStyle.bold),
                                          color: AppColors.onSurfaceVariant, size: 32.w(context)),
                                      SizedBox(height: 6.h(context)),
                                      Text('Gagal memuat gambar',
                                          style: AppTextStyles.labelSmall(context)),
                                    ],
                                  ),
                                ),
                                loadingBuilder: (c, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                              ),
                              Positioned(
                                right: 8.w(context),
                                bottom: 8.h(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8.w(context)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(PhosphorIcons.magnifyingGlassPlus(PhosphorIconsStyle.bold),
                                          color: Colors.white, size: 14.w(context)),
                                      SizedBox(width: 4.w(context)),
                                      Text('Perbesar',
                                          style: AppTextStyles.labelSmall(context, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h(context)),
                    // Tombol Unduh / Download Lampiran
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold),
                          size: 16.w(context),
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'Unduh Foto / Lampiran',
                          style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
                          padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w(context)),
                          ),
                          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
                        ),
                        onPressed: () {
                          final downloadUrl = '/complaints/${complaint.id}/download';
                          final ext = complaint.attachmentUrl?.split('.').last.toLowerCase() ?? 'jpg';
                          final filename = 'Lampiran_${complaint.category}_${complaint.id.substring(0, 8)}.$ext';
                          FileDownloadHelper.downloadFile(
                            context: context,
                            fileUrl: downloadUrl,
                            preferredFileName: filename,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 18.h(context)),
                  ],

                  const Divider(),
                  SizedBox(height: 12.h(context)),

                  // TU Action: Update status & response
                  Text(
                    'Tindak Lanjut & Respon Sekolah',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 12.h(context)),

                  // Status Selector ChoiceChips
                  Text(
                    'Pilih Status Penanganan:',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 8.h(context)),
                  Wrap(
                    spacing: 8.w(context),
                    runSpacing: 8.h(context),
                    children: _statusOptions.map((opt) {
                      final isSelected = _currentStatus == opt['value'];
                      return ChoiceChip(
                        label: Text(opt['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _currentStatus = opt['value']!;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Response note textfield
                  Text(
                    'Catatan Respon Sekolah (Dilihat oleh Siswa):',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                  ),
                  SizedBox(height: 8.h(context)),
                  TextField(
                    controller: _responseNoteController,
                    maxLines: 3,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan catatan perbaikan, tindak lanjut, atau keterangan...',
                      hintStyle: AppTextStyles.bodyMedium(context,
                          color: AppColors.onSurface.withValues(alpha: 0.4)),
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      contentPadding: EdgeInsets.all(14.w(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.w(context)),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h(context)),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h(context),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Simpan Status & Tanggapan',
                              style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
                            ),
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
