import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/file_download_helper.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../providers/tugas_provider.dart';

class TugasDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String subject;
  final String teacher;
  final String title;
  final String timeInfo;
  final String description;
  final String status;
  final bool isSubmitted;
  final Map<String, dynamic>? submission;
  final List<dynamic>? attachments;

  const TugasDetailScreen({
    super.key,
    required this.taskId,
    required this.subject,
    required this.teacher,
    required this.title,
    required this.timeInfo,
    this.description = '',
    this.status = 'Belum Dikerjakan',
    this.isSubmitted = false,
    this.submission,
    this.attachments,
  });

  @override
  ConsumerState<TugasDetailScreen> createState() => _TugasDetailScreenState();
}

class _TugasDetailScreenState extends ConsumerState<TugasDetailScreen> {
  late bool _isSubmitted;
  Map<String, dynamic>? _submission;
  bool _hasHandledDeletion = false;

  void _handleTaskDeleted() {
    if (_hasHandledDeletion || !mounted) return;
    _hasHandledDeletion = true;
    ref.invalidate(getTasksProvider);
    Navigator.pop(context);
    AniseFeedbackDialog.showWarning(
      context,
      title: 'Tugas Dihapus',
      message: 'Tugas ini telah dihapus atau ditarik oleh guru pengampu.',
    );
  }

  @override
  void initState() {
    super.initState();
    _isSubmitted = widget.isSubmitted;
    _submission = widget.submission;
  }

  void _downloadAttachment(String rawUrl, String fallbackName, {String? attachmentId, String? submissionId}) {
    String fullUrl = rawUrl.trim();
    if (attachmentId != null && attachmentId.isNotEmpty) {
      fullUrl = '/assignments/attachments/$attachmentId/download';
    } else if (submissionId != null && submissionId.isNotEmpty) {
      fullUrl = '/assignments/submissions/$submissionId/download';
    }

    if (fullUrl.isEmpty) return;

    FileDownloadHelper.downloadFile(
      context: context,
      fileUrl: fullUrl,
      preferredFileName: fallbackName,
    );
  }

  void _showSubmitModal(BuildContext context) {
    final textController = TextEditingController(text: _submission?['answer_text'] ?? '');
    File? pickedFile;
    String? pickedFileName;
    bool isSubmitting = false;
    double uploadProgress = 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w(context),
                right: 20.w(context),
                top: 20.h(context),
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.h(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w(context),
                        height: 4.h(context),
                        decoration: BoxDecoration(
                          color: AppColors.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),
                    Text(
                      _isSubmitted ? 'Perbarui Jawaban Tugas' : 'Kumpulkan Tugas',
                      style: AppTextStyles.titleLarge(context, color: AppColors.onSurface),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      widget.title,
                      style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 20.h(context)),

                    // Catatan Jawaban
                    Text(
                      'Jawaban Teks / Tautan Link (Opsional)',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h(context)),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan jawaban langsung, ringkasan, atau tautan berkas drive...',
                        hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h(context)),

                    // Unggah Berkas
                    Text(
                      'Unggah Berkas Tugas (PDF / Gambar / Zip, Maks 20 MB)',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h(context)),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'zip', 'rar'],
                          );
                          if (result != null && result.files.single.path != null) {
                            setModalState(() {
                              pickedFile = File(result.files.single.path!);
                              pickedFileName = result.files.single.name;
                            });
                          }
                        } catch (_) {}
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(14.w(context)),
                          border: Border.all(
                            color: pickedFile != null ? AppColors.primary : AppColors.outline.withValues(alpha: 0.2),
                            width: pickedFile != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w(context)),
                              decoration: BoxDecoration(
                                color: pickedFile != null ? AppColors.primaryContainer : AppColors.surface,
                                borderRadius: BorderRadius.circular(10.w(context)),
                              ),
                              child: Icon(
                                pickedFile != null ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold) : PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold),
                                color: pickedFile != null ? AppColors.primary : AppColors.onSurfaceVariant,
                                size: 20.w(context),
                              ),
                            ),
                            SizedBox(width: 12.w(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pickedFileName ?? (_submission?['attachment_url'] != null ? 'Berkas Telah Terlampir Sebelumnya' : 'Pilih Berkas Tugas'),
                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h(context)),
                                  Text(
                                    pickedFile != null
                                        ? '${(pickedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB'
                                        : 'Ketuk untuk memilih file dokumen di HP',
                                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            if (pickedFile != null)
                              IconButton(
                                icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.error),
                                onPressed: () {
                                  setModalState(() {
                                    pickedFile = null;
                                    pickedFileName = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Progress Bar saat mengunggah berkas
                    if (isSubmitting) ...[
                      SizedBox(height: 16.h(context)),
                      Container(
                        padding: EdgeInsets.all(12.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.w(context)),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 14.w(context),
                                      height: 14.w(context),
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                    ),
                                    SizedBox(width: 8.w(context)),
                                    Text(
                                      uploadProgress > 0 && uploadProgress < 1.0
                                          ? 'Mengunggah Berkas...'
                                          : 'Menyimpan Jawaban ke Server...',
                                      style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${(uploadProgress * 100).toInt()}%',
                                  style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h(context)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.w(context)),
                              child: LinearProgressIndicator(
                                value: uploadProgress > 0 ? uploadProgress : null,
                                backgroundColor: AppColors.outline.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 6.h(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 24.h(context)),

                    // Tombol Submit
                    AniseButton(
                      text: isSubmitting
                          ? (uploadProgress > 0 && uploadProgress < 1.0
                              ? 'Mengunggah Berkas (${(uploadProgress * 100).toInt()}%)...'
                              : 'Mengirim Tugas...')
                          : (_isSubmitted ? 'Perbarui Jawaban Sekarang' : 'Kirim Tugas Sekarang'),
                      isLoading: isSubmitting,
                      icon: PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.bold),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (pickedFile == null && textController.text.trim().isEmpty && _submission == null) {
                                AniseFeedbackDialog.showWarning(
                                  context,
                                  title: 'Jawaban Masih Kosong',
                                  message: 'Harap masukkan jawaban teks atau lampirkan berkas jawaban.',
                                );
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                                uploadProgress = 0.05;
                              });

                              final success = await ref.read(tugasProvider.notifier).submitTugas(
                                    taskId: widget.taskId,
                                    answerText: textController.text.trim(),
                                    attachment: pickedFile,
                                    onProgress: (progress) {
                                      setModalState(() {
                                        uploadProgress = progress;
                                      });
                                    },
                                  );

                              setModalState(() {
                                isSubmitting = false;
                              });

                              if (success) {
                                ref.invalidate(getTasksProvider);
                                ref.invalidate(siswaTaskDetailProvider(widget.taskId));
                                if (bottomSheetContext.mounted) {
                                  Navigator.pop(bottomSheetContext);
                                }
                                if (context.mounted) {
                                  setState(() {
                                    _isSubmitted = true;
                                    _submission = {
                                      'status': 'SUBMITTED',
                                      'answer_text': textController.text.trim(),
                                      'submitted_at': 'Baru saja',
                                      if (pickedFile != null) 'attachment_url': 'uploaded',
                                    };
                                  });
                                  AniseFeedbackDialog.showSuccess(
                                    context,
                                    title: 'Tugas Dikumpulkan',
                                    message: 'Tugas Anda berhasil dikirimkan ke guru pengampu.',
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  AniseFeedbackDialog.showError(
                                    context,
                                    title: 'Pengiriman Gagal',
                                    message: 'Gagal mengirim tugas. Periksa koneksi internet atau ukuran berkas.',
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLateRequestModal(BuildContext context) {
    final reasonController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w(context),
                right: 24.w(context),
                top: 24.h(context),
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w(context),
                        height: 4.h(context),
                        decoration: BoxDecoration(
                          color: AppColors.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),
                    Text(
                      'Permohonan Mengumpulkan Tugas',
                      style: AppTextStyles.titleLarge(context, color: AppColors.onSurface),
                    ),
                    SizedBox(height: 6.h(context)),
                    Text(
                      'Tenggat waktu tugas ini telah berakhir. Tuliskan permohonan, alasan keterlambatan, atau ucapan maaf kepada guru pengampu untuk membuka kembali akses pengumpulan tugas.',
                      style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                    ),
                    SizedBox(height: 16.h(context)),

                    Text(
                      'Alasan / Ucapan Maaf',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6.h(context)),
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan keterlambatan atau permohonan...',
                        hintStyle: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.w(context)),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h(context)),

                    AniseButton(
                      text: isSubmitting ? 'Mengirimkan Permohonan...' : 'Kirim Permohonan ke Guru',
                      icon: PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.bold),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final text = reasonController.text.trim();
                              if (text.length < 5) {
                                AniseFeedbackDialog.showWarning(
                                  context,
                                  title: 'Alasan Belum Lengkap',
                                  message: 'Harap tuliskan alasan atau permohonan minimal 5 karakter.',
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final success = await ref.read(tugasProvider.notifier).requestLateSubmission(
                                taskId: widget.taskId,
                                reason: text,
                              );

                              setModalState(() => isSubmitting = false);

                              if (success) {
                                ref.invalidate(getTasksProvider);
                                ref.invalidate(siswaTaskDetailProvider(widget.taskId));
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  AniseFeedbackDialog.showSuccess(
                                    context,
                                    title: 'Permohonan Terkirim',
                                    message: 'Permohonan Anda berhasil dikirim ke guru pengampu. Silakan tunggu konfirmasi melalui notifikasi.',
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  AniseFeedbackDialog.showError(
                                    context,
                                    title: 'Gagal Mengirim',
                                    message: 'Terjadi kendala saat mengirim permohonan. Periksa koneksi internet Anda.',
                                  );
                                }
                              }
                            },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen perubahan realtime: jika tugas dihapus guru saat siswa di halaman ini, langsung redirect
    ref.listen<AsyncValue<Map<String, dynamic>>>(siswaTaskDetailProvider(widget.taskId), (prev, next) {
      final data = next.asData?.value;
      if (data?['is_deleted'] == true) {
        _handleTaskDeleted();
      }
    });

    final taskDetailAsync = ref.watch(siswaTaskDetailProvider(widget.taskId));
    final liveData = taskDetailAsync.asData?.value;

    if (liveData?['is_deleted'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleTaskDeleted());
      return const Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final currentSubmission = liveData?['submission'] ?? _submission;
    final currentIsSubmitted = liveData?['is_submitted'] ?? _isSubmitted;
    final currentStatus = liveData?['status'] ?? widget.status;
    final currentTimeInfo = liveData?['due_date_formatted'] ?? widget.timeInfo;
    final currentDescription = liveData?['description'] ?? widget.description;
    final currentAttachments = liveData?['attachments'] ?? widget.attachments;
    final currentTeacher = liveData?['teacher'] ?? widget.teacher;
    final currentSubject = liveData?['subject'] ?? widget.subject;
    final currentTitle = liveData?['title'] ?? widget.title;
    final lateRequest = liveData?['late_request'] as Map<String, dynamic>?;

    final hasScore = currentSubmission != null && currentSubmission['score'] != null;
    final score = hasScore ? currentSubmission['score'] : null;
    final feedback = currentSubmission?['feedback']?.toString();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Tugas',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mapel & Guru Header (Nama guru di bawah mapel)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8.w(context)),
                  ),
                  child: Text(
                    currentSubject,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 6.h(context)),
                Row(
                  children: [
                    Icon(PhosphorIcons.user(PhosphorIconsStyle.regular), size: 14.w(context), color: AppColors.onBackground.withValues(alpha: 0.6)),
                    SizedBox(width: 4.w(context)),
                    Expanded(
                      child: Text(
                        'Guru Pengampu: $currentTeacher',
                        style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h(context)),

            // Judul Tugas
            Text(
              currentTitle,
              style: AppTextStyles.titleLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h(context)),

            // Nilai Card (jika sudah dinilai guru)
            if (hasScore) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w(context)),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIcons.trophy(PhosphorIconsStyle.fill), color: AppColors.onSecondary, size: 24.w(context)),
                    ),
                    SizedBox(width: 14.w(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nilai Tugas Anda',
                            style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
                          ),
                          SizedBox(height: 2.h(context)),
                          Text(
                            '$score / 100',
                            style: AppTextStyles.headlineSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (feedback != null && feedback.isNotEmpty) ...[
                            SizedBox(height: 4.h(context)),
                            Text(
                              'Catatan Guru: "$feedback"',
                              style: AppTextStyles.bodySmall(context, color: AppColors.onSurface).copyWith(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h(context)),
            ],

            // Batas Waktu Card
            Container(
              padding: EdgeInsets.all(14.w(context)),
              decoration: BoxDecoration(
                color: currentIsSubmitted
                    ? AppColors.secondary.withValues(alpha: 0.1)
                    : (currentStatus == 'Terlewat'
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primaryContainer.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14.w(context)),
                border: Border.all(
                  color: currentIsSubmitted
                      ? AppColors.secondary.withValues(alpha: 0.3)
                      : (currentStatus == 'Terlewat'
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    currentIsSubmitted
                        ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)
                        : (currentStatus == 'Terlewat' ? PhosphorIcons.warningCircle(PhosphorIconsStyle.bold) : PhosphorIcons.timer(PhosphorIconsStyle.bold)),
                    color: currentIsSubmitted
                        ? AppColors.secondary
                        : (currentStatus == 'Terlewat' ? AppColors.error : AppColors.primary),
                    size: 22.w(context),
                  ),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentIsSubmitted
                              ? 'Status: Selesai Dikerjakan'
                              : (currentStatus == 'Terlewat' ? 'Status: Terlewat' : 'Batas Waktu Pengumpulan'),
                          style: AppTextStyles.labelMedium(
                            context,
                            color: currentIsSubmitted
                                ? AppColors.secondary
                                : (currentStatus == 'Terlewat' ? AppColors.error : AppColors.primary),
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2.h(context)),
                        Text(
                          currentTimeInfo,
                          style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h(context)),

            // Petunjuk Pengerjaan Tugas
            Text(
              'Instruksi Pengerjaan',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
              ),
              child: Text(
                currentDescription.isNotEmpty
                    ? currentDescription
                    : 'Tidak ada catatan instruksi tambahan dari guru pengajar untuk tugas ini.',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
              ),
            ),
            SizedBox(height: 20.h(context)),

            // Lampiran Materi dari Guru
            if (currentAttachments != null && currentAttachments.isNotEmpty) ...[
              Text(
                'Lampiran Tugas dari Guru',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h(context)),
              ...currentAttachments.map((att) {
                final attMap = att is Map ? att : {};
                final fileName = attMap['name']?.toString() ?? 'Lampiran_Tugas.pdf';
                final fileUrl = attMap['url']?.toString() ?? '';

                return Container(
                  margin: EdgeInsets.only(bottom: 10.h(context)),
                  padding: EdgeInsets.all(14.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14.w(context)),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10.w(context)),
                        ),
                        child: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 20.w(context)),
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h(context)),
                            Text(
                              'Berkas Materi / Soal',
                              style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      if (fileUrl.isNotEmpty)
                        IconButton(
                          icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                          onPressed: () => _downloadAttachment(
                            fileUrl, 
                            fileName,
                            attachmentId: attMap['id']?.toString(),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 16.h(context)),
            ],

            // Rincian Jawaban yang telah dikirim oleh Siswa
            if (currentIsSubmitted && currentSubmission != null) ...[
              Text(
                'Jawaban Anda yang Terkirim',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h(context)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Pengumpulan & Waktu di bawahnya
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 20.w(context)),
                        SizedBox(width: 8.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tugas Telah Dikumpulkan',
                                style: AppTextStyles.labelLarge(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                              ),
                              if (currentSubmission['submitted_at'] != null) ...[
                                SizedBox(height: 2.h(context)),
                                Text(
                                  'Waktu kirim: ${currentSubmission['submitted_at']}',
                                  style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (currentSubmission['answer_text'] != null && currentSubmission['answer_text'].toString().isNotEmpty) ...[
                      SizedBox(height: 12.h(context)),
                      Text(
                        'Catatan Jawaban:',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h(context)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(10.w(context)),
                          border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          currentSubmission['answer_text'].toString(),
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                    if (currentSubmission['attachment_url'] != null && currentSubmission['attachment_url'].toString().isNotEmpty) ...[
                      SizedBox(height: 14.h(context)),
                      Text(
                        'Berkas Jawaban Terkirim:',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6.h(context)),
                      Container(
                        padding: EdgeInsets.all(14.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(14.w(context)),
                          border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10.w(context)),
                              ),
                              child: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 20.w(context)),
                            ),
                            SizedBox(width: 12.w(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Berkas Jawaban Anda',
                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h(context)),
                                  Text(
                                    'Jawaban Tugas Terlampir',
                                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                              onPressed: () => _downloadAttachment(
                                currentSubmission['attachment_url'].toString(), 
                                'Jawaban_Saya.pdf',
                                submissionId: currentSubmission['id']?.toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 20.h(context)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outline.withValues(alpha: 0.1)),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasScore) ...[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12.h(context)),
                  padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 10.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.w(context)),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.secondary),
                      SizedBox(width: 10.w(context)),
                      Expanded(
                        child: Text(
                          'Tugas ini sudah dinilai oleh guru (Nilai: $score). Jawaban tidak dapat diperbarui lagi.',
                          style: AppTextStyles.bodySmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (lateRequest != null) ...[
                // Banner Status Permohonan Mengumpulkan
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12.h(context)),
                  padding: EdgeInsets.all(12.w(context)),
                  decoration: BoxDecoration(
                    color: lateRequest['status'] == 'APPROVED'
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : (lateRequest['status'] == 'REJECTED'
                            ? AppColors.error.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(10.w(context)),
                    border: Border.all(
                      color: lateRequest['status'] == 'APPROVED'
                          ? AppColors.secondary.withValues(alpha: 0.3)
                          : (lateRequest['status'] == 'REJECTED'
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            lateRequest['status'] == 'APPROVED'
                                ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                                : (lateRequest['status'] == 'REJECTED'
                                    ? PhosphorIcons.xCircle(PhosphorIconsStyle.fill)
                                    : PhosphorIcons.hourglass(PhosphorIconsStyle.bold)),
                            size: 16.w(context),
                            color: lateRequest['status'] == 'APPROVED'
                                ? AppColors.secondary
                                : (lateRequest['status'] == 'REJECTED' ? AppColors.error : AppColors.primary),
                          ),
                          SizedBox(width: 8.w(context)),
                          Expanded(
                            child: Text(
                              lateRequest['status'] == 'APPROVED'
                                  ? 'Permohonan Disetujui Guru'
                                  : (lateRequest['status'] == 'REJECTED'
                                      ? 'Permohonan Ditolak Guru'
                                      : 'Permohonan Menunggu Konfirmasi Guru'),
                              style: AppTextStyles.labelMedium(context,
                                  color: lateRequest['status'] == 'APPROVED'
                                      ? AppColors.secondary
                                      : (lateRequest['status'] == 'REJECTED' ? AppColors.error : AppColors.primary))
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (lateRequest['teacher_note'] != null && lateRequest['teacher_note'].toString().isNotEmpty) ...[
                        SizedBox(height: 4.h(context)),
                        Text(
                          'Catatan Guru: "${lateRequest['teacher_note']}"',
                          style: AppTextStyles.bodySmall(context, color: AppColors.onSurface).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                      if (lateRequest['extended_until_formatted'] != null && lateRequest['status'] == 'APPROVED') ...[
                        SizedBox(height: 4.h(context)),
                        Text(
                          'Batas Waktu Tambahan: ${lateRequest['extended_until_formatted']}',
                          style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // Dynamic Action Button (Kumpulkan / Permohonan Mengumpulkan / Kunci)
              Builder(
                builder: (context) {
                  if (hasScore) {
                    return AniseButton(
                      text: 'Tugas Sudah Dinilai (Terkunci)',
                      icon: PhosphorIcons.lockKey(PhosphorIconsStyle.bold),
                      onPressed: null,
                    );
                  }

                  if (currentIsSubmitted) {
                    return AniseButton(
                      text: 'Perbarui Jawaban Tugas',
                      icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                      onPressed: () => _showSubmitModal(context),
                    );
                  }

                  final isLate = currentStatus == 'Terlewat';
                  final canSubmitAgain = lateRequest?['can_submit_again'] == true;
                  final isPendingRequest = lateRequest?['status'] == 'PENDING';
                  final isRejected = lateRequest?['status'] == 'REJECTED';
                  final isExpiredAfterApproved = lateRequest?['is_expired_after_approved'] == true;

                  if (isLate && !canSubmitAgain) {
                    // Jika permohonan ditolak atau masa toleransi 2x24 jam habis tanpa dikumpulkan: tombol terkunci permanen
                    final isPermanentlyLocked = isRejected || isExpiredAfterApproved;

                    return AniseButton(
                      text: isPendingRequest
                          ? 'Menunggu Konfirmasi'
                          : (isRejected
                              ? 'Permohonan Ditolak (Terkunci)'
                              : (isExpiredAfterApproved
                                  ? 'Batas Toleransi Berakhir'
                                  : 'Permohonan Mengumpulkan')),
                      icon: isPendingRequest
                          ? PhosphorIcons.hourglass(PhosphorIconsStyle.bold)
                          : (isPermanentlyLocked
                              ? PhosphorIcons.lockKey(PhosphorIconsStyle.bold)
                              : PhosphorIcons.handTap(PhosphorIconsStyle.bold)),
                      onPressed: (isPendingRequest || isPermanentlyLocked)
                          ? null
                          : () => _showLateRequestModal(context),
                    );
                  }

                  // Normal / Masa perpanjangan 2x24 jam yang disetujui
                  return AniseButton(
                    text: canSubmitAgain ? 'Kumpulkan Tugas (Masa Toleransi)' : 'Kumpulkan Tugas Sekarang',
                    icon: PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold),
                    onPressed: () => _showSubmitModal(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
