import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../providers/counseling_provider.dart';

class BkCommentModal {
  static void show(BuildContext context, {required String counselingId, required WidgetRef ref}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BkCommentSheet(counselingId: counselingId),
    );
  }
}

class _BkCommentSheet extends ConsumerStatefulWidget {
  final String counselingId;
  const _BkCommentSheet({required this.counselingId});

  @override
  ConsumerState<_BkCommentSheet> createState() => _BkCommentSheetState();
}

class _BkCommentSheetState extends ConsumerState<_BkCommentSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final list = await ref.read(counselingNotifierProvider.notifier).getComments(widget.counselingId);
    if (mounted) {
      setState(() {
        _comments = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final res = await ref.read(counselingNotifierProvider.notifier).addComment(widget.counselingId, text);
    setState(() => _isSending = false);

    if (res != null && mounted) {
      _commentCtrl.clear();
      setState(() {
        _comments.add(res);
      });
      ref.invalidate(bkCounselingRequestsProvider);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final ok = await ref.read(counselingNotifierProvider.notifier).deleteComment(widget.counselingId, commentId);
    if (ok && mounted) {
      setState(() {
        _comments.removeWhere((c) => c['id'].toString() == commentId);
      });
      ref.invalidate(bkCounselingRequestsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w(context))),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.h(context)),
              width: 40.w(context),
              height: 4.h(context),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 4.h(context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Komentar Bimbingan',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 20.w(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outlineVariant),

          // List Comments
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada komentar untuk bimbingan ini.\nJadilah yang pertama berkomentar!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(16.w(context)),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
                        itemBuilder: (ctx, idx) {
                          final c = _comments[idx];
                          final author = c['author_name'] ?? 'Pengguna';
                          final role = c['author_role'] ?? '';
                          final commentText = c['comment_text'] ?? '';
                          final canDelete = c['can_delete'] == true;
                          final avatar = c['author_avatar'];

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18.w(context),
                                backgroundColor: AppColors.primaryContainer,
                                child: (avatar != null && avatar.toString().isNotEmpty)
                                    ? ClipOval(
                                        child: Image.network(
                                          ApiConstants.formatStorageUrl(avatar.toString()),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            PhosphorIcons.user(PhosphorIconsStyle.bold),
                                            size: 16.w(context),
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        PhosphorIcons.user(PhosphorIconsStyle.bold),
                                        size: 16.w(context),
                                        color: AppColors.primary,
                                      ),
                              ),
                              SizedBox(width: 10.w(context)),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12.w(context)),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(12.w(context)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            author,
                                            style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (role.isNotEmpty) ...[
                                            SizedBox(width: 6.w(context)),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6.w(context), vertical: 2.h(context)),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(6.w(context)),
                                              ),
                                              child: Text(
                                                role,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 9.sp(context),
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const Spacer(),
                                          if (canDelete)
                                            GestureDetector(
                                              onTap: () => _deleteComment(c['id'].toString()),
                                              child: Icon(
                                                PhosphorIcons.trash(PhosphorIconsStyle.bold),
                                                size: 15.w(context),
                                                color: AppColors.error,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h(context)),
                                      Text(
                                        commentText,
                                        style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16.w(context),
              right: 16.w(context),
              top: 8.h(context),
              bottom: MediaQuery.of(context).viewInsets.bottom + 12.h(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentCtrl,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar bimbingan...',
                      hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.w(context)),
                        borderSide: const BorderSide(color: AppColors.outlineVariant),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 10.h(context)),
                    ),
                  ),
                ),
                SizedBox(width: 8.w(context)),
                IconButton(
                  onPressed: _isSending ? null : _sendComment,
                  icon: _isSending
                      ? SizedBox(
                          width: 20.w(context),
                          height: 20.w(context),
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                          color: AppColors.primary,
                          size: 24.w(context),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
