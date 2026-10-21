import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/file_download_helper.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../providers/tugas_provider.dart';

class GuruTugasPenilaianScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String? title;
  final String? subject;
  final String? className;

  const GuruTugasPenilaianScreen({
    Key? key,
    this.taskId = '',
    this.title,
    this.subject,
    this.className,
  }) : super(key: key);

  @override
  ConsumerState<GuruTugasPenilaianScreen> createState() => _GuruTugasPenilaianScreenState();
}

class _GuruTugasPenilaianScreenState extends ConsumerState<GuruTugasPenilaianScreen> {
  void _openGradeSheet(BuildContext context, Map<String, dynamic> student) {
    final submissionId = student['submission_id']?.toString();
    if (submissionId == null || submissionId.isEmpty) {
      AniseFeedbackDialog.showWarning(
        context,
        title: 'Belum Ada Jawaban',
        message: 'Siswa belum mengumpulkan tugas secara digital.',
      );
      return;
    }

    final scoreController = TextEditingController(
      text: student['score'] != null ? student['score'].toString() : '',
    );
    final feedbackController = TextEditingController(
      text: student['feedback']?.toString() ?? '',
    );

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
                      'Beri Nilai Siswa',
                      style: AppTextStyles.titleLarge(context, color: AppColors.onSurface),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      '${student['name']} (${student['nisn'] ?? '-'})',
                      style: AppTextStyles.bodyMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 20.h(context)),

                    // Input Nilai (0 - 100)
                    Text(
                      'Skor Nilai (0 - 100)',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h(context)),
                    TextField(
                      controller: scoreController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 85',
                        hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        prefixIcon: Icon(PhosphorIcons.trophy(PhosphorIconsStyle.bold), color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h(context)),

                    // Input Catatan / Feedback
                    Text(
                      'Catatan Evaluasi / Feedback Guru (Opsional)',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8.h(context)),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan catatan apresiasi atau evaluasi untuk siswa ini...',
                        hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.w(context)),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h(context)),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 48.h(context),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.w(context)),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final text = scoreController.text.trim().replaceAll(',', '.');
                                final score = double.tryParse(text);
                                if (score == null || score < 0 || score > 100) {
                                  AniseFeedbackDialog.showWarning(
                                    context,
                                    title: 'Skor Tidak Valid',
                                    message: 'Masukkan skor nilai yang valid antara 0 sampai 100.',
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                });

                                final success = await ref.read(tugasProvider.notifier).gradeSubmission(
                                      submissionId: submissionId,
                                      score: score,
                                      feedback: feedbackController.text.trim(),
                                    );

                                setModalState(() {
                                  isSubmitting = false;
                                });

                                if (success) {
                                  ref.invalidate(taskSubmissionsProvider(widget.taskId));
                                  ref.invalidate(getTasksProvider);
                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                  if (mounted) {
                                    AniseFeedbackDialog.showSuccess(
                                      context,
                                      title: 'Nilai Tersimpan',
                                      message: 'Nilai dan evaluasi untuk ${student['name']} berhasil disimpan.',
                                    );
                                  }
                                } else {
                                  if (mounted) {
                                    AniseFeedbackDialog.showError(
                                      context,
                                      title: 'Gagal Menyimpan',
                                      message: 'Terjadi kendala saat menyimpan nilai. Periksa koneksi server Anda.',
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Simpan Nilai Siswa',
                                style: AppTextStyles.labelLarge(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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

  void _downloadStudentFile(String rawUrl, String studentName, {String? submissionId}) {
    String targetUrl = rawUrl.trim();
    if (submissionId != null && submissionId.isNotEmpty) {
      targetUrl = '/assignments/submissions/$submissionId/download';
    }

    if (targetUrl.isEmpty) return;

    final sanitizedName = studentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final ext = rawUrl.contains('.') ? rawUrl.split('.').last.split('?').first : 'pdf';
    final customFileName = 'Tugas_$sanitizedName.$ext';

    FileDownloadHelper.downloadFile(
      context: context,
      fileUrl: targetUrl,
      preferredFileName: customFileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync = ref.watch(taskSubmissionsProvider(widget.taskId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Penilaian Tugas',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              widget.className ?? 'Detail Kelas',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
      body: submissionsAsync.when(
        data: (data) {
          final task = data['task'] as Map<String, dynamic>? ?? {};
          final students = data['students'] as List<dynamic>? ?? [];

          final taskTitle = task['title']?.toString() ?? widget.title ?? 'Tugas';
          final subjectName = task['subject_name']?.toString() ?? widget.subject ?? 'Mata Pelajaran';
          final className = task['class_name']?.toString() ?? widget.className ?? '';
          final totalStudents = task['total_students'] ?? students.length;
          final submittedCount = task['submitted_count'] ?? students.where((s) => s['is_submitted'] == true).length;
          final gradedCount = task['graded_count'] ?? students.where((s) => s['score'] != null).length;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(taskSubmissionsProvider(widget.taskId));
            },
            child: Column(
              children: [
                _buildTaskHeader(
                  context,
                  title: taskTitle,
                  subject: subjectName,
                  className: className,
                  dueDate: task['due_date_formatted']?.toString() ?? '',
                  totalStudents: totalStudents,
                  submittedCount: submittedCount,
                  gradedCount: gradedCount,
                ),
                Expanded(
                  child: students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(PhosphorIcons.users(PhosphorIconsStyle.fill), size: 48.w(context), color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                              SizedBox(height: 12.h(context)),
                              Text(
                                'Belum ada data siswa di kelas ini.',
                                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index] as Map<String, dynamic>;
                            return _buildStudentCard(context, student);
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), size: 48.w(context), color: AppColors.error),
                SizedBox(height: 12.h(context)),
                Text(
                  'Gagal memuat data penilaian siswa: $error',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h(context)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => ref.invalidate(taskSubmissionsProvider(widget.taskId)),
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(
    BuildContext context, {
    required String title,
    required String subject,
    required String className,
    required String dueDate,
    required dynamic totalStudents,
    required dynamic submittedCount,
    required dynamic gradedCount,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.15))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Mapel & Tenggat Waktu di bawahnya
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
                  subject,
                  style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (dueDate.isNotEmpty) ...[
                SizedBox(height: 6.h(context)),
                Row(
                  children: [
                    Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), size: 14.w(context), color: AppColors.onSurfaceVariant),
                    SizedBox(width: 4.w(context)),
                    Text(
                      'Tenggat: $dueDate',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h(context)),
          Text(
            title,
            style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h(context)),
          Row(
            children: [
              _buildStatBadge(context, '$submittedCount/$totalStudents', 'Mengumpulkan', AppColors.secondary),
              SizedBox(width: 8.w(context)),
              _buildStatBadge(context, '$gradedCount/$totalStudents', 'Dinilai', AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.w(context)),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.labelMedium(context, color: color).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 4.w(context)),
          Text(
            label,
            style: AppTextStyles.labelSmall(context, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> student) {
    final bool isSubmitted = student['is_submitted'] == true;
    final bool isLate = student['is_late'] == true;
    final dynamic score = student['score'];
    final bool hasScore = score != null;
    final String statusText = student['status']?.toString() ?? (isSubmitted ? 'Sudah Mengumpulkan' : 'Belum Mengumpulkan');
    final String? answerText = student['answer_text']?.toString();
    final String? attachmentUrl = student['attachment_url']?.toString();
    final String? feedback = student['feedback']?.toString();

    Color statusColor = AppColors.error;
    if (hasScore) {
      statusColor = AppColors.primary;
    } else if (isSubmitted) {
      statusColor = isLate ? AppColors.warning : AppColors.secondary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h(context)),
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(
          color: hasScore
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isSubmitted ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.outline.withValues(alpha: 0.15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header Siswa
          Row(
            children: [
              CircleAvatar(
                radius: 18.w(context),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: student['avatar_url'] != null && student['avatar_url'].toString().isNotEmpty
                    ? NetworkImage(student['avatar_url'])
                    : null,
                child: student['avatar_url'] == null || student['avatar_url'].toString().isEmpty
                    ? Text(
                        (student['name']?.toString().isNotEmpty == true) ? student['name'][0].toUpperCase() : 'S',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14.w(context)),
                      )
                    : null,
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name']?.toString() ?? 'Siswa',
                      style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      statusText + (student['submitted_at'] != null ? ' â€¢ ${student['submitted_at']}' : ''),
                      style: AppTextStyles.labelSmall(context, color: statusColor).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (isSubmitted) ...[
                InkWell(
                  onTap: () => _openGradeSheet(context, student),
                  borderRadius: BorderRadius.circular(10.w(context)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
                    decoration: BoxDecoration(
                      color: hasScore ? AppColors.primary : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.w(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasScore ? PhosphorIcons.check(PhosphorIconsStyle.bold) : PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                          size: 14.w(context),
                          color: hasScore ? Colors.white : AppColors.primary,
                        ),
                        SizedBox(width: 4.w(context)),
                        Text(
                          hasScore ? '$score' : 'Beri Nilai',
                          style: AppTextStyles.labelMedium(context).copyWith(
                            color: hasScore ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Teks Jawaban Siswa jika ada
          if (answerText != null && answerText.trim().isNotEmpty) ...[
            SizedBox(height: 12.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan / Jawaban Siswa:',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    answerText,
                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
          ],

          // Lampiran Berkas Siswa jika ada (Standardized Card layout)
          if (attachmentUrl != null && attachmentUrl.isNotEmpty) ...[
            SizedBox(height: 10.h(context)),
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8.w(context)),
                    ),
                    child: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 18.w(context)),
                  ),
                  SizedBox(width: 10.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Berkas Jawaban Siswa',
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp(context)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h(context)),
                        Text(
                          'Ketuk unduh untuk memeriksa jawaban',
                          style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontSize: 10.sp(context)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                    onPressed: () => _downloadStudentFile(
                      attachmentUrl, 
                      student['name'] ?? 'Siswa',
                      submissionId: student['submission_id']?.toString(),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Feedback Guru jika sudah dinilai
          if (feedback != null && feedback.trim().isNotEmpty) ...[
            SizedBox(height: 8.h(context)),
            Text(
              'Catatan Guru: "$feedback"',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
