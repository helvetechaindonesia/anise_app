import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import 'schedule_card_components.dart';

enum ScheduleStatus { selesai, live }

class ScheduleCard extends StatefulWidget {
  final ScheduleStatus status;
  final String timeRange;
  final String uploadTime;
  final String subjectName;
  final String teacherName;
  final String? teacherImage;
  final String teacherRole;
  final String description;
  final bool hasFileAttachment;
  final String? fileName;
  final String? fileSize;
  final bool hasImages;
  final int likes;
  final int comments;

  const ScheduleCard({
    Key? key,
    required this.status,
    required this.timeRange,
    required this.uploadTime,
    required this.subjectName,
    required this.teacherName,
    this.teacherImage,
    required this.teacherRole,
    required this.description,
    this.hasFileAttachment = false,
    this.fileName,
    this.fileSize,
    this.hasImages = false,
    required this.likes,
    required this.comments,
  }) : super(key: key);

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;
  late int _currentLikes;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.likes;
    _blinkController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _blinkAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_blinkController);
    if (widget.status == ScheduleStatus.live) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.status == ScheduleStatus.live;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.5), width: 1)),
      ),
      padding: EdgeInsets.only(top: 20.h(context), bottom: 16.h(context), left: 20.w(context), right: 20.w(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Avatar, Username, Waktu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // AVATAR
              ClipOval(
                child: Container(
                  width: 44.w(context),
                  height: 44.w(context),
                  color: AppColors.onSurface.withValues(alpha: 0.1),
                  child: widget.teacherImage != null && widget.teacherImage!.isNotEmpty
                      ? Image.network(
                          widget.teacherImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
                        )
                      : Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
                ),
              ),
              SizedBox(width: 12.w(context)),
              // USERNAME & WAKTU
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.teacherName,
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      widget.uploadTime,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),
          
          // KONTEN: Mata Pelajaran & Waktu Kelas
          PostTitleWidget(
            subjectName: widget.subjectName,
            timeRange: widget.timeRange,
            isLive: false,
          ),
          SizedBox(height: 12.h(context)),
          
          // DESKRIPSI (Caption)
          Text(
            widget.description,
            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          ),
          
          // ATTACHMENTS
          if (widget.hasFileAttachment) ...[
            SizedBox(height: 16.h(context)),
            FileAttachmentWidget(
              isLive: false,
              fileName: widget.fileName,
              fileSize: widget.fileSize,
            ),
          ],
          if (widget.hasImages) ...[
            SizedBox(height: 16.h(context)),
            const ImageGridWidget(isLive: false),
          ],
          if (!isLive) ...[
            SizedBox(height: 16.h(context)),
            const RatingSectionWidget(),
          ],
          if (isLive) ...[
            SizedBox(height: 16.h(context)),
            const LiveActionWidget(),
          ],
          
          if (isLive) ...[
            SizedBox(height: 16.h(context)),
            FadeTransition(
              opacity: _blinkAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 8.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(20.w(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w(context),
                      height: 8.w(context),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    Text(
                      'Sedang Berlangsung',
                      style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 16.h(context)),
          // FOOTER: Action Buttons (Like, Comment, dll)
          _buildFooter(context, false),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLive) {
    Color iconColor = isLive ? AppColors.onPrimaryContainer : AppColors.onSurface.withValues(alpha: 0.6);
    Color mutedTextColor = isLive ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface.withValues(alpha: 0.6);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. KOMENTAR
        GestureDetector(
          onTap: () {
            _showCommentBottomSheet(context);
          },
          child: Row(
            children: [
              Icon(
                PhosphorIcons.chatTeardrop(PhosphorIconsStyle.bold),
                color: mutedTextColor,
                size: 20.w(context),
              ),
              SizedBox(width: 6.w(context)),
              Text(
                '${widget.comments}',
                style: AppTextStyles.bodySmall(context, color: mutedTextColor),
              ),
            ],
          ),
        ),
        
        // 2. BAGIKAN
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tautan berhasil disalin!'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w(context))),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Row(
            children: [
              Icon(
                PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                color: mutedTextColor,
                size: 20.w(context),
              ),
              SizedBox(width: 6.w(context)),
              Text(
                '12', // Dummy count untuk jumlah share
                style: AppTextStyles.bodySmall(context, color: mutedTextColor),
              ),
            ],
          ),
        ),

        // 3. SUKA
        GestureDetector(
          onTap: () {
            setState(() {
              _isLiked = !_isLiked;
              if (_isLiked) {
                _currentLikes++;
              } else {
                _currentLikes--;
              }
            });
          },
          child: Row(
            children: [
              Icon(
                _isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(PhosphorIconsStyle.bold),
                color: _isLiked ? AppColors.error : mutedTextColor,
                size: 20.w(context),
              ),
              SizedBox(width: 6.w(context)),
              Text(
                '$_currentLikes',
                style: AppTextStyles.bodySmall(context, color: _isLiked ? AppColors.error : mutedTextColor),
              ),
            ],
          ),
        ),
        
        // 4. SIMPAN (BOOKMARK)
        GestureDetector(
          onTap: () {
            setState(() {
              _isSaved = !_isSaved;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isSaved ? 'Berhasil disimpan ke koleksi' : 'Dihapus dari koleksi'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w(context))),
                backgroundColor: AppColors.primary,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Icon(
            _isSaved ? PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill) : PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
            color: _isSaved ? AppColors.secondary : iconColor,
            size: 20.w(context),
          ),
        ),
      ],
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.w(context)),
              topRight: Radius.circular(24.w(context)),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h(context)),
              Container(width: 40.w(context), height: 4.h(context), decoration: BoxDecoration(color: AppColors.outline, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: 16.h(context)),
              Text(
                'Komentar ()',
                style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface),
              ),
              Divider(color: AppColors.outline),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.chatTeardrop(PhosphorIconsStyle.light), size: 48.w(context), color: AppColors.onSurface.withValues(alpha: 0.5)),
                      SizedBox(height: 16.h(context)),
                      Text(
                        'Belum ada komentar terbaru',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 16.w(context),
                  right: 16.w(context),
                  top: 12.h(context),
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.h(context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [BoxShadow(color: AppColors.onBackground.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 10.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(20.w(context)),
                        ),
                        child: Text('Tulis komentar...', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                      ),
                    ),
                    SizedBox(width: 12.w(context)),
                    Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill), color: AppColors.primary, size: 24.w(context)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

