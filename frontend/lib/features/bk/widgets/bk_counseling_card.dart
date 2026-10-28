import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../providers/counseling_provider.dart';
import '../screens/bk_isi_jurnal_screen.dart';
import 'bk_comment_modal.dart';

class BkCounselingCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  final DateTime selectedDate;
  final VoidCallback onRefresh;
  final bool isStudent;

  const BkCounselingCard({
    super.key,
    required this.item,
    required this.selectedDate,
    required this.onRefresh,
    this.isStudent = false,
  });

  @override
  ConsumerState<BkCounselingCard> createState() => _BkCounselingCardState();
}

class _BkCounselingCardState extends ConsumerState<BkCounselingCard> {
  late bool _isLiked;
  late bool _isSaved;
  late int _currentLikes;
  bool _isCheckingIn = false;
  double? _userRating;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.item['is_liked'] == true;
    _isSaved = widget.item['is_saved'] == true;
    _currentLikes = widget.item['likes'] is int ? widget.item['likes'] : int.tryParse(widget.item['likes']?.toString() ?? '0') ?? 0;
    final r = widget.item['rating'];
    if (r != null) {
      _userRating = (r is num) ? r.toDouble() : double.tryParse(r.toString());
    }
  }

  @override
  void didUpdateWidget(covariant BkCounselingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item['is_liked'] != widget.item['is_liked'] ||
        oldWidget.item['likes'] != widget.item['likes'] ||
        oldWidget.item['rating'] != widget.item['rating']) {
      setState(() {
        _isLiked = widget.item['is_liked'] == true;
        _isSaved = widget.item['is_saved'] == true;
        _currentLikes = widget.item['likes'] is int ? widget.item['likes'] : int.tryParse(widget.item['likes']?.toString() ?? '0') ?? 0;
        final r = widget.item['rating'];
        if (r != null) {
          _userRating = (r is num) ? r.toDouble() : double.tryParse(r.toString());
        }
      });
    }
  }

  void _handlePresensi() async {
    final String id = widget.item['id']?.toString() ?? '';
    if (id.startsWith('journal-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presensi bimbingan klasikal dilakukan melalui halaman Agenda Jurnal Guru.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Presensi Masuk Sesi'),
        content: const Text('Mulai sesi bimbingan sekarang dan catat presensi masuk? Notifikasi WhatsApp akan dikirimkan ke Siswa dan Guru BK.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Mulai Sesi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isCheckingIn = true);
    final ok = await ref.read(counselingNotifierProvider.notifier).checkIn(id);
    setState(() => _isCheckingIn = false);

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Presensi sesi bimbingan berhasil dicatat! Notifikasi WhatsApp terkirim.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRefresh();
      } else {
        final err = ref.read(counselingNotifierProvider.notifier).lastErrorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Gagal mencatat presensi bimbingan.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleIsiJurnal() async {
    final res = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => BkIsiJurnalScreen(item: widget.item),
      ),
    );
    if (res == true) {
      widget.onRefresh();
    }
  }

  void _handleToggleLike() async {
    final id = widget.item['id']?.toString() ?? '';
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _currentLikes++;
      } else {
        _currentLikes = (_currentLikes > 0) ? _currentLikes - 1 : 0;
      }
    });

    if (!id.startsWith('journal-')) {
      await ref.read(counselingNotifierProvider.notifier).toggleLike(id);
    }
  }

  void _handleShare() {
    final studentName = widget.item['student_name']?.toString() ?? 'Siswa';
    final topic = widget.item['topic']?.toString() ?? 'Bimbingan';
    final date = widget.item['schedule_date']?.toString() ?? '';
    final time = widget.item['schedule_time']?.toString() ?? '';
    final text = "📋 *Agenda Bimbingan BK*\nSiswa: $studentName\nTopik: $topic\nWaktu: $date ($time WIB)\n\nAplikasi ANIS-App";
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _showOptionsMenu(BuildContext context) {
    final id = widget.item['id']?.toString() ?? '';
    final isJournal = id.startsWith('journal-');

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w(context))),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                _isSaved ? PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.fill) : PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                color: _isSaved ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              title: Text(_isSaved ? 'Hapus dari Simpanan' : 'Simpan Bimbingan Ini'),
              subtitle: const Text('Tandai sesi bimbingan konseling ini ke daftar tersimpan'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _isSaved = !_isSaved;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isSaved ? 'Sesi bimbingan berhasil disimpan!' : 'Sesi bimbingan dihapus dari simpanan.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            if (!widget.isStudent) ...[
              ListTile(
                leading: Icon(PhosphorIcons.notePencil(PhosphorIconsStyle.bold), color: AppColors.primary),
                title: const Text('Edit Hasil Jurnal & Penilaian'),
                subtitle: const Text('Perbarui ringkasan, catatan evaluasi, dan rating bintang'),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleIsiJurnal();
                },
              ),
              if (!isJournal)
                ListTile(
                  leading: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.primary),
                  title: const Text('Edit Jadwal / Topik Bimbingan'),
                  subtitle: const Text('Perbarui informasi tanggal, jam, atau topik bimbingan'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditScheduleDialog();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditScheduleDialog() {
    final id = widget.item['id']?.toString() ?? '';
    final topicCtrl = TextEditingController(text: widget.item['topic']?.toString() ?? '');
    final descCtrl = TextEditingController(text: widget.item['description']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Data Bimbingan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicCtrl,
              decoration: const InputDecoration(labelText: 'Topik Bimbingan'),
            ),
            SizedBox(height: 12.h(context)),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Deskripsi / Keterangan'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref.read(counselingNotifierProvider.notifier).updateCounseling(
                    counselingId: id,
                    topic: topicCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  );
              if (ok) {
                widget.onRefresh();
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final id = item['id']?.toString() ?? '';
    final studentName = item['student_name']?.toString() ?? 'Siswa';
    final studentAvatar = item['student_avatar']?.toString();
    final className = item['class_name']?.toString() ?? '';
    final topic = item['topic']?.toString() ?? 'Bimbingan';
    final date = item['schedule_date']?.toString() ?? '';
    final time = item['schedule_time']?.toString() ?? '';
    final desc = item['description']?.toString() ?? '';
    final counselingResult = item['counseling_result']?.toString() ?? '';
    final notesEvaluasi = item['notes_evaluasi']?.toString() ?? '';
    final rating = item['rating'];
    final commentsCount = item['comments'] is int ? item['comments'] : int.tryParse(item['comments']?.toString() ?? '0') ?? 0;

    final isCheckedIn = item['is_checked_in'] == true || item['check_in_time'] != null;
    final isFilled = item['is_filled'] == true || item['filled_at'] != null;
    final isLate = item['is_late'] == true;
    final minutesLate = item['minutes_late'] ?? 0;

    // Evaluasi waktu sesi (menggunakan server_time jika ada time travel, konversi ke local/WIB)
    final offDaysData = ref.watch(offDaysProvider).valueOrNull;
    final serverTimeStr = offDaysData?['server_time_iso'] ?? offDaysData?['server_time'];
    final parsedServer = serverTimeStr != null ? DateTime.tryParse(serverTimeStr.toString()) : null;
    final now = (parsedServer != null ? parsedServer.toLocal() : DateTime.now());
    final today = DateTime(now.year, now.month, now.day);
    
    // Ambil tanggal sesi dari item['schedule_date'], fallback ke widget.selectedDate
    final itemDateParsed = date.isNotEmpty ? DateTime.tryParse(date) : null;
    final targetDay = itemDateParsed != null 
        ? DateTime(itemDateParsed.year, itemDateParsed.month, itemDateParsed.day)
        : DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    
    final isPastDay = targetDay.isBefore(today);
    final isToday = targetDay.isAtSameMomentAs(today);

    int currentMinutes = now.hour * 60 + now.minute;
    int startMinutes = 0;
    int endMinutes = 1440;

    if (time.isNotEmpty) {
      try {
        final parts = time.split('-');
        // Support format baik '10:45' maupun '10.45'
        final normalizedStart = parts[0].trim().replaceAll('.', ':');
        final startP = normalizedStart.split(':');
        startMinutes = int.parse(startP[0]) * 60 + int.parse(startP[1]);
        if (parts.length > 1) {
          final normalizedEnd = parts[1].trim().replaceAll('.', ':');
          final endP = normalizedEnd.split(':');
          endMinutes = int.parse(endP[0]) * 60 + int.parse(endP[1]);
        } else {
          endMinutes = startMinutes + 60; // Default jendela bimbingan 60 menit
        }
      } catch (_) {}
    }

    // Apakah waktu sesi sudah dimulai?
    final bool isTimeStarted = isPastDay || (isToday && currentMinutes >= startMinutes);

    // Status Jurnal KBM / Bimbingan
    String status = 'Belum';
    if (isFilled) {
      status = 'Selesai';
    } else if (isCheckedIn) {
      status = 'Aktif';
    } else if (isPastDay || (isToday && currentMinutes > endMinutes)) {
      // Jika sudah lewat jam selesai tapi belum presensi
      status = 'Terlewat';
    } else if (isToday && currentMinutes >= startMinutes) {
      status = 'Aktif';
    } else {
      status = 'Belum';
    }


    final isLive = status == 'Aktif';

    // Style card persis ScheduleCard & GuruJurnalCard
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

    // Status badge chip
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;
    if (status == 'Selesai') {
      badgeBg = Colors.green.withValues(alpha: 0.12);
      badgeTextColor = Colors.green.shade700;
      badgeText = 'Selesai';
    } else if (status == 'Aktif') {
      badgeBg = const Color(0xFF10B981).withValues(alpha: 0.15);
      badgeTextColor = const Color(0xFF047857);
      badgeText = 'Sesi Aktif';
    } else if (status == 'Terlewat') {
      badgeBg = AppColors.error.withValues(alpha: 0.12);
      badgeTextColor = AppColors.error;
      badgeText = 'Terlewat';
    } else {
      badgeBg = AppColors.warning.withValues(alpha: 0.15);
      badgeTextColor = Colors.orange.shade800;
      badgeText = 'Belum Dimulai';
    }

    // Nama dan avatar yang ditampilkan di header:
    // Jika dilihat siswa, tampilkan identitas Guru BK. Jika dilihat Guru BK, tampilkan identitas Siswa.
    final displayName = widget.isStudent
        ? (item['guru_bk_name']?.toString() ?? 'Guru BK')
        : studentName;
    final displayAvatar = widget.isStudent
        ? item['guru_bk_avatar']?.toString()
        : studentAvatar;
    final displaySubtitle = widget.isStudent
        ? 'Guru Pembimbing BK • $time WIB'
        : (className.isNotEmpty ? '$className • $time WIB' : '$time WIB');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: cardShadow,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: Avatar, Nama Siswa / Guru BK, Waktu, Titik Tiga
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 44.w(context),
                  height: 44.w(context),
                  color: AppColors.primaryContainer,
                  child: (displayAvatar != null && displayAvatar.isNotEmpty)
                      ? Image.network(
                          ApiConstants.formatStorageUrl(displayAvatar),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            PhosphorIcons.user(PhosphorIconsStyle.bold),
                            color: AppColors.primary,
                            size: 22.w(context),
                          ),
                        )
                      : Icon(
                          PhosphorIcons.user(PhosphorIconsStyle.bold),
                          color: AppColors.primary,
                          size: 22.w(context),
                        ),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      displaySubtitle,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5)),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w(context)),
              // Status Badge Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.outfit(
                    fontSize: 10.sp(context),
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
              SizedBox(width: 4.w(context)),
              // Menu Titik Tiga
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.w(context)),
                  onTap: () => _showOptionsMenu(context),
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

          // 2. KONTEN UTAMA: Topik & Deskripsi Bimbingan
          Text(
            topic,
            style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (desc.isNotEmpty) ...[
            SizedBox(height: 6.h(context)),
            Text(
              desc,
              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.85)),
            ),
          ],

          // 3. Catatan Terlambat Jika Ada
          if (isLate) ...[
            SizedBox(height: 10.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.w(context)),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.warning(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.error),
                  SizedBox(width: 8.w(context)),
                  Expanded(
                    child: Text(
                      'Presensi Terlambat ($minutesLate menit setelah sesi dimulai)',
                      style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 4. HASIL BIMBINGAN / JURNAL TERISI
          if (counselingResult.isNotEmpty) ...[
            SizedBox(height: 12.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10.w(context)),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.notebook(PhosphorIconsStyle.fill), color: AppColors.primary, size: 16.w(context)),
                      SizedBox(width: 6.w(context)),
                      Text(
                        'Hasil & Kesimpulan Bimbingan:',
                        style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    counselingResult,
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                  ),
                  if (notesEvaluasi.isNotEmpty) ...[
                    SizedBox(height: 8.h(context)),
                    Text(
                      'Catatan Evaluasi: "$notesEvaluasi"',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // 5. RATING SECTION: Siswa bisa beri rating, Guru BK melihat rating (HANYA tampil setelah jurnal diisi)
          if (isFilled && (_userRating != null || widget.isStudent)) ...[
            SizedBox(height: 12.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 10.h(context)),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Row(
                children: [
                  Text(
                    'Rating:',
                    style: AppTextStyles.labelSmall(context, color: const Color(0xFFB45309)).copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.w(context)),
                  ...List.generate(5, (idx) {
                    final starVal = idx + 1.0;
                    final isFilledStar = (_userRating ?? 0.0) >= starVal;
                    return GestureDetector(
                      onTap: widget.isStudent
                          ? () async {
                              setState(() {
                                _userRating = starVal;
                              });
                              if (!id.startsWith('journal-')) {
                                await ref.read(counselingNotifierProvider.notifier).submitRating(id, starVal);
                                widget.onRefresh();
                              }
                            }
                          : null,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w(context)),
                        child: Icon(
                          isFilledStar ? PhosphorIcons.star(PhosphorIconsStyle.fill) : PhosphorIcons.star(PhosphorIconsStyle.bold),
                          color: const Color(0xFFF59E0B),
                          size: 20.w(context),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  Text(
                    _userRating != null ? '${_userRating!.toStringAsFixed(1)} / 5.0' : 'Beri Nilai',
                    style: AppTextStyles.labelSmall(context, color: const Color(0xFFB45309)).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],

          // 6. ACTION BUTTONS (Khusus Guru BK): Presensi Masuk / Isi Jurnal
          // Syarat: Tombol presensi HANYA MUNCUL KETIKA SUDAH MASUK WAKTUNYA (isTimeStarted == true)
          if (!widget.isStudent) ...[
            if (!isCheckedIn && status != 'Selesai' && isTimeStarted) ...[
              SizedBox(height: 16.h(context)),
              SizedBox(
                width: double.infinity,
                height: 44.h(context),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    elevation: 0,
                  ),
                  onPressed: _isCheckingIn ? null : _handlePresensi,
                  icon: _isCheckingIn
                      ? SizedBox(
                          width: 18.w(context),
                          height: 18.w(context),
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(PhosphorIcons.handTap(PhosphorIconsStyle.bold), size: 18.w(context)),
                  label: Text(
                    _isCheckingIn ? 'Mencatat Presensi...' : 'Presensi Sesi Bimbingan',
                    style: AppTextStyles.labelMedium(context, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else if (isCheckedIn && !isFilled) ...[
              SizedBox(height: 16.h(context)),
              SizedBox(
                width: double.infinity,
                height: 44.h(context),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    elevation: 0,
                  ),
                  onPressed: _handleIsiJurnal,
                  icon: Icon(PhosphorIcons.notePencil(PhosphorIconsStyle.bold), size: 18.w(context)),
                  label: Text(
                    'Isi Jurnal & Penilaian',
                    style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],

          SizedBox(height: 14.h(context)),
          // 7. FOOTER ENGAGEMENT BAR (Like, Komentar, Bagikan)
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final mutedTextColor = AppColors.onSurface.withValues(alpha: 0.65);
    final id = widget.item['id']?.toString() ?? '';
    final commentsCount = widget.item['comments'] is int ? widget.item['comments'] : int.tryParse(widget.item['comments']?.toString() ?? '0') ?? 0;

    return Container(
      padding: EdgeInsets.only(top: 10.h(context)),
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
              onTap: _handleToggleLike,
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
              onTap: () {
                if (id.startsWith('journal-')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Komentar bimbingan klasikal dapat dilihat pada halaman Agenda Jurnal Guru.'),
                    ),
                  );
                } else {
                  BkCommentModal.show(context, counselingId: id, ref: ref);
                }
              },
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
                      '$commentsCount',
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
              onTap: _handleShare,
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
}
