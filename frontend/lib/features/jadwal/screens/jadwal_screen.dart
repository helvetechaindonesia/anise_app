import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_state_feedback.dart';
import '../widgets/schedule_card.dart';
import '../providers/jurnal_provider.dart';

class JadwalScreen extends ConsumerStatefulWidget {
  const JadwalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends ConsumerState<JadwalScreen> {
  DateTime _selectedDate = DateTime.now();
  late List<DateTime> dates;
  late int _selectedDateIndex;

  @override
  void initState() {
    super.initState();
    // Tampilkan 14 hari: 3 hari sebelumnya, hari ini, dan 10 hari ke depan
    dates = List.generate(14, (index) => DateTime.now().add(Duration(days: index - 3)));
    _selectedDateIndex = 3;
    _selectedDate = dates[_selectedDateIndex];
  }

  bool _matchesDayOfWeek(dynamic dayOfWeek, int targetWeekday) {
    if (dayOfWeek == null) return false;
    if (dayOfWeek is int) {
      return dayOfWeek == targetWeekday;
    }
    final str = dayOfWeek.toString().trim().toLowerCase();
    final intVal = int.tryParse(str);
    if (intVal != null) {
      return intVal == targetWeekday;
    }
    const Map<String, int> map = {
      'senin': 1, 'monday': 1,
      'selasa': 2, 'tuesday': 2,
      'rabu': 3, 'wednesday': 3,
      'kamis': 4, 'thursday': 4,
      'jumat': 5, "jum'at": 5, 'friday': 5,
      'sabtu': 6, 'saturday': 6,
      'minggu': 7, 'sunday': 7, 'ahad': 7,
    };
    return map[str] == targetWeekday;
  }

  ScheduleStatus _determineStatus(dynamic item) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (!isToday) {
      return ScheduleStatus.selesai;
    }

    final startTimeStr = item['start_time']?.toString();
    final endTimeStr = item['end_time']?.toString();
    if (startTimeStr == null || endTimeStr == null) return ScheduleStatus.selesai;

    try {
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      final currentMinutes = now.hour * 60 + now.minute;

      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return ScheduleStatus.live;
      }
    } catch (_) {}

    return ScheduleStatus.selesai;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                  Spacing.custom(context, 20),
                  _buildDateSelector(context),
                  Spacing.custom(context, 20),
                ],
              ),
            ),
          ),
          _buildScheduleList(context),
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
                'Anise By Helvetecha',
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
              'AGENDA AKADEMIK',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              'Jadwal Kelas',
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
                bool found = false;
                for (int i = 0; i < dates.length; i++) {
                  if (dates[i].year == picked.year && dates[i].month == picked.month && dates[i].day == picked.day) {
                    _selectedDateIndex = i;
                    found = true;
                    break;
                  }
                }
                if (!found) {
                  dates.insert(0, picked);
                  _selectedDateIndex = 0;
                }
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 14.w(context)),
                SizedBox(width: 6.w(context)),
                Text(
                  'Pilih Tanggal',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final List<String> hariStr = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

    return SizedBox(
      height: 70.h(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDateIndex;
          final date = dates[index];
          final dayName = hariStr[date.weekday % 7];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
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
                  color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTextStyles.labelSmall(
                      context,
                      color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.85) : AppColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.titleMedium(
                      context,
                      color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                    ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600),
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 4.h(context)),
                    Container(
                      width: 5.w(context),
                      height: 5.w(context),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
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

  Widget _buildScheduleList(BuildContext context) {
    final journalsAsync = ref.watch(allJournalsProvider);

    return journalsAsync.when(
      data: (journals) {
        final selectedDateStr = "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
        final selectedWeekday = _selectedDate.weekday; // 1 (Senin) - 7 (Minggu)

        // 1. Ambil jurnal yang spesifik terbit pada tanggal yang dipilih
        final dateJournals = journals.where((j) {
          if (j['teaching_date'] != null) {
            final td = j['teaching_date'].toString().substring(0, 10);
            return td == selectedDateStr;
          }
          return false;
        }).toList();

        // Tandai mata pelajaran atau schedule_id yang sudah memiliki jurnal pada tanggal terpilih
        final Set<String> coveredKeys = {};
        for (final j in dateJournals) {
          if (j['schedule_id'] != null) {
            coveredKeys.add(j['schedule_id'].toString());
          }
          if (j['subject'] != null) {
            coveredKeys.add(j['subject'].toString().toLowerCase().trim());
          }
        }

        // 2. Ambil jadwal reguler untuk hari terpilih yang belum diterbitkan jurnalnya
        final regularSchedules = journals.where((j) {
          final isSchedule = j['type'] == 'schedule' || j['teaching_date'] == null;
          if (!isSchedule) return false;

          final dow = j['day_of_week'];
          if (!_matchesDayOfWeek(dow, selectedWeekday)) return false;

          final schedId = j['schedule_id']?.toString();
          final subj = j['subject']?.toString().toLowerCase().trim();

          if (schedId != null && coveredKeys.contains(schedId)) return false;
          if (subj != null && coveredKeys.contains(subj)) return false;

          return true;
        }).toList();

        final combinedList = [...dateJournals, ...regularSchedules];

        // 3. Urutkan berdasarkan waktu mulai (start_time ASC)
        combinedList.sort((a, b) {
          final timeA = a['start_time']?.toString() ?? '00:00';
          final timeB = b['start_time']?.toString() ?? '00:00';
          return timeA.compareTo(timeB);
        });

        if (combinedList.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: AniseStateFeedback(
              icon: PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill),
              title: 'Tidak Ada Jadwal',
              subtitle: 'Tidak ada agenda akademik atau kegiatan pembelajaran pada hari ini.',
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == combinedList.length) return SizedBox(height: 40.h(context));
                final j = combinedList[index];

                String timeRange = '';
                if (j['start_time'] != null && j['end_time'] != null) {
                  final start = j['start_time'].toString().substring(0, 5);
                  final end = j['end_time'].toString().substring(0, 5);
                  timeRange = '$start - $end';
                }

                String uploadTime = 'Jadwal Rutin';
                if (j['created_at'] != null) {
                  final createdAt = DateTime.tryParse(j['created_at'].toString());
                  if (createdAt != null) {
                    final diff = DateTime.now().difference(createdAt);
                    if (diff.inHours < 1) {
                      uploadTime = '${diff.inMinutes.clamp(1, 59)} Menit yang lalu';
                    } else if (diff.inHours < 24) {
                      uploadTime = '${diff.inHours} Jam yang lalu';
                    } else {
                      uploadTime = '${diff.inDays} Hari yang lalu';
                    }
                  }
                }

                final status = _determineStatus(j);
                final bool hasTask = j['has_task'] == true || j['attachment_url'] != null;
                final String? fileName = j['attachment_url'] != null
                    ? j['attachment_url'].toString().split('/').last
                    : (hasTask ? (j['task_title'] ?? 'Tugas.pdf') : null);

                final int likes = (j['likes'] as num?)?.toInt() ?? 0;
                final int comments = (j['comments'] as num?)?.toInt() ?? 0;
                final int rating = ((j['rating'] as num?)?.toInt() ?? 5).clamp(1, 5);

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h(context)),
                  child: ScheduleCard(
                    journalId: j['id']?.toString(),
                    status: status,
                    timeRange: timeRange,
                    uploadTime: uploadTime,
                    subjectName: j['subject'] ?? 'Pelajaran',
                    teacherName: j['teacher'] ?? 'Guru Pengajar',
                    teacherImage: j['teacher_image'] as String?,
                    teacherRole: 'Guru Pengajar',
                    description: j['description'] ?? j['topic'] ?? 'Belum ada catatan materi.',
                    hasFileAttachment: hasTask,
                    fileName: fileName,
                    fileSize: hasTask ? '1.5 MB' : null,
                    likes: likes,
                    comments: comments,
                    initialRating: rating,
                  ),
                );
              },
              childCount: combinedList.length + 1,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, st) => SliverFillRemaining(
        hasScrollBody: false,
        child: AniseStateFeedback(
          isError: true,
          title: 'Gagal Memuat Jadwal',
          subtitle: 'Terjadi kendala saat memuat agenda akademik. Silakan coba lagi.',
          actionButtonText: 'Coba Lagi',
          onActionPressed: () => ref.refresh(allJournalsProvider),
        ),
      ),
    );
  }
}
