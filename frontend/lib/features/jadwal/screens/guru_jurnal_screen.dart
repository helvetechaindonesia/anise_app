import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/main_header.dart';
import '../../../core/widgets/anise_card.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_date_filter.dart';
import '../../notifications/screens/notification_screen.dart';
import 'guru_terbit_jurnal_screen.dart';
import 'guru_jurnal_detail_screen.dart';
import '../../presensi/screens/presensi_camera_screen.dart';
import '../widgets/guru_isi_jurnal_dialog.dart';
import '../providers/jurnal_provider.dart';

class GuruJurnalScreen extends ConsumerStatefulWidget {
  final String? className;
  const GuruJurnalScreen({Key? key, this.className}) : super(key: key);

  @override
  ConsumerState<GuruJurnalScreen> createState() => _GuruJurnalScreenState();
}

class _GuruJurnalScreenState extends ConsumerState<GuruJurnalScreen> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;
  bool _isCustomDateSelected = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _initCurrentWeek();
  }

  void _initCurrentWeek() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentWeekStart = computeActiveWeekMonday(null);
    _isCustomDateSelected = false;
  }

  void _resetToCurrentWeek([Map<String, dynamic>? offDaysData]) {
    setState(() {
      _isCustomDateSelected = false;
      _currentWeekStart = computeActiveWeekMonday(offDaysData);
      final activeDates = filterActiveWeekDates(
        weekMonday: _currentWeekStart,
        offDaysData: offDaysData,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (activeDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) {
        _selectedDate = today;
      } else if (activeDates.isNotEmpty) {
        _selectedDate = activeDates.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final offDaysAsync = ref.watch(offDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 1. Standard MainHeader (Identitas Visual Baku Anise App)
          MainHeader(
            schoolName: 'SMA N 1 Peunaron',
            subtitle: 'Jurnal Mengajar Guru',
            onNotificationPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
          ),

          // 2. Main Title dan Filter Hari Nonaktif Terstandarisasi
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h(context)),
                  _buildHeaderTitle(context, offDaysAsync.valueOrNull),
                  SizedBox(height: 16.h(context)),
                  offDaysAsync.when(
                    data: (offDaysData) {
                      if (!_isCustomDateSelected) {
                        _currentWeekStart = computeActiveWeekMonday(offDaysData);
                      }
                      final activeDates = filterActiveWeekDates(
                        weekMonday: _currentWeekStart,
                        offDaysData: offDaysData,
                      );

                      // Jika hari saat ini adalah hari libur / nonaktif, otomatis pilih hari KBM aktif pertama
                      if (!_isCustomDateSelected && activeDates.isNotEmpty) {
                        final isSelectedInActive = activeDates.any((d) =>
                            d.year == _selectedDate.year &&
                            d.month == _selectedDate.month &&
                            d.day == _selectedDate.day);
                        if (!isSelectedInActive) {
                          _selectedDate = activeDates.first;
                        }
                      }

                      return AniseDateFilter(
                        dates: activeDates,
                        selectedDate: _selectedDate,
                        isCustomDateSelected: _isCustomDateSelected,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                            _isCustomDateSelected = false;
                          });
                        },
                        onReset: () => _resetToCurrentWeek(offDaysData),
                      );
                    },
                    loading: () => SizedBox(
                      height: 74.h(context),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    ),
                    error: (_, __) {
                      final fallbackDates = List.generate(6, (i) => _currentWeekStart.add(Duration(days: i)));
                      return AniseDateFilter(
                        dates: fallbackDates,
                        selectedDate: _selectedDate,
                        isCustomDateSelected: _isCustomDateSelected,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                            _isCustomDateSelected = false;
                          });
                        },
                        onReset: () => _resetToCurrentWeek(null),
                      );
                    },
                  ),
                  SizedBox(height: 20.h(context)),
                ],
              ),
            ),
          ),

          // 3. Daftar Kartu KBM / Jurnal Guru Terstandarisasi
          _buildJurnalList(context),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle(BuildContext context, [Map<String, dynamic>? offDaysData]) {
    final releaseDateStr = offDaysData?['app_release_date']?.toString();
    final releaseDate = (releaseDateStr != null ? DateTime.tryParse(releaseDateStr) : null) ?? ApiConstants.appReleaseDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JURNAL AKADEMIK',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              widget.className != null ? 'Jadwal ${widget.className}' : 'Jurnal Mengajar',
              style: AppTextStyles.headlineMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        // Tombol Standarisasi: AniseDatePickerButton (Pilih Tanggal / Ubah Tanggal)
        AniseDatePickerButton(
          selectedDate: _selectedDate,
          isCustomDateSelected: _isCustomDateSelected,
          firstDate: releaseDate,
          onDateSelected: (picked) {
            setState(() {
              _selectedDate = DateTime(picked.year, picked.month, picked.day);
              _currentWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
              _isCustomDateSelected = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildJurnalList(BuildContext context) {
    final journalsAsync = ref.watch(allJournalsProvider);

    return journalsAsync.when(
      data: (journals) {
        final selectedDateStr =
            "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
        final selectedWeekday = _selectedDate.weekday; // 1 = Senin ... 7 = Minggu
        const daysIndo = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
        final currentDayName = daysIndo[selectedWeekday];

        // 1. Ambil jurnal terbit pada tanggal yang dipilih
        final dateJournals = journals.where((j) {
          if (widget.className != null && j['class_name'] != null && j['class_name'] != widget.className) {
            return false;
          }
          if (j['teaching_date'] != null) {
            final td = j['teaching_date'].toString().substring(0, 10);
            return td == selectedDateStr;
          }
          return false;
        }).toList();

        final Set<String> coveredScheduleIds = {};
        for (final j in dateJournals) {
          if (j['schedule_id'] != null) {
            coveredScheduleIds.add(j['schedule_id'].toString());
          }
        }

        // 2. Ambil cangkang jadwal reguler untuk hari terpilih yang belum diterbitkan
        final regularSchedules = journals.where((j) {
          final isScheduleOnly = j['type'] == 'schedule' || j['teaching_date'] == null;
          if (!isScheduleOnly) return false;

          if (widget.className != null && j['class_name'] != null && j['class_name'] != widget.className) {
            return false;
          }

          final schedId = j['schedule_id']?.toString();
          if (schedId != null && coveredScheduleIds.contains(schedId)) {
            return false;
          }

          final dow = j['day_of_week']?.toString().toLowerCase().trim();
          return dow == currentDayName.toLowerCase();
        }).toList();

        final combinedList = [...dateJournals, ...regularSchedules];

        // 3. Urutkan berdasarkan jam mulai (start_time ASC)
        combinedList.sort((a, b) {
          final timeA = a['start_time']?.toString() ?? '00:00';
          final timeB = b['start_time']?.toString() ?? '00:00';
          return timeA.compareTo(timeB);
        });

        if (combinedList.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: AniseEmptyState(
              title: 'Tidak Ada Jadwal Mengajar',
              subtitle: 'Anda tidak memiliki jadwal kegiatan belajar mengajar pada tanggal ini.',
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final journal = combinedList[index];
                final jId = journal['id']?.toString() ?? '';
                final isScheduleOnly = journal['type'] == 'schedule' || jId.startsWith('sched_');

                final subjectName = journal['subject'] ?? 'Mata Pelajaran';
                final className = journal['class_name'] ?? journal['class'] ?? 'Kelas';
                final timeRange = (journal['start_time'] != null && journal['end_time'] != null)
                    ? '${journal['start_time'].toString().substring(0, 5)} - ${journal['end_time'].toString().substring(0, 5)} WIB'
                    : 'Waktu KBM';

                final isFilled = journal['is_filled'] == true || journal['filled_at'] != null;
                final isCheckedIn = journal['is_checked_in'] == true || journal['check_in_time'] != null;

                // Hitung waktu saat ini vs waktu KBM untuk evaluasi status yang ketat
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final targetDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
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

                // ========================================================
                // ATURAN STRICT: Guru Kelewatan Menerbitkan Jurnal
                // Bila KBM belum terbit dan waktu KBM sudah mulai/lewat
                // ========================================================
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

                // Warna border & background berdasarkan status
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
                  cardBorderColor = isScheduleOnly ? AppColors.warning.withValues(alpha: 0.4) : AppColors.outline.withValues(alpha: 0.2);
                }

                return AniseCard(
                  margin: EdgeInsets.only(bottom: 16.h(context)),
                  padding: EdgeInsets.all(18.w(context)),
                  color: cardBgColor,
                  border: Border.all(color: cardBorderColor, width: status == 'Aktif' || status == 'Terlewat' ? 1.5 : 1),
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
                      // ==========================================
                      // KASUS 1: TERLEWAT (TIDAK BISA TERBITKAN JURNAL)
                      // ==========================================
                      if (status == 'Terlewat') ...[
                        Container(
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
                        ),
                      ]
                      // ==========================================
                      // KASUS 2: BELUM TERBIT & BELUM MASUK JAM KBM (MASIH BISA TERBIT)
                      // ==========================================
                      else if (isScheduleOnly) ...[
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
                              // Data yang di-embed 100% akurat: schedule_id, subject_id, dan teaching_date terpilih!
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
                      ]
                      // ==========================================
                      // KASUS 3: KBM AKTIF (SEDANG BERJALAN)
                      // ==========================================
                      else if (status == 'Aktif') ...[
                        if (!isCheckedIn) ...[
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
                                  ref.invalidate(allJournalsProvider);
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
                        ] else ...[
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
                                  ref.invalidate(allJournalsProvider);
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
                      ]
                      // ==========================================
                      // KASUS 4: KBM SELESAI
                      // ==========================================
                      else if (status == 'Selesai') ...[
                        if (!isFilled) ...[
                          SizedBox(
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
                                  ref.invalidate(allJournalsProvider);
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
                          ),
                        ] else ...[
                          Row(
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
                          ),
                        ],
                      ]
                      // ==========================================
                      // KASUS 5: JURNAL TERBIT TAPI MENUNGGU JAM KBM
                      // ==========================================
                      else ...[
                        Row(
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
                        ),
                      ],
                    ],
                  ),
                );
              },
              childCount: combinedList.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: Text('Gagal memuat jurnal: $error', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
        ),
      ),
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
