import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class ScheduleShareModal {
  static void show({
    required BuildContext context,
    required String subjectName,
    required String teacherName,
    required String timeRange,
    required String description,
    required String dateText,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ShareCardSheet(
        subjectName: subjectName,
        teacherName: teacherName,
        timeRange: timeRange,
        description: description,
        dateText: dateText,
      ),
    );
  }
}

class _ShareCardSheet extends StatefulWidget {
  final String subjectName;
  final String teacherName;
  final String timeRange;
  final String description;
  final String dateText;

  const _ShareCardSheet({
    Key? key,
    required this.subjectName,
    required this.teacherName,
    required this.timeRange,
    required this.description,
    required this.dateText,
  }) : super(key: key);

  @override
  State<_ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<_ShareCardSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isGenerating = false;

  Future<void> _shareImage() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    try {
      // Tunggu hingga frame selesai dirender
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RepaintBoundary tidak ditemukan');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Gagal membuat gambar kartu');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/jadwal_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      final captionText = '📚 Jadwal & Pembelajaran: ${widget.subjectName}\n👨‍🏫 Guru: ${widget.teacherName} (${widget.timeRange})\n\n📲 Dibagikan melalui Sipena';

      if (mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: captionText,
            subject: 'Jadwal: ${widget.subjectName}',
            sharePositionOrigin: origin,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat gambar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _shareTextOnly() {
    final cleanDesc = widget.description.length > 250
        ? '${widget.description.substring(0, 250)}...'
        : widget.description;

    final shareText = StringBuffer()
      ..writeln('📚 *JADWAL & MATERI PEMBELAJARAN*')
      ..writeln('--------------------------------')
      ..writeln('📖 *Mata Pelajaran:* ${widget.subjectName}')
      ..writeln('👨‍🏫 *Guru:* ${widget.teacherName}')
      ..writeln('⏰ *Waktu:* ${widget.timeRange}')
      ..writeln('📅 *Tanggal:* ${widget.dateText}')
      ..writeln('')
      ..writeln('📝 *Catatan:*')
      ..writeln(cleanDesc)
      ..writeln('')
      ..writeln('📲 *Sipena Learning System*');

    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    SharePlus.instance.share(
      ShareParams(
        text: shareText.toString(),
        subject: 'Jadwal: ${widget.subjectName}',
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w(context),
            height: 4.h(context),
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h(context)),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bagikan Jadwal & Catatan',
                style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),

          // CARD PREVIEW (YANG AKAN DI-SCREENSHOT JADI GAMBAR INSTAGRAM STYLE)
          RepaintBoundary(
            key: _cardKey,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.w(context)),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F172A), // Dark slate navy
                    Color(0xFF1E293B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              padding: EdgeInsets.all(20.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top School / App branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34.w(context),
                            height: 34.w(context),
                            padding: EdgeInsets.all(4.w(context)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo-smk.png',
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, _, __) => Icon(
                                  PhosphorIcons.graduationCap(PhosphorIconsStyle.fill),
                                  color: AppColors.primary,
                                  size: 18.w(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w(context)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SIPENA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.w(context),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                              Text(
                                widget.dateText,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 10.w(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.w(context)),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4), width: 1),
                        ),
                        child: Text(
                          widget.timeRange,
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h(context)),

                  // Subject Name
                  Text(
                    widget.subjectName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.w(context),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 6.h(context)),

                  // Teacher row
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 15.w(context),
                      ),
                      SizedBox(width: 6.w(context)),
                      Expanded(
                        child: Text(
                          widget.teacherName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h(context)),

                  // Note Box Container
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w(context)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12.w(context)),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.notebook(PhosphorIconsStyle.fill),
                              color: AppColors.secondary,
                              size: 14.w(context),
                            ),
                            SizedBox(width: 6.w(context)),
                            Text(
                              'Ringkasan Materi',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h(context)),
                        Text(
                          widget.description.trim().isNotEmpty
                              ? widget.description
                              : 'Tidak ada catatan khusus untuk sesi ini.',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Bottom Watermark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#JadwalBelajar #Sipena',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'sipena.app',
                        style: TextStyle(
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h(context)),

          // Action Buttons: Share Card Image vs Ringkasan Teks (Proporsi Seimbang 1:1)
          Row(
            children: [
              // 1. Share as Image (Instagram / WA Story / Chat)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGenerating ? null : _shareImage,
                  icon: _isGenerating
                      ? SizedBox(
                          width: 16.w(context),
                          height: 16.w(context),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Icon(PhosphorIcons.image(PhosphorIconsStyle.bold), size: 18.w(context)),
                  label: Text(
                    _isGenerating ? 'Membuat...' : 'Bagikan Gambar',
                    style: AppTextStyles.labelMedium(context, color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(width: 12.w(context)),

              // 2. Share as Compact Text
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareTextOnly,
                  icon: Icon(PhosphorIcons.chatTeardropText(PhosphorIconsStyle.bold), size: 18.w(context)),
                  label: Text(
                    'Bagikan Teks',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                    side: BorderSide(color: AppColors.outlineVariant, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h(context)),
        ],
      ),
    );
  }
}
