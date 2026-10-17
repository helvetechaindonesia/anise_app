import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../constants/api_constants.dart';
import '../theme/app_text_styles.dart';
import 'responsive.dart';
import 'shared_prefs.dart';
import 'local_notification_helper.dart';

class FileDownloadHelper {
  /// Mengunduh berkas langsung via Dio dan menyimpannya ke folder Download HP
  static Future<void> downloadFile({
    required BuildContext context,
    required String fileUrl,
    String? preferredFileName,
  }) async {
    if (fileUrl.trim().isEmpty) {
      _showSnackBar(context, 'Tautan berkas tidak valid.', isError: true);
      return;
    }

    String absoluteUrl = fileUrl.trim();
    if (!absoluteUrl.startsWith('http://') && !absoluteUrl.startsWith('https://')) {
      if (absoluteUrl.startsWith('/storage/')) {
        // Berkas statis di web server
        final serverHost = ApiConstants.baseUrl.replaceAll('/api', '');
        absoluteUrl = '$serverHost$absoluteUrl';
      } else {
        // Endpoint API (misal /journals/{id}/download)
        final cleanBase = ApiConstants.baseUrl.endsWith('/')
            ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
            : ApiConstants.baseUrl;
        final cleanPath = absoluteUrl.startsWith('/') ? absoluteUrl : '/$absoluteUrl';
        absoluteUrl = '$cleanBase$cleanPath';
      }
    }

    // Nama berkas
    String fileName = preferredFileName?.trim() ?? '';
    if (fileName.isEmpty) {
      fileName = absoluteUrl.split('?').first.split('/').last;
      if (fileName.isEmpty || fileName.contains('download')) {
        fileName = 'Dokumen_${DateTime.now().millisecondsSinceEpoch}.pdf';
      }
    }

    // Tampilkan notifikasi proses unduh
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    _showSnackBar(context, 'Sedang mengunduh $fileName...', isError: false, icon: PhosphorIcons.arrowClockwise(PhosphorIconsStyle.bold));

    try {
      Directory? targetDir;

      if (Platform.isAndroid) {
        // Folder Download publik di Android: /storage/emulated/0/Download
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          targetDir = downloadDir;
        } else {
          // Fallback ke getExternalStorageDirectory
          targetDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        targetDir = await getApplicationDocumentsDirectory();
      } else {
        // Windows / Desktop
        targetDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      if (targetDir == null) {
        throw Exception('Direktori penyimpanan unduhan tidak ditemukan.');
      }

      // Pastikan nama file unik jika sudah ada file dengan nama yang sama
      String savePath = '${targetDir.path}/$fileName';
      int counter = 1;
      final fileExtension = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      final baseName = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;

      while (await File(savePath).exists()) {
        savePath = '${targetDir.path}/${baseName}_($counter)$fileExtension';
        counter++;
      }

      final dio = Dio();
      final token = await SharedPrefs.getToken();
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      await dio.download(
        absoluteUrl,
        savePath,
        options: options,
      );

      // Trigger Push Notifikasi Sistem (Bisa diklik langsung buka berkas)
      final downloadedFileName = savePath.split('/').last;
      LocalNotificationHelper.showDownloadCompleteNotification(
        filePath: savePath,
        fileName: downloadedFileName,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: AppColors.onPrimary,
                size: 20.w(context),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Text(
                  'Tersimpan di Download: $downloadedFileName',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSnackBar(context, 'Gagal mengunduh: $e', isError: true);
    }
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? (isError ? PhosphorIcons.warningCircle(PhosphorIconsStyle.fill) : PhosphorIcons.info(PhosphorIconsStyle.fill)),
              color: AppColors.onPrimary,
              size: 20.w(context),
            ),
            SizedBox(width: 10.w(context)),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
