import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';

final filesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/files');
    if (response.data['status'] == 'success') {
      return response.data['data'] as List<dynamic>;
    }
    return [];
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) return [];
    rethrow;
  }
});

class BerkasSayaScreen extends ConsumerStatefulWidget {
  const BerkasSayaScreen({super.key});

  @override
  ConsumerState<BerkasSayaScreen> createState() => _BerkasSayaScreenState();
}

class _BerkasSayaScreenState extends ConsumerState<BerkasSayaScreen> {
  bool _isUploading = false;

  Future<void> _pickFile() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        if (file.path == null) return;
        
        setState(() => _isUploading = true);
        
        final dio = ref.read(dioProvider);
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path!),
        });
        
        await dio.post('/files/upload', data: formData);
        
        ref.invalidate(filesProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File berhasil diunggah')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(filesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text('Berkas Saya', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 20.w(context)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickFile,
        backgroundColor: AppColors.primary,
        icon: _isUploading
            ? SizedBox(width: 24.w(context), height: 24.w(context), child: const CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
            : Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), color: AppColors.onPrimary),
        label: Text(_isUploading ? 'Mengunggah...' : 'Unggah File', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary)),
      ),
      body: filesAsync.when(
        data: (files) {
          if (files.isEmpty) {
            return Center(
              child: Text(
                'Belum ada file',
                style: AppTextStyles.bodyLarge(context, color: AppColors.onSurfaceVariant),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(filesProvider),
            child: ListView.separated(
              itemCount: files.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.outline),
              itemBuilder: (context, index) {
                final file = files[index];
                IconData iconData;

                final type = file['type']?.toLowerCase() ?? '';
                if (type == 'pdf') {
                  iconData = PhosphorIcons.filePdf(PhosphorIconsStyle.bold);
                } else if (type == 'doc' || type == 'docx') {
                  iconData = PhosphorIcons.fileDoc(PhosphorIconsStyle.bold);
                } else if (type == 'xls' || type == 'xlsx') {
                  iconData = PhosphorIcons.fileXls(PhosphorIconsStyle.bold);
                } else if (type == 'ppt' || type == 'pptx') {
                  iconData = PhosphorIcons.filePpt(PhosphorIconsStyle.bold);
                } else {
                  iconData = PhosphorIcons.fileText(PhosphorIconsStyle.bold);
                }

                final date = DateTime.parse(file['created_at']);
                final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
                  leading: Container(
                    padding: EdgeInsets.all(12.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Icon(iconData, color: AppColors.primary, size: 24.w(context)),
                  ),
                  title: Text(
                    file['title'],
                    style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4.h(context)),
                    child: Row(
                      children: [
                        Text(
                          dateStr,
                          style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w(context)),
                          child: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 4.w(context), color: AppColors.outline),
                        ),
                        Text(
                          file['size'],
                          style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold), color: AppColors.onBackground),
                    onPressed: () {},
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Gagal memuat file: $err')),
      ),
    );
  }
}
