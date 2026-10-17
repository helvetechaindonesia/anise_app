import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/file_download_helper.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_card.dart';

class GuruJurnalDetailScreen extends StatelessWidget {
  final Map<String, dynamic> journal;

  const GuruJurnalDetailScreen({
    Key? key,
    required this.journal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subjectName = journal['subject'] ?? 'Mata Pelajaran';
    final className = journal['class_name'] ?? journal['class'] ?? 'Kelas';
    final timeRange = (journal['start_time'] != null && journal['end_time'] != null)
        ? '${journal['start_time']} - ${journal['end_time']}'
        : (journal['time'] ?? '08:00 - 09:30');
    final topic = journal['topic'] ?? journal['title'] ?? 'Topik Pembelajaran';
    final description = journal['description'] ?? 'Belum ada catatan deskripsi materi.';
    final classNotes = journal['class_notes'];
    final attachmentUrl = journal['attachment_url'];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Detail Jurnal',
        subtitle: '$subjectName • $className',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 20.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Info Jadwal
            _buildSectionTitle(context, 'Informasi Jadwal', PhosphorIcons.calendar(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 12),
            AniseCard(
              padding: EdgeInsets.all(16.w(context)),
              child: Column(
                children: [
                  _buildInfoRow(context, 'Kelas', className, PhosphorIcons.usersThree(PhosphorIconsStyle.regular)),
                  Divider(color: AppColors.outline.withValues(alpha: 0.15), height: 24.h(context)),
                  _buildInfoRow(context, 'Mata Pelajaran', subjectName, PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular)),
                  Divider(color: AppColors.outline.withValues(alpha: 0.15), height: 24.h(context)),
                  _buildInfoRow(context, 'Waktu / Jam Pembelajaran', timeRange, PhosphorIcons.clock(PhosphorIconsStyle.regular)),
                ],
              ),
            ),

            Spacing.custom(context, 24),

            // 2. Catatan Jurnal & Materi Pembelajaran
            _buildSectionTitle(context, 'Rencana & Catatan KBM', PhosphorIcons.notePencil(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 12),
            AniseCard(
              color: AppColors.primaryContainer.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              padding: EdgeInsets.all(18.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topik Pembahasan (Micro-RPP)',
                    style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    topic,
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 14.h(context)),
                  Text(
                    'Deskripsi / Skenario KBM',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)).copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                  ),
                  if (classNotes != null && classNotes.toString().trim().isNotEmpty) ...[
                    SizedBox(height: 14.h(context)),
                    Divider(color: AppColors.primary.withValues(alpha: 0.2), height: 1),
                    SizedBox(height: 12.h(context)),
                    Text(
                      'Catatan Dinamika & Evaluasi Kelas',
                      style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6.h(context)),
                    Text(
                      classNotes.toString(),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),

            Spacing.custom(context, 24),

            // 3. Lampiran Materi
            _buildSectionTitle(context, 'Lampiran Materi / Dokumen', PhosphorIcons.fileText(PhosphorIconsStyle.bold)),
            Spacing.custom(context, 12),
            if (attachmentUrl != null && attachmentUrl.toString().trim().isNotEmpty)
              AniseCard(
                padding: EdgeInsets.all(16.w(context)),
                onTap: () async {
                  await FileDownloadHelper.downloadFile(
                    context: context,
                    fileUrl: attachmentUrl.toString(),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.w(context)),
                      ),
                      child: Icon(PhosphorIcons.paperclip(PhosphorIconsStyle.bold), color: AppColors.primary, size: 22.w(context)),
                    ),
                    SizedBox(width: 14.w(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Berkas Lampiran Pembelajaran',
                            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 2.h(context)),
                          Text(
                            attachmentUrl.toString().split('/').last,
                            style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 16.w(context)),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.files(PhosphorIconsStyle.regular), color: AppColors.onBackground.withValues(alpha: 0.4), size: 36.w(context)),
                      SizedBox(height: 8.h(context)),
                      Text(
                        'Tidak ada lampiran dokumen pada jurnal ini',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),

            Spacing.custom(context, 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.onPrimaryContainer, size: 16.w(context)),
        ),
        SizedBox(width: 10.w(context)),
        Text(
          title,
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8.w(context)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18.w(context)),
        ),
        SizedBox(width: 14.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
              SizedBox(height: 2.h(context)),
              Text(
                value,
                style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
