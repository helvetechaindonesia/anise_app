import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_card.dart';
import '../providers/jurnal_provider.dart';
import '../screens/guru_terbit_jurnal_screen.dart';
import '../screens/guru_jurnal_detail_screen.dart';
import '../../presensi/screens/presensi_camera_screen.dart';
import 'guru_isi_jurnal_dialog.dart';
import 'schedule_share_modal.dart';

class GuruJurnalCard extends ConsumerWidget {
  final Map<String, dynamic> journal;
  final DateTime selectedDate;
  final VoidCallback onRefresh;

  const GuruJurnalCard({
    super.key,
    required this.journal,
    required this.selectedDate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jId = journal['id']?.toString() ?? '';
    final isScheduleOnly = journal['type'] == 'schedule' || jId.startsWith('sched_');

    final subjectName = journal['subject'] ?? 'Mata Pelajaran';
    final className = journal['class_name'] ?? journal['class'] ?? 'Kelas';
    final timeRange = (journal['start_time'] != null && journal['end_time'] != null)
        ? '${journal['start_time'].toString().substring(0, 5)} - ${journal['end_time'].toString().substring(0, 5)} WIB'
        : 'Waktu KBM';

    final isFilled = journal['is_filled'] == true || journal['filled_at'] != null;
    final isCheckedIn = journal['is_checked_in'] == true || journal['check_in_time'] != null;

    final selectedDateStr =
        "${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    // Evaluasi waktu saat ini vs waktu KBM
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final isPastDay = targetDay.isBefore(today);
    final isToday = targetDay.isAtSameMomentAs(today);

    int currentMinutes = now.hour * 60 + now.minute;
    int startMinutes = 0;
    int endMinutes = 1440;

    if (journal['start_time'] != null) {
      try {
        final p = journal['start_time'].toString().split(':');
        startMinutes = int.parse(p[0]) * 60 + int.parse(p[1]);
      } catch (_) {}
    }

    if (journal['end_time'] != null) {
      try {
        final p = journal['end_time'].toString().split(':');
        endMinutes = int.parse(p[0]) * 60 + int.parse(p[1]);
      } catch (_) {}
    }

    // STRICT: Guru Kelewatan Menerbitkan Jurnal
    final isLateUnpublished = isScheduleOnly && (isPastDay || (isToday && currentMinutes >= startMinutes));

    // Penentuan Status Kartu
    String status = 'Belum';
    if (isLateUnpublished) {
      status = 'Terlewat';
    } else if (isFilled) {
      status = 'Selesai';
    } else if (isCheckedIn) {
      status = 'Aktif';
    } else if (!isScheduleOnly) {
      if (isToday && currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        status = 'Aktif';
      } else if (isPastDay || (isToday && currentMinutes > endMinutes)) {
        status = 'Selesai';
      } else {
        status = 'Belum';
      }
    }

    // 1. Background Card: Selalu Putih / Surface Polos Standar
    const Color cardBgColor = AppColors.surface;

    // 2. Border & Shadow: Pembeda Utama Status Card
    Color cardBorderColor;
    double cardBorderWidth = 1.0;
    List<BoxShadow>? cardShadow;

    if (status == 'Terlewat') {
      // Border merah untuk card terlewat
      cardBorderColor = AppColors.error;
      cardBorderWidth = 1.5;
    } else if (status == 'Aktif') {
      // Border hijau menyala + efek shining / glowing
      cardBorderColor = const Color(0xFF10B981);
      cardBorderWidth = 1.8;
      cardShadow = [
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
    } else if (isScheduleOnly) {
      // Border kuning amber agak gelap untuk card belum terbit / cangkang
      cardBorderColor = const Color(0xFFD97706);
      cardBorderWidth = 1.3;
    } else {
      // Border abu-abu / hitam muda untuk card terbit / selesai
      cardBorderColor = AppColors.outlineVariant;
      cardBorderWidth = 1.0;
    }

    return AniseCard(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      color: cardBgColor,
      boxShadow: cardShadow,
      border: Border.all(
        color: cardBorderColor,
        width: cardBorderWidth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Baris Atas: Badge Mapel, Kelas, dan Hamburger Menu (Pill Badges Dihapus)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.w(context),
                  runSpacing: 4.h(context),
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.w(context)),
                      ),
                      child: Text(
                        subjectName,
                        style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.w(context)),
                      ),
                      child: Text(
                        className,
                        style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCardMenuButton(
                context,
                ref,
                isScheduleOnly: isScheduleOnly,
                jId: jId,
                subjectName: subjectName,
                className: className,
                timeRange: timeRange,
                selectedDateStr: selectedDateStr,
              ),
            ],
          ),

          SizedBox(height: 12.h(context)),

          // 2. Baris Jam & Topik Materi
          Row(
            children: [
              Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.primary),
              SizedBox(width: 6.w(context)),
              Text(
                timeRange,
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 6.h(context)),
          Text(
            journal['topic'] ?? 'Sesi Pembelajaran',
            style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            journal['description'] ?? 'Belum ada catatan deskripsi materi.',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Dinamika Kelas jika ada
          if (journal['class_notes'] != null && journal['class_notes'].toString().trim().isNotEmpty) ...[
            SizedBox(height: 10.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Text(
                'Catatan KBM: "${journal['class_notes']}"',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],

          SizedBox(height: 14.h(context)),
          Divider(color: AppColors.outline.withValues(alpha: 0.12), height: 1),
          SizedBox(height: 12.h(context)),

          // 3. ACTION AREA BERDASARKAN STATUS
          _buildActionArea(context, status, isScheduleOnly, isCheckedIn, isFilled, jId, subjectName, className, timeRange, selectedDateStr),
        ],
      ),
    );
  }

  Widget _buildActionArea(
    BuildContext context,
    String status,
    bool isScheduleOnly,
    bool isCheckedIn,
    bool isFilled,
    String jId,
    String subjectName,
    String className,
    String timeRange,
    String selectedDateStr,
  ) {
    // KASUS 1: TERLEWAT
    if (status == 'Terlewat') {
      return Container(
        padding: EdgeInsets.all(12.w(context)),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.w(context)),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.fill), color: AppColors.error, size: 18.w(context)),
            SizedBox(width: 8.w(context)),
            Expanded(
              child: Text(
                'KBM Terlewat: Jurnal tidak diterbitkan sebelum jam pembelajaran dimulai. Sesi ditandai Tidak Terlaksana dan sistem telah mengunci pengisian jurnal serta presensi cam.',
                style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(height: 1.35, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    // KASUS 2: BELUM TERBIT & BELUM MASUK JAM KBM
    if (isScheduleOnly) {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12.h(context)),
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.w(context)),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.warning(PhosphorIconsStyle.fill), color: AppColors.warning, size: 16.w(context)),
                SizedBox(width: 8.w(context)),
                Expanded(
                  child: Text(
                    'Wajib terbitkan jurnal maksimal H-24 jam sebelum KBM dimulai.',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuruTerbitJurnalScreen(
                      initialScheduleId: journal['schedule_id']?.toString(),
                      initialSubjectId: journal['subject_id']?.toString(),
                      initialTeachingDate: selectedDateStr,
                    ),
                  ),
                );
              },
              icon: Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onPrimary),
              label: Text(
                'Terbitkan Jurnal Sekarang',
                style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
              ),
            ),
          ),
        ],
      );
    }

    // KASUS 3: KBM AKTIF
    if (status == 'Aktif') {
      if (!isCheckedIn) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 12.h(context)),
              padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.w(context)),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill), color: AppColors.error, size: 18.w(context)),
                  SizedBox(width: 8.w(context)),
                  Expanded(
                    child: Text(
                      'KBM Aktif! Anda wajib Presensi Cam (Toleransi 15 menit dari jam mulai).',
                      style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PresensiCameraScreen(
                        journalId: jId,
                        kbmTitle: '$subjectName ($className)',
                      ),
                    ),
                  );
                  if (res == true) {
                    onRefresh();
                  }
                },
                icon: Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill), size: 18.w(context), color: AppColors.onPrimary),
                label: Text(
                  'Presensi Cam Jurnal',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                ),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 12.h(context)),
              padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.w(context)),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 18.w(context)),
                  SizedBox(width: 8.w(context)),
                  Expanded(
                    child: Text(
                      'Presensi Cam terverifikasi (${journal['check_in_time'] ?? 'OK'}). Silakan isi jurnal.',
                      style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final res = await GuruIsiJurnalDialog.show(
                    context,
                    journalId: jId,
                    subjectName: subjectName,
                    className: className,
                    timeRange: timeRange,
                  );
                  if (res == true) {
                    onRefresh();
                  }
                },
                icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onPrimary),
                label: Text(
                  'Isi Laporan Jurnal KBM',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                ),
              ),
            ),
          ],
        );
      }
    }

    // KASUS 4: KBM SELESAI
    if (status == 'Selesai') {
      if (!isFilled) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final res = await GuruIsiJurnalDialog.show(
                context,
                journalId: jId,
                subjectName: subjectName,
                className: className,
                timeRange: timeRange,
              );
              if (res == true) {
                onRefresh();
              }
            },
            icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
            label: Text(
              'Lengkapi Catatan Jurnal',
              style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
            ),
          ),
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.secondary, size: 16.w(context)),
                SizedBox(width: 6.w(context)),
                Text(
                  'KBM & Laporan Selesai',
                  style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuruJurnalDetailScreen(journal: journal),
                  ),
                );
              },
              child: Text(
                'Lihat Detail >',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      }
    }

    // KASUS 5: JURNAL TERBIT TAPI MENUNGGU JAM KBM
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(PhosphorIcons.hourglass(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.onSurfaceVariant),
            SizedBox(width: 6.w(context)),
            Text(
              'Materi terbit (Menunggu jam KBM)',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (journal['has_task'] == true)
          Row(
            children: [
              Icon(PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), size: 14.w(context), color: AppColors.primary),
              SizedBox(width: 4.w(context)),
              Text(
                'Ada Tugas',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildCardMenuButton(
    BuildContext context,
    WidgetRef ref, {
    required bool isScheduleOnly,
    required String jId,
    required String subjectName,
    required String className,
    required String timeRange,
    required String selectedDateStr,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.w(context)),
        onTap: () => _showCardMenuBottomSheet(
          context,
          ref,
          isScheduleOnly: isScheduleOnly,
          jId: jId,
          subjectName: subjectName,
          className: className,
          timeRange: timeRange,
          selectedDateStr: selectedDateStr,
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w(context)),
          child: Icon(
            PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.bold),
            size: 20.w(context),
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _showCardMenuBottomSheet(
    BuildContext context,
    WidgetRef ref, {
    required bool isScheduleOnly,
    required String jId,
    required String subjectName,
    required String className,
    required String timeRange,
    required String selectedDateStr,
  }) {
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
                              '$subjectName • $className',
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
                      if (!isScheduleOnly) ...[
                        // 1. Edit (Untuk Penerbit)
                        _buildMenuActionTile(
                          context,
                          icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold),
                          title: 'Edit Jurnal',
                          subtitle: 'Perbarui rincian atau catatan pembelajaran',
                          color: AppColors.primary,
                          onTap: () async {
                            Navigator.pop(bottomSheetContext);
                            final res = await GuruIsiJurnalDialog.show(
                              context,
                              journalId: jId,
                              subjectName: subjectName,
                              className: className,
                              timeRange: timeRange,
                            );
                            if (res == true) {
                              onRefresh();
                            }
                          },
                        ),
                        SizedBox(height: 8.h(context)),

                        // 2. Hapus (Untuk Penerbit)
                        _buildMenuActionTile(
                          context,
                          icon: PhosphorIcons.trash(PhosphorIconsStyle.bold),
                          title: 'Hapus Jurnal',
                          subtitle: 'Hapus penerbitan dan kembalikan ke jadwal kosong',
                          color: AppColors.error,
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            _confirmDeleteJournal(context, ref, jId, subjectName, className);
                          },
                        ),
                        SizedBox(height: 8.h(context)),
                      ],

                      // 3. Bagikan (Untuk Semua)
                      _buildMenuActionTile(
                        context,
                        icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.bold),
                        title: 'Bagikan',
                        subtitle: 'Kirim tautan informasi jadwal/jurnal ini',
                        color: AppColors.onSurface,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          ScheduleShareModal.show(
                            context: context,
                            subjectName: subjectName,
                            teacherName: journal['teacher_name'] ?? 'Guru Pengampu',
                            timeRange: timeRange,
                            description: journal['description'] ?? 'Sesi Pembelajaran KBM',
                            dateText: selectedDateStr,
                          );
                        },
                      ),
                      SizedBox(height: 8.h(context)),

                      // 4. Simpan (Untuk Semua)
                      _buildMenuActionTile(
                        context,
                        icon: PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.bold),
                        title: 'Simpan ke Koleksi',
                        subtitle: 'Tandai sesi ini untuk diakses cepat nanti',
                        color: AppColors.onSurface,
                        onTap: () {
                          Navigator.pop(bottomSheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jurnal berhasil disimpan ke koleksi.'),
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

  void _confirmDeleteJournal(
    BuildContext context,
    WidgetRef ref,
    String jId,
    String subjectName,
    String className,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
        title: Row(
          children: [
            Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 24.w(context)),
            SizedBox(width: 8.w(context)),
            Text('Hapus Jurnal?', style: AppTextStyles.titleMedium(context, color: AppColors.onSurface)),
          ],
        ),
        content: Text(
          'Jurnal mengajar untuk $subjectName ($className) akan dihapus. Jadwal akan kembali berstatus belum terbit.',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Batal', style: AppTextStyles.labelLarge(context, color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await ref.read(jurnalProvider.notifier).deleteJournal(jId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jurnal berhasil dihapus.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  onRefresh();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus jurnal.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text('Hapus', style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuActionTile(
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
}
