import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import 'guru_terbit_jurnal_screen.dart';
import 'guru_jurnal_detail_screen.dart';
import '../../presensi/screens/presensi_camera_screen.dart';
import '../widgets/guru_isi_jurnal_dialog.dart';
import '../providers/jurnal_provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class GuruJurnalScreen extends ConsumerStatefulWidget {
  final String? className;
  const GuruJurnalScreen({Key? key, this.className}) : super(key: key);

  @override
  ConsumerState<GuruJurnalScreen> createState() => _GuruJurnalScreenState();
}

class _GuruJurnalScreenState extends ConsumerState<GuruJurnalScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _currentWeekDates;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _selectedDate = DateTime.now();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    final now = DateTime.now();
    // Cari hari Senin minggu ini
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _currentWeekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacing.custom(context, 16),
                  _buildHeader(context),
                  Spacing.custom(context, 24),
                  _buildInputJurnalCard(context),
                  Spacing.custom(context, 24),
                  _buildDateSelector(context),
                  Spacing.custom(context, 24),
                ],
              ),
            ),
          ),
          _buildJurnalList(context),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 65.h(context),
      expandedHeight: 65.h(context),
      titleSpacing: 24.w(context),
      automaticallyImplyLeading: false, 
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo-smk.png',
            height: 36.h(context),
            width: 36.w(context),
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w(context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SMA N 1 Peunaron',
                style: AppTextStyles.headlineSmall(context, color: AppColors.onSurface),
              ),
              Text(
                'Jurnal Mengajar',
                style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
          icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        ),
        SizedBox(width: 16.w(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JURNAL AKADEMIK',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              widget.className != null ? 'Jadwal ${widget.className}' : 'Jurnal Mengajar',
              style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                // Generate ulang minggu berdasarkan tanggal yang di-pick
                final startOfWeek = picked.subtract(Duration(days: picked.weekday - 1));
                _currentWeekDates = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onSecondary, size: 14.w(context)),
                SizedBox(width: 6.w(context)),
                Text(
                  'Pilih Tanggal',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputJurnalCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GuruTerbitJurnalScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold),
                color: AppColors.onPrimary,
                size: 20.w(context),
              ),
            ),
            SizedBox(width: 16.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terbitkan Jurnal',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Pilih Jadwal Master & Buat Rencana Mengajar',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              color: AppColors.primary,
              size: 20.w(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return SizedBox(
      height: 70.h(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _currentWeekDates.length,
        itemBuilder: (context, index) {
          final date = _currentWeekDates[index];
          final isSelected = date.year == _selectedDate.year && 
                             date.month == _selectedDate.month && 
                             date.day == _selectedDate.day;
                             
          final dayName = DateFormat('E', 'id_ID').format(date).toUpperCase();
          final dayNumber = DateFormat('d').format(date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              width: 56.w(context),
              margin: EdgeInsets.only(right: 12.w(context)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(
                  color: isSelected ? AppColors.onPrimaryContainer : AppColors.outline,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.onBackground.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTextStyles.labelSmall(context, color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    dayNumber,
                    style: AppTextStyles.titleMedium(context, color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface),
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 4.h(context)),
                    Container(
                      width: 4.w(context),
                      height: 4.w(context),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJurnalList(BuildContext context) {
    final journalsAsync = ref.watch(allJournalsProvider);

    return journalsAsync.when(
      data: (journals) {
        final selectedDateStr = "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
        final selectedWeekday = _selectedDate.weekday; // 1 = Senin, ... 7 = Minggu
        final daysIndo = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
        final currentDayName = daysIndo[selectedWeekday];

        // Filter jurnal & jadwal untuk tanggal terpilih
        final filteredJournals = journals.where((j) {
          if (widget.className != null && j['class_name'] != null && j['class_name'] != widget.className) {
            return false;
          }

          if (j['teaching_date'] != null) {
            final td = j['teaching_date'].toString().substring(0, 10);
            return td == selectedDateStr;
          }

          if (j['day_of_week'] != null) {
            return j['day_of_week'].toString().toLowerCase() == currentDayName.toLowerCase();
          }

          if (j['created_at'] != null) {
            final dt = DateTime.tryParse(j['created_at'].toString());
            if (dt != null) {
              return dt.year == _selectedDate.year && dt.month == _selectedDate.month && dt.day == _selectedDate.day;
            }
          }
          return false;
        }).toList();

        if (filteredJournals.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.notebook(PhosphorIconsStyle.fill), color: AppColors.onBackground.withValues(alpha: 0.2), size: 64.w(context)),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'Tidak ada KBM pada tanggal ini',
                    style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 8.h(context)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final journal = filteredJournals[index];
                final jId = journal['id']?.toString() ?? '';
                final isScheduleOnly = journal['type'] == 'schedule' || jId.startsWith('sched_');

                final subjectName = journal['subject'] ?? 'Mata Pelajaran';
                final className = journal['class_name'] ?? journal['class'] ?? 'Kelas';
                final timeRange = (journal['start_time'] != null && journal['end_time'] != null)
                    ? '${journal['start_time'].toString().substring(0, 5)} - ${journal['end_time'].toString().substring(0, 5)}'
                    : 'Waktu KBM';

                final isFilled = journal['is_filled'] == true || journal['filled_at'] != null;
                final isCheckedIn = journal['is_checked_in'] == true || journal['check_in_time'] != null;

                // Tentukan status kartu (Belum, Aktif, Selesai)
                String status = 'Belum';
                if (isFilled) {
                  status = 'Selesai';
                } else if (isCheckedIn) {
                  status = 'Aktif';
                } else if (!isScheduleOnly) {
                  final now = DateTime.now();
                  final isToday = _selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day;
                  if (isToday && journal['start_time'] != null && journal['end_time'] != null) {
                    try {
                      final startParts = journal['start_time'].toString().split(':');
                      final endParts = journal['end_time'].toString().split(':');
                      final start = DateTime(now.year, now.month, now.day, int.parse(startParts[0]), int.parse(startParts[1]));
                      final end = DateTime(now.year, now.month, now.day, int.parse(endParts[0]), int.parse(endParts[1]));

                      if (now.isAfter(start) && now.isBefore(end)) {
                        status = 'Aktif';
                      } else if (now.isAfter(end)) {
                        status = 'Selesai';
                      } else {
                        status = 'Belum';
                      }
                    } catch (_) {}
                  }
                }

                final isLive = status == 'Aktif';

                return Container(
                  margin: EdgeInsets.only(bottom: 16.h(context)),
                  padding: EdgeInsets.all(20.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20.w(context)),
                    border: Border.all(
                      color: isLive ? AppColors.secondary : AppColors.outline.withValues(alpha: 0.2),
                      width: isLive ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isLive ? AppColors.secondary.withValues(alpha: 0.08) : AppColors.onBackground.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Mapel, Kelas, dan Badge Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: AppTextStyles.labelSmall(context, color: AppColors.primary),
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
                                    style: AppTextStyles.labelSmall(context, color: AppColors.secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Badge Status 3 jenis: Belum, Aktif, Selesai
                          if (status == 'Aktif')
                            Container(
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
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4.w(context)),
                                  Text(
                                    'Aktif',
                                    style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            )
                          else if (status == 'Selesai')
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12.w(context)),
                              ),
                              child: Text(
                                'Selesai',
                                style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)).copyWith(fontWeight: FontWeight.w600),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12.w(context)),
                              ),
                              child: Text(
                                isScheduleOnly ? 'Belum Terbit' : 'Belum',
                                style: AppTextStyles.labelSmall(context, color: isScheduleOnly ? AppColors.warning : AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 12.h(context)),

                      // Baris 2: Waktu KBM & Topik
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
                      SizedBox(height: 8.h(context)),
                      Text(
                        journal['topic'] ?? 'Sesi Pembelajaran',
                        style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6.h(context)),
                      Text(
                        journal['description'] ?? 'Belum ada catatan deskripsi materi.',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Baris Catatan Dinamika Kelas jika sudah diisi
                      if (journal['class_notes'] != null && journal['class_notes'].toString().trim().isNotEmpty) ...[
                        SizedBox(height: 12.h(context)),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10.w(context)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10.w(context)),
                          ),
                          child: Text(
                            'Catatan KBM: "${journal['class_notes']}"',
                            style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],

                      SizedBox(height: 16.h(context)),
                      Divider(color: AppColors.outline.withValues(alpha: 0.1), height: 1),
                      SizedBox(height: 14.h(context)),

                      // ACTION AREA BERDASARKAN STATUS & ATURAN SIKLUS HIDUP:
                      // Case 1: Cangkang Kurikulum belum terbit jurnal
                      if (isScheduleOnly) ...[
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
                                  'Wajib terbitkan jurnal maksimal H-24 jam sebelum KBM.',
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
                                MaterialPageRoute(builder: (context) => const GuruTerbitJurnalScreen()),
                              );
                            },
                            icon: Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold), size: 16.w(context)),
                            label: Text('Terbitkan Jurnal Sekarang', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                            ),
                          ),
                        ),
                      ]
                      // Case 2: KBM Aktif (Sedang Berjalan)
                      else if (status == 'Aktif') ...[
                        if (!isCheckedIn) ...[
                          // Banner Toleransi 15 Menit
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
                          // Tombol Presensi Cam Jurnal
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
                              icon: Icon(PhosphorIcons.camera(PhosphorIconsStyle.fill), size: 18.w(context)),
                              label: Text('Presensi Cam Jurnal 📸', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w800)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Sudah Presensi Cam -> Tampilkan Tombol Isi Jurnal
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
                              icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 16.w(context)),
                              label: Text('Isi Laporan Jurnal KBM 📝', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                              ),
                            ),
                          ),
                        ],
                      ]
                      // Case 3: Selesai
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
                              label: Text('Lengkapi Catatan Jurnal', style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.primary, width: 1.5),
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
                      // Case 4: Belum mulai (Jurnal Terbit tapi KBM belum jamnya)
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
                                  style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            if (journal['has_task'] == true)
                              Row(
                                children: [
                                  Icon(PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), size: 14.w(context), color: AppColors.primary),
                                  SizedBox(width: 4.w(context)),
                                  Text('Ada Tugas', style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
              childCount: filteredJournals.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: Text('Gagal memuat jurnal: $error', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
        ),
      ),
    );
  }
}

