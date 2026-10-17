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
                    SizedBox(height: 24.h(context)),

                    // Tombol Submit
                    AniseButton(
                      text: isSubmitting ? 'Mengirim Tugas...' : (_isSubmitted ? 'Perbarui Jawaban Sekarang' : 'Kirim Tugas Sekarang'),
                      isLoading: isSubmitting,
                      icon: PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.bold),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (pickedFile == null && textController.text.trim().isEmpty && _submission == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Harap masukkan jawaban teks atau lampirkan berkas.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              setModalState(() {
                                isSubmitting = true;
                              });

                              final success = await ref.read(tugasProvider.notifier).submitTugas(
                                    taskId: widget.taskId,
                                    answerText: textController.text.trim(),
                                    attachment: pickedFile,
                                  );

                              setModalState(() {
                                isSubmitting = false;
                              });

                              if (success) {
                                ref.invalidate(getTasksProvider);
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tugas berhasil dikumpulkan!'),
                                      backgroundColor: AppColors.secondary,
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Gagal mengirim tugas. Periksa koneksi internet.'),
                                      backgroundColor: AppColors.error,
                                    ),
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
    final hasScore = _submission != null && _submission!['score'] != null;
    final score = hasScore ? _submission!['score'] : null;
    final feedback = _submission?['feedback']?.toString();

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
            // Mapel & Guru Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8.w(context)),
                  ),
                  child: Text(
                    widget.subject,
                    style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Text(
                    'Guru: ${widget.teacher}',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h(context)),

            // Judul Tugas
            Text(
              widget.title,
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
                color: _isSubmitted
                    ? AppColors.secondary.withValues(alpha: 0.1)
                    : (widget.status == 'Terlewat'
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primaryContainer.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14.w(context)),
                border: Border.all(
                  color: _isSubmitted
                      ? AppColors.secondary.withValues(alpha: 0.3)
                      : (widget.status == 'Terlewat'
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.primary.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSubmitted
                        ? PhosphorIcons.checkCircle(PhosphorIconsStyle.bold)
                        : (widget.status == 'Terlewat' ? PhosphorIcons.warningCircle(PhosphorIconsStyle.bold) : PhosphorIcons.timer(PhosphorIconsStyle.bold)),
                    color: _isSubmitted
                        ? AppColors.secondary
                        : (widget.status == 'Terlewat' ? AppColors.error : AppColors.primary),
                    size: 22.w(context),
                  ),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isSubmitted
                              ? 'Status: Selesai Dikerjakan'
                              : (widget.status == 'Terlewat' ? 'Status: Terlewat' : 'Batas Waktu Pengumpulan'),
                          style: AppTextStyles.labelMedium(
                            context,
                            color: _isSubmitted
                                ? AppColors.secondary
                                : (widget.status == 'Terlewat' ? AppColors.error : AppColors.primary),
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 2.h(context)),
                        Text(
                          widget.timeInfo,
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
                widget.description.isNotEmpty
                    ? widget.description
                    : 'Tidak ada catatan instruksi tambahan dari guru pengajar untuk tugas ini.',
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
              ),
            ),
            SizedBox(height: 20.h(context)),

            // Lampiran Materi dari Guru
            if (widget.attachments != null && widget.attachments!.isNotEmpty) ...[
              Text(
                'Lampiran Tugas dari Guru',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h(context)),
              ...widget.attachments!.map((att) {
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
            if (_isSubmitted && _submission != null) ...[
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
                    Row(
                      children: [
                        Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 18.w(context)),
                        SizedBox(width: 8.w(context)),
                        Text(
                          'Tugas Telah Dikumpulkan' + (_submission!['submitted_at'] != null ? ' (${_submission!['submitted_at']})' : ''),
                          style: AppTextStyles.labelMedium(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    if (_submission!['answer_text'] != null && _submission!['answer_text'].toString().isNotEmpty) ...[
                      SizedBox(height: 10.h(context)),
                      Text(
                        'Catatan Jawaban:',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                      ),
                      SizedBox(height: 2.h(context)),
                      Text(
                        _submission!['answer_text'].toString(),
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      ),
                    ],
                    if (_submission!['attachment_url'] != null && _submission!['attachment_url'].toString().isNotEmpty) ...[
                      SizedBox(height: 12.h(context)),
                      GestureDetector(
                        onTap: () => _downloadAttachment(
                          _submission!['attachment_url'].toString(), 
                          'Jawaban_Saya.pdf',
                          submissionId: _submission!['id']?.toString(),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8.w(context)),
                            border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIcons.fileArrowDown(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                              SizedBox(width: 8.w(context)),
                              Text(
                                'Unduh Kembali Berkas Terkirim',
                                style: AppTextStyles.bodySmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
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
              ],
              AniseButton(
                text: hasScore
                    ? 'Tugas Sudah Dinilai (Terkunci)'
                    : (_isSubmitted ? 'Perbarui Jawaban Tugas' : 'Kumpulkan Tugas Sekarang'),
                icon: hasScore
                    ? PhosphorIcons.lockKey(PhosphorIconsStyle.bold)
                    : (_isSubmitted ? PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold) : PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold)),
                onPressed: hasScore ? null : () => _showSubmitModal(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
