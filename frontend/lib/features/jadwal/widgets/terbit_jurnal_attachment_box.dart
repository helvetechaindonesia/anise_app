import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class TerbitJurnalAttachmentBox extends StatelessWidget {
  final File? selectedFile;
  final String? fileName;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;

  const TerbitJurnalAttachmentBox({
    super.key,
    required this.selectedFile,
    required this.fileName,
    required this.onPickFile,
    required this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedFile != null) {
      final double sizeMb = selectedFile!.lengthSync() / (1024 * 1024);

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h(context), horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.w(context)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), color: AppColors.primary, size: 24.w(context)),
            ),
            SizedBox(width: 14.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName ?? 'Berkas Terpilih',
                    style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    '${sizeMb.toStringAsFixed(2)} MB • Siap diunggah',
                    style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), color: AppColors.error, size: 20.w(context)),
              tooltip: 'Hapus Lampiran',
              onPressed: onRemoveFile,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPickFile,
      borderRadius: BorderRadius.circular(14.w(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 22.h(context), horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.w(context)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(PhosphorIcons.cloudArrowUp(PhosphorIconsStyle.bold), color: AppColors.primary, size: 28.w(context)),
            ),
            SizedBox(height: 12.h(context)),
            Text(
              'Unggah Modul / Materi Pembelajaran',
              style: AppTextStyles.titleSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h(context)),
            Text(
              'Format PDF, DOCX, XLSX, PPTX, JPG, PNG (Maksimal 20 MB)',
              style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
