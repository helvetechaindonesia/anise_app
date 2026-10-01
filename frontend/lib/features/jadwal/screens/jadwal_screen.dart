import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
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
    dates = List.generate(7, (index) => DateTime.now().add(Duration(days: index - 3)));
    _selectedDateIndex = 3;
    _selectedDate = dates[_selectedDateIndex];
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
                  Spacing.custom(context, 24),
                  _buildDateSelector(context),
                  Spacing.custom(context, 24),
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
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      toolbarHeight: 65.h(context),
      expandedHeight: 65.h(context),
      titleSpacing: 24.w(context),
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
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
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
                    date.day.toString(),
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

  Widget _buildScheduleList(BuildContext context) {
    final journalsAsync = ref.watch(allJournalsProvider);

    return journalsAsync.when(
      data: (journals) {
        final filteredJournals = journals.where((j) {
          if (j['teaching_date'] != null) {
            final DateTime teachingDate = DateTime.parse(j['teaching_date']);
            return teachingDate.year == _selectedDate.year &&
                teachingDate.month == _selectedDate.month &&
                teachingDate.day == _selectedDate.day;
          }
          return false;
        }).toList();

        if (filteredJournals.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.light), size: 64.w(context), color: AppColors.onBackground.withValues(alpha: 0.3)),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'Tidak ada jadwal akademik hari ini',
                    style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == filteredJournals.length) return SizedBox(height: 40.h(context));
                final j = filteredJournals[index];
                
                String timeRange = '';
                if (j['start_time'] != null && j['end_time'] != null) {
                  final start = j['start_time'].toString().substring(0, 5);
                  final end = j['end_time'].toString().substring(0, 5);
                  timeRange = '$start - $end';
                }

                String uploadTime = '';
                if (j['created_at'] != null) {
                  final createdAt = DateTime.parse(j['created_at']);
                  final diff = DateTime.now().difference(createdAt);
                  if (diff.inHours < 1) {
                    uploadTime = '${diff.inMinutes} Menit yang lalu';
                  } else if (diff.inHours < 24) {
                    uploadTime = '${diff.inHours} Jam yang lalu';
                  } else {
                    uploadTime = '${diff.inDays} Hari yang lalu';
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h(context)),
                  child: ScheduleCard(
                    status: ScheduleStatus.selesai,
                    timeRange: timeRange,
                    uploadTime: uploadTime,
                    subjectName: j['subject'] ?? 'Pelajaran',
                    teacherName: j['teacher'] ?? 'Guru',
                    teacherRole: 'Guru Pengajar',
                    description: j['description'] ?? j['topic'] ?? '',
                    hasFileAttachment: j['has_task'] == true,
                    fileName: j['has_task'] == true ? 'Tugas.pdf' : null,
                    fileSize: j['has_task'] == true ? '1.5 MB' : null,
                    likes: 0,
                    comments: 0,
                  ),
                );
              },
              childCount: filteredJournals.length + 1,
            ),
          ),
        );
      },
      loading: () => SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, st) => SliverFillRemaining(
        child: Center(
          child: Text(
            'Terjadi kesalahan saat memuat jadwal',
            style: AppTextStyles.bodyMedium(context, color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
