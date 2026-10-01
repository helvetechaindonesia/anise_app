import 'dart:io';

void main() {
  final content = '''
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

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
    Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant;
    Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;

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
                  color: isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
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
                    Text(
                      teacherName,
                      style: AppTextStyles.bodyMedium(context, color: textColor, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h(context)),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            teacherRole,
                            style: AppTextStyles.overline(context, color: mutedTextColor, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w(context)),
                          child: Text(
                            '•',
                            style: AppTextStyles.overline(context, color: mutedTextColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            uploadTime,
                            style: AppTextStyles.overline(context, color: mutedTextColor, fontWeight: FontWeight.w500),
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
            style: AppTextStyles.overline(context, color: isLive ? AppColors.onPrimary : AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
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
    Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;
    Color subtitleColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subjectName,
          style: AppTextStyles.h4(context, color: textColor),
        ),
        SizedBox(height: 4.h(context)),
        Row(
          children: [
            Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 14.w(context), color: subtitleColor),
            SizedBox(width: 4.w(context)),
            Text(
              timeRange,
              style: AppTextStyles.bodySmall(context, color: subtitleColor, fontWeight: FontWeight.w600),
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

  const FileAttachmentWidget({
    Key? key,
    required this.isLive,
    this.fileName,
    this.fileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface;
    Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant;
    Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.primary;
    Color bgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.surfaceVariant;
    Color iconBgColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1);

    return Container(
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
                  style: AppTextStyles.bodySmall(context, color: textColor, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  fileSize ?? '1.2 MB',
                  style: AppTextStyles.overline(context, color: mutedTextColor, fontWeight: FontWeight.w500),
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
    );
  }
}

class ImageGridWidget extends StatelessWidget {
  final bool isLive;
  const ImageGridWidget({Key? key, this.isLive = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color placeholderColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.1) : AppColors.surfaceVariant;
    Color iconColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.5) : AppColors.onSurfaceVariant;

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

class RatingSectionWidget extends StatelessWidget {
  const RatingSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.w(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Beri Rating Sesi Guru\nini:',
            style: AppTextStyles.caption(context, color: AppColors.onSurface, fontWeight: FontWeight.bold).copyWith(height: 1.2),
          ),
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.only(left: 4.w(context)),
                child: Icon(
                  PhosphorIcons.star(PhosphorIconsStyle.fill),
                  color: AppColors.warning,
                  size: 20.w(context),
                ),
              );
            }),
          ),
        ],
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
            style: AppTextStyles.bodyMedium(context, color: AppColors.primaryContainer, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
''';
  File('f:/projek/anise_app/frontend/lib/features/jadwal/widgets/schedule_card_components.dart').writeAsStringSync(content);
}
