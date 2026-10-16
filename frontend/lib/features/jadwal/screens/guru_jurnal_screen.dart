import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_date_filter.dart';
import '../../notifications/screens/notification_screen.dart';
import '../widgets/guru_jurnal_card.dart';
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
    _isCustomDateSelected = false;
    _currentWeekStart = computeActiveWeekMonday(null);
    final activeDates = filterActiveWeekDates(
      weekMonday: _currentWeekStart,
      offDaysData: null,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (today.isBefore(ApiConstants.appReleaseDate)) {
      _selectedDate = activeDates.isNotEmpty ? activeDates.first : ApiConstants.appReleaseDate;
    } else if (activeDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) {
      _selectedDate = today;
    } else if (activeDates.isNotEmpty) {
      _selectedDate = activeDates.first;
    } else {
      _selectedDate = _currentWeekStart;
    }
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
      final releaseDateStr = offDaysData?['app_release_date']?.toString();
      final releaseDate = (releaseDateStr != null ? DateTime.tryParse(releaseDateStr) : null) ?? ApiConstants.appReleaseDate;

      if (today.isBefore(releaseDate)) {
        _selectedDate = activeDates.isNotEmpty ? activeDates.first : releaseDate;
      } else if (activeDates.any((d) => d.year == today.year && d.month == today.month && d.day == today.day)) {
        _selectedDate = today;
      } else if (activeDates.isNotEmpty) {
        _selectedDate = activeDates.first;
      } else {
        _selectedDate = _currentWeekStart;
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
          _buildAppBar(context),

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

                      // Jika hari saat ini adalah hari libur / nonaktif / pra-rilis, otomatis pilih hari KBM aktif pertama
                      if (!_isCustomDateSelected && activeDates.isNotEmpty) {
                        final isSelectedInActive = activeDates.any((d) =>
                            d.year == _selectedDate.year &&
                            d.month == _selectedDate.month &&
                            d.day == _selectedDate.day);
                        if (!isSelectedInActive) {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final todayInActive = activeDates.firstWhere(
                            (d) => d.year == today.year && d.month == today.month && d.day == today.day,
                            orElse: () => activeDates.first,
                          );
                          _selectedDate = todayInActive;
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
                      _currentWeekStart = computeActiveWeekMonday(null);
                      final fallbackDates = filterActiveWeekDates(
                        weekMonday: _currentWeekStart,
                        offDaysData: null,
                      );
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

  SliverAppBar _buildAppBar(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 65.h(context),
      expandedHeight: 65.h(context),
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 22.w(context)),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      titleSpacing: canPop ? 0 : 24.w(context),
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

          // Abaikan kegiatan luar mapel (KEG) karena tidak memerlukan penerbitan jurnal
          final subjectCode = (j['subject_code'] ?? '').toString().toUpperCase();
          final subjectName = (j['subject'] ?? '').toString().toUpperCase();
          if (subjectCode == 'KEG' || subjectName.contains('KEGIATAN') || j['activity_name'] != null) {
            return false;
          }

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
                return GuruJurnalCard(
                  journal: journal,
                  selectedDate: _selectedDate,
                  onRefresh: () => ref.invalidate(allJournalsProvider),
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
}
