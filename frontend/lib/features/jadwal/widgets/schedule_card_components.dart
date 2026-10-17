import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/file_download_helper.dart';

class TeacherHeaderWidget extends StatelessWidget {
  final bool isLive;
  final String teacherImage;
  final String teacherName;
  final String teacherRole;
  final String uploadTime;

  const TeacherHeaderWidget({
    Key? key,
    required this.isLive,
    this.teacherImage = '',
    required this.teacherName,
    required this.teacherRole,
    required this.uploadTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color mutedTextColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  width: 42.w(context),
                  height: 42.w(context),
                  color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.1),
                  child: teacherImage.isNotEmpty
                      ? Image.network(
                          teacherImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: iconColor, size: 24.w(context)),
                        )
                      : Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: iconColor, size: 24.w(context)),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            teacherName,
                            style: AppTextStyles.titleMedium(context, color: textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w(context)),
                          child: Text(
                            '•',
                            style: AppTextStyles.bodyMedium(context, color: mutedTextColor),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            uploadTime,
                            style: AppTextStyles.bodyMedium(context, color: mutedTextColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w(context)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
          decoration: BoxDecoration(
            color: isLive ? AppColors.error : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12.w(context)),
          ),
          child: Text(
            isLive ? 'Sedang Berlangsung' : 'Selesai',
            style: AppTextStyles.labelSmall(context, color: isLive ? AppColors.onPrimary : AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class PostTitleWidget extends StatelessWidget {
  final String subjectName;
  final String timeRange;
  final bool isLive;

  const PostTitleWidget({
    Key? key,
    required this.subjectName,
    required this.timeRange,
    this.isLive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color subtitleColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subjectName,
          style: AppTextStyles.bodyMedium(context, color: textColor, fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h(context)),
        Row(
          children: [
            Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 14.w(context), color: subtitleColor),
            SizedBox(width: 4.w(context)),
            Text(
              timeRange,
              style: AppTextStyles.bodyMedium(context, color: subtitleColor),
            ),
          ],
        ),
      ],
    );
  }
}

class FileAttachmentWidget extends StatelessWidget {
  final bool isLive;
  final String? fileName;
  final String? fileSize;
  final String? attachmentUrl;
  final String? journalId;
  final VoidCallback? onDownload;

  const FileAttachmentWidget({
    Key? key,
    required this.isLive,
    this.fileName,
    this.fileSize,
    this.attachmentUrl,
    this.journalId,
    this.onDownload,
  }) : super(key: key);

  Future<void> _handleDownload(BuildContext context) async {
    if (onDownload != null) {
      onDownload!();
      return;
    }

    if ((attachmentUrl == null || attachmentUrl!.trim().isEmpty) && (journalId == null || journalId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tautan berkas lampiran tidak tersedia.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Jika ada journalId, arahkan ke endpoint download terproteksi
    String targetUrl = attachmentUrl ?? '';
    if (journalId != null && journalId!.isNotEmpty) {
      targetUrl = '/journals/$journalId/download';
    }

    await FileDownloadHelper.downloadFile(
      context: context,
      fileUrl: targetUrl,
      preferredFileName: fileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color mutedTextColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color bgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.backgroundLight;
    Color iconBgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.onSurface.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.w(context)),
      child: InkWell(
        onTap: () => _handleDownload(context),
        borderRadius: BorderRadius.circular(12.w(context)),
        child: Container(
          padding: EdgeInsets.all(12.w(context)),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.w(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w(context)),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8.w(context)),
                ),
                child: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.bold), color: iconColor, size: 20.w(context)),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName ?? 'Lampiran_Dokumen.pdf',
                      style: AppTextStyles.bodySmall(context, color: textColor).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      fileSize ?? 'Ketuk untuk unduh',
                      style: AppTextStyles.labelSmall(context, color: mutedTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.w(context)),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(PhosphorIcons.downloadSimple(PhosphorIconsStyle.bold), color: iconColor, size: 16.w(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageGridWidget extends StatelessWidget {
  final bool isLive;
  const ImageGridWidget({Key? key, this.isLive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color placeholderColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.backgroundLight;
    Color iconColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.5);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.w(context)),
            child: Image.network(
              'https://images.unsplash.com/photo-1577896851231-70ef18881754?q=80&w=600&auto=format&fit=crop',
              height: 100.h(context),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100.h(context),
                color: placeholderColor,
                child: Center(child: Icon(PhosphorIcons.image(PhosphorIconsStyle.bold), color: iconColor, size: 32.w(context))),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.w(context)),
            child: Image.network(
              'https://images.unsplash.com/photo-1523240795612-9a054b0db644?q=80&w=600&auto=format&fit=crop',
              height: 100.h(context),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 100.h(context),
                color: placeholderColor,
                child: Center(child: Icon(PhosphorIcons.image(PhosphorIconsStyle.bold), color: iconColor, size: 32.w(context))),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RatingSectionWidget extends StatefulWidget {
  final int initialRating;
  final bool isLocked;
  final ValueChanged<int>? onRatingChanged;

  const RatingSectionWidget({
    Key? key,
    this.initialRating = 5,
    this.isLocked = false,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  State<RatingSectionWidget> createState() => _RatingSectionWidgetState();
}

class _RatingSectionWidgetState extends State<RatingSectionWidget> {
  late int _currentRating;
  late bool _hasSubmitted;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    _hasSubmitted = widget.isLocked;
  }

  @override
  void didUpdateWidget(covariant RatingSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating || oldWidget.isLocked != widget.isLocked) {
      _currentRating = widget.initialRating;
      _hasSubmitted = widget.isLocked;
    }
  }

  void _showRatingModal(BuildContext context) {
    int tempRating = _currentRating;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w(context))),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 22.h(context)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.star(PhosphorIconsStyle.fill),
                        color: AppColors.warning,
                        size: 32.w(context),
                      ),
                    ),
                    SizedBox(height: 14.h(context)),
                    Text(
                      'Beri Penilaian Pembelajaran',
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h(context)),
                    Text(
                      'Bagaimana pemahaman dan suasana kelas hari ini? Penilaian Anda akan disimpan permanen.',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18.h(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final isFilled = starIndex <= tempRating;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempRating = starIndex;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6.w(context)),
                            child: Icon(
                              isFilled ? PhosphorIcons.star(PhosphorIconsStyle.fill) : PhosphorIcons.star(PhosphorIconsStyle.regular),
                              color: isFilled ? AppColors.warning : AppColors.outlineVariant,
                              size: 32.w(context),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      '$tempRating dari 5 Bintang',
                      style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 22.h(context)),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14.w(context)),
                              ),
                              child: Center(
                                child: Text(
                                  'Batal',
                                  style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w(context)),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _currentRating = tempRating;
                                _hasSubmitted = true;
                              });
                              if (widget.onRatingChanged != null) {
                                widget.onRatingChanged!(tempRating);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Penilaian $tempRating bintang berhasil disimpan permanen!'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w(context))),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14.w(context)),
                              ),
                              child: Center(
                                child: Text(
                                  'Simpan',
                                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
    // 1. Tampilan jika SUDAH dinilai: berbentuk bar bintang terkunci (read-only)
    if (_hasSubmitted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12.w(context)),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                    color: AppColors.secondary,
                    size: 16.w(context),
                  ),
                  SizedBox(width: 6.w(context)),
                  Flexible(
                    child: Text(
                      'Penilaian Anda ($_currentRating/5)',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w(context)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  final isFilled = starIndex <= _currentRating;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.5.w(context)),
                    child: Icon(
                      isFilled ? PhosphorIcons.star(PhosphorIconsStyle.fill) : PhosphorIcons.star(PhosphorIconsStyle.regular),
                      color: isFilled ? AppColors.warning : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                      size: 16.w(context),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    }

    // 2. Tampilan jika BELUM dinilai: Tombol CTA yang jelas, saat diklik baru muncul pop-up modal
    return GestureDetector(
      onTap: () => _showRatingModal(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 11.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12.w(context)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.star(PhosphorIconsStyle.bold), color: AppColors.primary, size: 18.w(context)),
            SizedBox(width: 8.w(context)),
            Text(
              'Beri Penilaian Kelas Ini',
              style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4.w(context)),
            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.primary, size: 14.w(context)),
          ],
        ),
      ),
    );
  }
}

class LiveActionWidget extends StatelessWidget {
  const LiveActionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h(context)),
      decoration: BoxDecoration(
        color: AppColors.onPrimaryContainer,
        borderRadius: BorderRadius.circular(12.w(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.bookOpen(PhosphorIconsStyle.bold), color: AppColors.primaryContainer, size: 18.w(context)),
          SizedBox(width: 8.w(context)),
          Text(
            'Buka Diktat Digital',
            style: AppTextStyles.bodyMedium(context, color: AppColors.primaryContainer),
          ),
        ],
      ),
    );
  }
}

