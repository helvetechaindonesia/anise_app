import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_card.dart';
import '../screens/guru_terbit_jurnal_screen.dart';
import '../screens/guru_jurnal_detail_screen.dart';
import '../../presensi/screens/presensi_camera_screen.dart';
import 'guru_isi_jurnal_dialog.dart';

class GuruJurnalCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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

    // Border & Background
    Color cardBorderColor;
    Color cardBgColor = AppColors.surface;

    if (status == 'Terlewat') {
      cardBorderColor = AppColors.error.withValues(alpha: 0.5);
      cardBgColor = AppColors.error.withValues(alpha: 0.03);
    } else if (status == 'Aktif') {
      cardBorderColor = AppColors.secondary;
      cardBgColor = AppColors.secondary.withValues(alpha: 0.02);
    } else if (status == 'Selesai') {
      cardBorderColor = AppColors.outline.withValues(alpha: 0.15);
    } else {
      cardBorderColor = isScheduleOnly
          ? AppColors.warning.withValues(alpha: 0.4)
          : AppColors.outline.withValues(alpha: 0.2);
    }

    return AniseCard(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      color: cardBgColor,
      border: Border.all(
        color: cardBorderColor,
        width: status == 'Aktif' || status == 'Terlewat' ? 1.5 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Baris Atas: Badge Mapel, Kelas, dan Status
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
              _buildStatusBadge(context, status, isScheduleOnly),
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

  Widget _buildStatusBadge(BuildContext context, String status, bool isScheduleOnly) {
    if (status == 'Terlewat') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.error, width: 1),
          borderRadius: BorderRadius.circular(12.w(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.bold), size: 12.w(context), color: AppColors.error),
            SizedBox(width: 4.w(context)),
            Text(
              'Terlewat (Terkunci)',
              style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    if (status == 'Aktif') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
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
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            ),
            SizedBox(width: 4.w(context)),
            Text(
              'Aktif',
              style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    if (status == 'Selesai') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12.w(context)),
        ),
        child: Text(
          'Selesai',
          style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)).copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
      decoration: BoxDecoration(
        color: isScheduleOnly ? AppColors.warning.withValues(alpha: 0.12) : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12.w(context)),
      ),
      child: Text(
        isScheduleOnly ? 'Belum Terbit' : 'Belum Mulai',
        style: AppTextStyles.labelSmall(context, color: isScheduleOnly ? AppColors.warning : AppColors.onSurfaceVariant)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
