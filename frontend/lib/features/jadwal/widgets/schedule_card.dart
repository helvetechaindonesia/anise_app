import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import 'schedule_card_components.dart';
import 'schedule_share_modal.dart';

enum ScheduleStatus { selesai, live, upcoming }

class ScheduleCard extends StatefulWidget {
  final String? journalId;
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
  final bool isLiked;
  final bool isSaved;
  final int comments;
  final int initialRating;
  final bool hasRated;
  final int? userRating;
  final ValueChanged<int>? onRatingChanged;
  final VoidCallback? onLikeToggled;
  final VoidCallback? onSaveToggled;
  final Future<List<Map<String, dynamic>>> Function()? onFetchComments;
  final Future<dynamic> Function(String commentText)? onCommentSubmitted;
  final Future<bool> Function(String commentId)? onDeleteComment;

  const ScheduleCard({
    Key? key,
    this.journalId,
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
    this.isLiked = false,
    this.isSaved = false,
    required this.comments,
    this.initialRating = 5,
    this.hasRated = false,
    this.userRating,
    this.onRatingChanged,
    this.onLikeToggled,
    this.onSaveToggled,
    this.onFetchComments,
    this.onCommentSubmitted,
    this.onDeleteComment,
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
    _isLiked = widget.isLiked;
    _isSaved = widget.isSaved;
    _currentLikes = widget.likes;
    _blinkController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _blinkAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(_blinkController);
    if (widget.status == ScheduleStatus.live) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked ||
        oldWidget.likes != widget.likes ||
        oldWidget.isSaved != widget.isSaved) {
      setState(() {
        _isLiked = widget.isLiked;
        _currentLikes = widget.likes;
        _isSaved = widget.isSaved;
      });
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
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(
          color: isLive ? AppColors.secondary : AppColors.outlineVariant,
          width: isLive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLive
                ? AppColors.secondary.withValues(alpha: 0.12)
                : AppColors.onBackground.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Avatar, Username, Upload Time, & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // AVATAR
              ClipOval(
                child: Container(
                  width: 44.w(context),
                  height: 44.w(context),
                  color: AppColors.primaryContainer,
                  child: widget.teacherImage != null && widget.teacherImage!.isNotEmpty
                      ? Image.network(
                          widget.teacherImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.primary, size: 22.w(context)),
                        )
                      : Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), color: AppColors.primary, size: 22.w(context)),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      widget.uploadTime,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w(context)),
              // STATUS BADGE (Top Right)
              if (isLive)
                FadeTransition(
                  opacity: _blinkAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 5.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.error, width: 1),
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w(context),
                          height: 6.w(context),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w(context)),
                        Text(
                          'Aktif',
                          style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                )
              else if (widget.status == ScheduleStatus.upcoming)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 5.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Text(
                    'Belum',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w600),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 5.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Text(
                    'Selesai',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5)).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h(context)),
          
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
          if (widget.status == ScheduleStatus.selesai) ...[
            SizedBox(height: 16.h(context)),
            RatingSectionWidget(
              initialRating: widget.userRating ?? widget.initialRating,
              isLocked: widget.hasRated,
              onRatingChanged: widget.onRatingChanged,
            ),
          ],
          if (isLive) ...[
            SizedBox(height: 16.h(context)),
            const LiveActionWidget(),
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
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. KOMENTAR
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _showCommentBottomSheet(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.chatTeardrop(PhosphorIconsStyle.bold),
                        color: mutedTextColor,
                        size: 18.w(context),
                      ),
                      SizedBox(width: 4.w(context)),
                      Text(
                        '${widget.comments}',
                        style: AppTextStyles.bodySmall(context, color: mutedTextColor),
                      ),
                    ],
                  ),
                ),
                
                // 2. BAGIKAN
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ScheduleShareModal.show(
                      context: context,
                      subjectName: widget.subjectName,
                      teacherName: widget.teacherName,
                      timeRange: widget.timeRange,
                      description: widget.description,
                      dateText: widget.uploadTime.isNotEmpty ? widget.uploadTime : 'Hari Ini',
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                        color: mutedTextColor,
                        size: 18.w(context),
                      ),
                      SizedBox(width: 4.w(context)),
                      Text(
                        'Bagikan',
                        style: AppTextStyles.bodySmall(context, color: mutedTextColor),
                      ),
                    ],
                  ),
                ),

                // 3. SUKA
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      if (_isLiked) {
                        _currentLikes++;
                      } else {
                        _currentLikes--;
                      }
                    });
                    if (widget.onLikeToggled != null) {
                      widget.onLikeToggled!();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(PhosphorIconsStyle.bold),
                        color: _isLiked ? AppColors.error : mutedTextColor,
                        size: 18.w(context),
                      ),
                      SizedBox(width: 4.w(context)),
                      Text(
                        '$_currentLikes',
                        style: AppTextStyles.bodySmall(context, color: _isLiked ? AppColors.error : mutedTextColor),
                      ),
                    ],
                  ),
                ),
                
                // 4. SIMPAN (BOOKMARK)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _isSaved = !_isSaved;
                    });
                    if (widget.onSaveToggled != null) {
                      widget.onSaveToggled!();
                    }
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w(context), vertical: 2.h(context)),
                    child: Icon(
                      _isSaved ? PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill) : PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                      color: _isSaved ? AppColors.secondary : iconColor,
                      size: 18.w(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    final commentController = TextEditingController();
    List<Map<String, dynamic>> commentsList = [];
    bool isLoading = true;
    bool hasFetched = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Muat data komentar saat pertama kali dibuka
            if (!hasFetched) {
              hasFetched = true;
              if (widget.onFetchComments != null && widget.journalId != null) {
                widget.onFetchComments!().then((list) {
                  setSheetState(() {
                    commentsList = list;
                    isLoading = false;
                  });
                }).catchError((_) {
                  setSheetState(() {
                    isLoading = false;
                  });
                });
              } else {
                isLoading = false;
              }
            }

            final totalCount = commentsList.length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
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
                  Container(
                    width: 40.w(context),
                    height: 4.h(context),
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'Tanggapan & Diskusi ($totalCount)',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12.h(context)),
                  Divider(color: AppColors.outlineVariant, height: 1),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : commentsList.isEmpty
                            ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  PhosphorIcons.chatTeardrop(PhosphorIconsStyle.light),
                                  size: 48.w(context),
                                  color: AppColors.onSurface.withValues(alpha: 0.3),
                                ),
                                SizedBox(height: 16.h(context)),
                                Text(
                                  'Belum ada tanggapan untuk kelas ini',
                                  style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                                ),
                                SizedBox(height: 4.h(context)),
                                Text(
                                  'Maksimal 1 tanggapan per siswa untuk menjaga ketertiban.',
                                  style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
                            itemCount: commentsList.length,
                            separatorBuilder: (context, index) => SizedBox(height: 14.h(context)),
                            itemBuilder: (context, idx) {
                              final item = commentsList[idx];
                              final canDelete = item['can_delete'] == true;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 16.w(context),
                                    backgroundColor: AppColors.primaryContainer,
                                    child: Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onPrimaryContainer),
                                  ),
                                  SizedBox(width: 12.w(context)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  item['user'] ?? 'Siswa',
                                                  style: AppTextStyles.labelMedium(context, color: (item['is_me'] == true || item['user'] == 'Saya') ? AppColors.primary : AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                                                ),
                                                if (item['is_me'] == true || item['user'] == 'Saya') ...[
                                                  SizedBox(width: 6.w(context)),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryContainer,
                                                      borderRadius: BorderRadius.circular(4.w(context)),
                                                    ),
                                                    child: Text(
                                                      'Anda',
                                                      style: AppTextStyles.labelSmall(context, color: AppColors.onPrimaryContainer).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  item['time'] ?? 'Baru saja',
                                                  style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
                                                ),
                                                if (canDelete) ...[
                                                  SizedBox(width: 8.w(context)),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final commentId = item['id']?.toString();
                                                      if (widget.onDeleteComment != null && commentId != null) {
                                                        final ok = await widget.onDeleteComment!(commentId);
                                                        if (ok) {
                                                          setSheetState(() {
                                                            commentsList.removeAt(idx);
                                                          });
                                                        }
                                                      } else {
                                                        setSheetState(() {
                                                          commentsList.removeAt(idx);
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      PhosphorIcons.trash(PhosphorIconsStyle.bold),
                                                      color: AppColors.error,
                                                      size: 16.w(context),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h(context)),
                                        Text(
                                          item['text'] ?? '',
                                          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onBackground.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(24.w(context)),
                              border: Border.all(color: AppColors.outlineVariant, width: 1),
                            ),
                            child: TextField(
                              controller: commentController,
                              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar (1x tanggapan)...',
                                hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10.h(context)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w(context)),
                        GestureDetector(
                          onTap: () async {
                            final text = commentController.text.trim();
                            if (text.isNotEmpty) {
                              if (widget.onCommentSubmitted != null) {
                                final res = await widget.onCommentSubmitted!(text);
                                if (res != null && res != false) {
                                  String? newId;
                                  if (res is Map && res['id'] != null) {
                                    newId = res['id'].toString();
                                  }
                                  setSheetState(() {
                                    commentsList.insert(0, {
                                      'id': newId,
                                      'user': 'Saya',
                                      'text': text,
                                      'time': 'Baru saja',
                                      'is_me': true,
                                      'can_delete': true,
                                    });
                                    commentController.clear();
                                  });
                                }
                              } else {
                                setSheetState(() {
                                  commentsList.insert(0, {
                                    'user': 'Saya',
                                    'text': text,
                                    'time': 'Baru saja',
                                    'is_me': true,
                                    'can_delete': true,
                                  });
                                  commentController.clear();
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.w(context)),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                              color: AppColors.onPrimary,
                              size: 18.w(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

