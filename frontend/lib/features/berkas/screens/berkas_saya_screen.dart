import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/utils/file_download_helper.dart';

final filesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users/files');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    rethrow;
  }
});

class BerkasSayaScreen extends ConsumerWidget {
  const BerkasSayaScreen({super.key});

  void _downloadFile(BuildContext context, dynamic file) {
    final fileUrl = file['file_url']?.toString() ?? '';
    final title = file['title']?.toString() ?? 'Dokumen';
    final type = file['type']?.toString() ?? 'pdf';
    final fileName = title.endsWith(".$type") ? title : "$title.$type";

    FileDownloadHelper.downloadFile(
      context: context,
      fileUrl: fileUrl,
      preferredFileName: fileName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(filesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'E-File',
      ),
      body: filesAsync.when(
        data: (files) {
          if (files.isEmpty) {
            return const AniseEmptyState(
              icon: PhosphorIconsRegular.folderDashed,
              title: 'Belum Ada Berkas',
              subtitle: 'Seluruh berkas yang Anda unggah di berbagai modul akan tersimpan secara otomatis di sini.',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.refresh(filesProvider),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
              itemCount: files.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h(context)),
              itemBuilder: (context, index) {
                final file = files[index];
                IconData iconData;

                final type = file['type']?.toString().toLowerCase() ?? '';
                if (type == 'pdf') {
                  iconData = PhosphorIcons.filePdf(PhosphorIconsStyle.bold);
                } else if (type == 'doc' || type == 'docx') {
                  iconData = PhosphorIcons.fileDoc(PhosphorIconsStyle.bold);
                } else if (type == 'xls' || type == 'xlsx') {
                  iconData = PhosphorIcons.fileXls(PhosphorIconsStyle.bold);
                } else if (type == 'ppt' || type == 'pptx') {
                  iconData = PhosphorIcons.filePpt(PhosphorIconsStyle.bold);
                } else if (type == 'jpg' || type == 'jpeg' || type == 'png') {
                  iconData = PhosphorIcons.fileImage(PhosphorIconsStyle.bold);
                } else {
                  iconData = PhosphorIcons.fileText(PhosphorIconsStyle.bold);
                }

                String dateStr = '-';
                if (file['created_at'] != null) {
                  try {
                    final date = DateTime.parse(file['created_at'].toString());
                    dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
                  } catch (_) {
                    dateStr = file['created_at'].toString();
                  }
                }

                final source = file['source']?.toString() ?? 'Modul';
                final sizeStr = file['size']?.toString() ?? '';

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.w(context)),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                  child: Row(
                    children: [
                      // Ikon Format Berkas
                      Container(
                        padding: EdgeInsets.all(12.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12.w(context)),
                        ),
                        child: Icon(iconData, color: AppColors.primary, size: 24.w(context)),
                      ),
                      SizedBox(width: 14.w(context)),

                      // Keterangan File & Sumber Modul
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['title']?.toString() ?? 'Berkas',
                              style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h(context)),
                            Row(
                              children: [
                                // Badge Sumber Modul
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4.w(context)),
                                  ),
                                  child: Text(
                                    source,
                                    style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w(context)),
                                Expanded(
                                  child: Text(
                                    sizeStr.isNotEmpty ? "$dateStr • $sizeStr" : dateStr,
                                    style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w(context)),

                      // Tombol Download Ulang (Read-only, no edit, no delete)
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
                        ),
                        icon: Icon(
                          PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold),
                          color: AppColors.primary,
                          size: 20.w(context),
                        ),
                        tooltip: 'Unduh Berkas',
                        onPressed: () => _downloadFile(context, file),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => const AniseEmptyState(
          icon: PhosphorIconsRegular.warningCircle,
          title: 'Gagal Memuat Berkas',
          subtitle: 'Terjadi kendala saat menghubungkan ke penyimpanan e-file.',
        ),
      ),
    );
  }
}
