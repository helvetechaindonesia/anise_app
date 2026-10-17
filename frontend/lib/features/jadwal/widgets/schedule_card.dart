import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../tugas/screens/guru_input_tugas_screen.dart';
import 'schedule_card_components.dart';
import 'schedule_share_modal.dart';

enum ScheduleStatus { selesai, live, upcoming }

class ScheduleCard extends StatefulWidget {
  final String? journalId;
  final ScheduleStatus status;
  final String timeRange;
  final String uploadTime;
  final String subjectName;
  final String? className;
  final String teacherName;
  final String? teacherImage;
  final String teacherRole;
  final String? topicTitle;
  final String description;
  final String? classNotes;
  final bool hasFileAttachment;
  final bool hasTask;
  final String? subjectId;
  final String? fileName;
  final String? fileSize;
  final String? attachmentUrl;
  final bool hasImages;
  final int likes;
  final bool isLiked;
  final bool isSaved;
  final int comments;
  final int initialRating;
  final bool hasRated;
  final int? userRating;
  final bool isPublisher;
  final Widget? customActionWidget;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
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
    this.className,
    required this.teacherName,
    this.teacherImage,
    required this.teacherRole,
    this.topicTitle,
    required this.description,
    this.classNotes,
    this.hasFileAttachment = false,
    this.hasTask = false,
    this.subjectId,
    this.fileName,
    this.fileSize,
    this.attachmentUrl,
    this.hasImages = false,
    required this.likes,
    this.isLiked = false,
    this.isSaved = false,
    this.isPublisher = false,
    this.customActionWidget,
    this.onEdit,
    this.onDelete,
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

class _ScheduleCardState extends State<ScheduleCard> {
  bool _isLiked = false;
  bool _isSaved = false;
  late int _currentLikes;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isSaved = widget.isSaved;
    _currentLikes = widget.likes;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.status == ScheduleStatus.live;

    // Border & Shadow: Pembeda Status Jurnal (Hijau Menyala + Shining jika Aktif)
    final borderColor = isLive ? const Color(0xFF10B981) : AppColors.outlineVariant;
    final borderWidth = isLive ? 1.8 : 1.0;
    final cardShadow = [
      if (isLive)
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: cardShadow,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Avatar, Username, Upload Time, & Hamburger Menu
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
              // HAMBURGER MENU (Top Right - Menggantikan Pill Badges)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.w(context)),
                  onTap: () => _showScheduleOptionsMenu(context),
                  child: Padding(
                    padding: EdgeInsets.all(6.w(context)),
                    child: Icon(
                      PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
                      size: 20.w(context),
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h(context)),
          
          // KONTEN: Mata Pelajaran & Waktu Kelas
          PostTitleWidget(
            subjectName: widget.subjectName,
            className: widget.className,
            timeRange: widget.timeRange,
            isLive: false,
          ),
          SizedBox(height: 12.h(context)),
          
          // DESKRIPSI (Caption & Topik Materi)
          if (widget.topicTitle != null && widget.topicTitle!.trim().isNotEmpty) ...[
            Text(
              widget.topicTitle!,
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6.h(context)),
          ],
          Text(
            widget.description,
            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          ),
          
          if (widget.classNotes != null && widget.classNotes!.trim().isNotEmpty) ...[
            SizedBox(height: 10.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Text(
                'Catatan KBM: "${widget.classNotes}"',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
          
          // ATTACHMENTS
          if (widget.hasFileAttachment) ...[
            SizedBox(height: 16.h(context)),
            FileAttachmentWidget(
              isLive: false,
              fileName: widget.fileName,
              fileSize: widget.fileSize,
              attachmentUrl: widget.attachmentUrl,
              journalId: widget.journalId,
            ),
          ],

          // TOMBOL "ADA TUGAS" (Khusus Tampilan Pengajar/Publisher)
          if (widget.isPublisher && (widget.hasTask || widget.hasFileAttachment)) ...[
            SizedBox(height: 12.h(context)),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12.w(context)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuruInputTugasScreen(
                          initialSubjectId: widget.subjectId,
                          initialJournalId: widget.journalId,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12.w(context)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 12.h(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.w(context)),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.clipboardText(PhosphorIconsStyle.bold),
                          color: AppColors.primary,
                          size: 18.w(context),
                        ),
                        SizedBox(width: 8.w(context)),
                        Text(
                          'Ada Tugas • Kelola / Buat Tugas Terkait',
                          style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4.w(context)),
                        Icon(
                          PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                          color: AppColors.primary,
                          size: 14.w(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
          if (widget.customActionWidget != null) ...[
            SizedBox(height: 16.h(context)),
            widget.customActionWidget!,
          ],

          SizedBox(height: 16.h(context)),
          // FOOTER: Action Buttons (Like, Comment, dll)
          _buildFooter(context, false),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLive) {
    final mutedTextColor = AppColors.onSurface.withValues(alpha: 0.65);

    return Container(
      padding: EdgeInsets.only(top: 8.h(context)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. SUKA (LIKE)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.w(context)),
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLiked ? PhosphorIcons.heart(PhosphorIconsStyle.fill) : PhosphorIcons.heart(PhosphorIconsStyle.bold),
                      color: _isLiked ? AppColors.error : mutedTextColor,
                      size: 20.w(context),
                    ),
                    SizedBox(width: 8.w(context)),
                    Text(
                      '$_currentLikes',
                      style: AppTextStyles.bodyMedium(
                        context,
                        color: _isLiked ? AppColors.error : mutedTextColor,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. KOMENTAR (COMMENT)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.w(context)),
              onTap: () => _showCommentBottomSheet(context),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.chatTeardrop(PhosphorIconsStyle.bold),
                      color: mutedTextColor,
                      size: 20.w(context),
                    ),
                    SizedBox(width: 8.w(context)),
                    Text(
                      '${widget.comments}',
                      style: AppTextStyles.bodyMedium(context, color: mutedTextColor).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. BAGIKAN (SHARE)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10.w(context)),
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                      color: mutedTextColor,
                      size: 20.w(context),
                    ),
                    SizedBox(width: 8.w(context)),
                    Text(
                      'Bagikan',
                      style: AppTextStyles.bodyMedium(context, color: mutedTextColor).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h(context)),
                Container(
                  width: 44.w(context),
                  height: 4.h(context),
                  decoration: BoxDecoration(
                    color: AppColors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.w(context)),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opsi Jurnal',
                              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h(context)),
                            Text(
                              '${widget.subjectName} • ${widget.teacherName}',
                              style: AppTextStyles.bodySmall(context, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          PhosphorIcons.x(PhosphorIconsStyle.bold),
                          size: 20.w(context),
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w(context), 8.h(context), 16.w(context), 20.h(context)),
                  child: Column(
                    children: [
                      if (widget.isPublisher) ...[
                        // 1. Edit (Untuk Penerbit)
                        _buildMenuOptionTile(
                          context,
                          icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                          title: 'Edit Jurnal',
                          subtitle: 'Perbarui rincian topik atau catatan pembelajaran',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            if (widget.onEdit != null) {
                              widget.onEdit!();
                            }
                          },
                        ),
                        SizedBox(height: 8.h(context)),

                        // 2. Hapus (Untuk Penerbit)
                        _buildMenuOptionTile(
                          context,
                          icon: PhosphorIcons.trash(PhosphorIconsStyle.bold),
                          title: 'Hapus Jurnal',
                          subtitle: 'Hapus penerbitan jurnal ini dari sistem',
                          color: AppColors.error,
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            if (widget.onDelete != null) {
                              widget.onDelete!();
                            }
                          },
                        ),
                        SizedBox(height: 8.h(context)),
                      ],

                      // 3. Bagikan (Untuk Semua)
                      _buildMenuOptionTile(
                        context,
                        icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                        title: 'Bagikan',
                        subtitle: 'Kirim tautan informasi jadwal/jurnal ini',
                        color: AppColors.onSurface,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          ScheduleShareModal.show(
                            context: context,
                            subjectName: widget.subjectName,
                            teacherName: widget.teacherName,
                            timeRange: widget.timeRange,
                            description: widget.description,
                            dateText: widget.uploadTime.isNotEmpty ? widget.uploadTime : 'Hari Ini',
                          );
                        },
                      ),
                      SizedBox(height: 8.h(context)),

                      // 4. Simpan (Untuk Semua)
                      _buildMenuOptionTile(
                        context,
                        icon: _isSaved ? PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill) : PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                        title: _isSaved ? 'Hapus dari Koleksi' : 'Simpan ke Koleksi',
                        subtitle: 'Tandai sesi ini untuk diakses cepat nanti',
                        color: _isSaved ? AppColors.secondary : AppColors.onSurface,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
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
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.w(context)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 10.h(context)),
          child: Row(
            children: [
              Container(
                width: 38.w(context),
                height: 38.w(context),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.w(context)),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 20.w(context)),
                ),
              ),
              SizedBox(width: 14.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium(context, color: color == AppColors.error ? AppColors.error : AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                size: 16.w(context),
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
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
                                                  item['user'] ?? 'Pengguna',
                                                  style: AppTextStyles.labelMedium(context, color: item['is_me'] == true ? AppColors.primary : AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                                                ),
                                                if (item['is_me'] == true) ...[
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

