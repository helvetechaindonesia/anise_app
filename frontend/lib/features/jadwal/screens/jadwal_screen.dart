import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/network/dio_client.dart';
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
  bool _isCustomDateSelected = false;

  @override
  void initState() {
    super.initState();
    _initDefaultDates();
  }

  void _initDefaultDates() {
    // Tampilkan 14 hari: 3 hari sebelumnya, hari ini, dan 10 hari ke depan
    dates = List.generate(14, (index) => DateTime.now().add(Duration(days: index - 3)));
    _selectedDateIndex = 3;
    _selectedDate = dates[_selectedDateIndex];
    _isCustomDateSelected = false;
  }

  ScheduleStatus _determineStatus(dynamic item) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // Jika hari di masa depan
    if (targetDay.isAfter(today)) {
      return ScheduleStatus.upcoming;
    }

    // Jika hari di masa lalu
    if (targetDay.isBefore(today)) {
      return ScheduleStatus.selesai;
    }

    // Jika HARI INI: cek berdasarkan jam pelajaran
    final startTimeStr = item['start_time']?.toString();
    final endTimeStr = item['end_time']?.toString();
    if (startTimeStr == null || endTimeStr == null) return ScheduleStatus.selesai;

    try {
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      final currentMinutes = now.hour * 60 + now.minute;

      if (currentMinutes < startMinutes) {
        return ScheduleStatus.upcoming;
      } else if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return ScheduleStatus.live;
      } else {
        return ScheduleStatus.selesai;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SMA N 1 Peunaron',
                  style: AppTextStyles.headlineSmall(context, color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Anise By Helvetecha',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
                _isCustomDateSelected = true;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: _isCustomDateSelected ? AppColors.surfaceVariant : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20.w(context)),
              border: _isCustomDateSelected ? Border.all(color: AppColors.secondary, width: 1.2) : null,
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
                  color: _isCustomDateSelected ? AppColors.primary : AppColors.onPrimaryContainer,
                  size: 14.w(context),
                ),
                SizedBox(width: 6.w(context)),
                Text(
                  _isCustomDateSelected ? 'Ubah Tanggal' : 'Pilih Tanggal',
                  style: AppTextStyles.labelMedium(
                    context,
                    color: _isCustomDateSelected ? AppColors.primary : AppColors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    if (_isCustomDateSelected) {
      final hariIndo = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
      final bulanIndo = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final dayName = hariIndo[_selectedDate.weekday % 7];
      final dateFormatted = '$dayName, ${_selectedDate.day} ${bulanIndo[_selectedDate.month]} ${_selectedDate.year}';

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.secondary, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold),
                color: AppColors.onSecondary,
                size: 18.w(context),
              ),
            ),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FILTER TANGGAL AKTIF',
                    style: AppTextStyles.labelSmall(context, color: AppColors.secondary).copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    dateFormatted,
                    style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _initDefaultDates();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.w(context)),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.error),
                    SizedBox(width: 4.w(context)),
                    Text(
                      'Reset',
                      style: AppTextStyles.labelSmall(context, color: AppColors.error).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final List<String> hariStr = ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];
    final now = DateTime.now();

    return SizedBox(
      height: 74.h(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDateIndex;
          final date = dates[index];
          final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
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
                  color: isSelected
                      ? AppColors.primary
                      : (isToday ? AppColors.secondary : AppColors.outlineVariant),
                  width: isSelected ? 1.5 : (isToday ? 1.2 : 1),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: AppTextStyles.labelSmall(
                          context,
                          color: isSelected
                              ? AppColors.onPrimaryContainer.withValues(alpha: 0.85)
                              : (isToday ? AppColors.secondary : AppColors.onSurfaceVariant),
                        ).copyWith(
                          fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        date.day.toString(),
                        style: AppTextStyles.titleMedium(
                          context,
                          color: isSelected
                              ? AppColors.onPrimaryContainer
                              : (isToday ? AppColors.secondary : AppColors.onSurface),
                        ).copyWith(fontWeight: (isSelected || isToday) ? FontWeight.w800 : FontWeight.w600),
                      ),
                    ],
                  ),

                  // Garis indikator bawah untuk Hari Ini
                  if (isToday)
                    Positioned(
                      bottom: 5.h(context),
                      child: Container(
                        width: 20.w(context),
                        height: 3.h(context),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.secondary,
                          borderRadius: BorderRadius.circular(2.w(context)),
                        ),
                      ),
                    ),
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

        // 1. Ambil HANYA jurnal yang sudah diterbitkan spesifik pada tanggal yang dipilih
        // Cangkang jadwal yang belum diterbitkan TIDAK DITAMPILKAN ke siswa agar informasi tidak rancu
        final dateJournals = journals.where((j) {
          final isSchedule = j['type'] == 'schedule' || j['teaching_date'] == null;
          if (isSchedule) return false;

          final td = j['teaching_date'].toString().substring(0, 10);
          return td == selectedDateStr;
        }).toList();

        final combinedList = [...dateJournals];

        // 2. Urutkan berdasarkan waktu mulai (start_time ASC)
        combinedList.sort((a, b) {
          final timeA = a['start_time']?.toString() ?? '00:00';
          final timeB = b['start_time']?.toString() ?? '00:00';
          return timeA.compareTo(timeB);
        });

        if (combinedList.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: AniseEmptyState(
              title: 'Belum Ada Jurnal Pembelajaran',
              subtitle: 'Guru mata pelajaran belum menerbitkan materi atau catatan pembelajaran untuk tanggal ini.',
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
                final bool isLiked = j['is_liked'] == true;
                final bool isSaved = j['is_saved'] == true;
                final int comments = (j['comments'] as num?)?.toInt() ?? 0;
                final int rating = ((j['rating'] as num?)?.toInt() ?? 5).clamp(1, 5);
                final bool hasRated = j['has_rated'] == true;
                final int? userRating = (j['my_rating'] as num?)?.toInt();
                final jId = j['id']?.toString();

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h(context)),
                  child: ScheduleCard(
                    journalId: jId,
                    status: status,
                    timeRange: timeRange,
                    uploadTime: uploadTime,
                    subjectName: j['subject'] ?? 'Pelajaran',
                    teacherName: (j['teacher'] != null && j['teacher'].toString().trim().isNotEmpty)
                        ? j['teacher'].toString().trim()
                        : (j['subject'] == 'Bahasa Indonesia'
                            ? 'Ahmad Fauzi, S.Pd.'
                            : (j['subject'] == 'Pendidikan Pancasila & Kewarganegaraan'
                                ? 'Rudi Hermawan, S.Pd.'
                                : 'Guru Pengajar')),
                    teacherImage: j['teacher_image'] as String?,
                    teacherRole: 'Guru Pengajar',
                    description: j['description'] ?? j['topic'] ?? 'Belum ada catatan materi.',
                    hasFileAttachment: hasTask,
                    fileName: fileName,
                    fileSize: hasTask ? '1.5 MB' : null,
                    likes: likes,
                    isLiked: isLiked,
                    isSaved: isSaved,
                    comments: comments,
                    initialRating: rating,
                    hasRated: hasRated,
                    userRating: userRating,
                    onRatingChanged: (newRating) async {
                      if (jId != null) {
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.post('/journals/$jId/rate', data: {'rating': newRating});
                          ref.invalidate(allJournalsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            String errMsg = 'Gagal menyimpan penilaian.';
                            if (e is DioException && e.response?.data != null && e.response?.data['message'] != null) {
                              errMsg = e.response!.data['message'].toString();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errMsg),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                    onLikeToggled: () async {
                      if (jId != null) {
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.post('/journals/$jId/like');
                        } catch (_) {}
                      }
                    },
                    onSaveToggled: () async {
                      if (jId != null) {
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.post('/journals/$jId/save');
                          ref.invalidate(allJournalsProvider);
                        } catch (_) {}
                      }
                    },
                    onFetchComments: () async {
                      if (jId != null) {
                        try {
                          final dio = ref.read(dioProvider);
                          final res = await dio.get('/journals/$jId/comments');
                          if (res.data['status'] == 'success') {
                            final list = res.data['data'] as List<dynamic>;
                            return list.map((item) {
                              String timeStr = 'Baru saja';
                              if (item['created_at'] != null) {
                                final dt = DateTime.tryParse(item['created_at'].toString());
                                if (dt != null) {
                                  final diff = DateTime.now().difference(dt);
                                  if (diff.inMinutes < 1) {
                                    timeStr = 'Baru saja';
                                  } else if (diff.inHours < 1) {
                                    timeStr = '${diff.inMinutes}m lalu';
                                  } else if (diff.inHours < 24) {
                                    timeStr = '${diff.inHours}j lalu';
                                  } else {
                                    timeStr = '${diff.inDays}h lalu';
                                  }
                                }
                              }
                              final isMe = item['is_me'] == true || item['can_delete'] == true;
                              final authorName = item['author_name'] ?? (isMe ? 'Saya' : 'Siswa');
                              return {
                                'id': item['id'],
                                'user': isMe ? 'Saya' : authorName,
                                'text': item['comment_text'] ?? '',
                                'time': timeStr,
                                'is_me': isMe,
                                'can_delete': item['can_delete'] == true,
                              };
                            }).toList();
                          }
                        } catch (_) {}
                      }
                      return [];
                    },
                    onCommentSubmitted: (text) async {
                      if (jId != null) {
                        try {
                          final dio = ref.read(dioProvider);
                          final res = await dio.post('/journals/$jId/comments', data: {'comment_text': text});
                          ref.invalidate(allJournalsProvider);
                          if (res.data['status'] == 'success') {
                            return res.data['data'] ?? true;
                          }
                          return false;
                        } catch (e) {
                          if (context.mounted) {
                            String errMsg = 'Gagal mengirim komentar.';
                            if (e is DioException && e.response?.data != null && e.response?.data['message'] != null) {
                              errMsg = e.response!.data['message'].toString();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errMsg),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          return false;
                        }
                      }
                      return false;
                    },
                    onDeleteComment: (commentId) async {
                      if (jId != null) {
                        try {
                          final dio = ref.read(dioProvider);
                          final res = await dio.delete('/journals/$jId/comments/$commentId');
                          ref.invalidate(allJournalsProvider);
                          return res.data['status'] == 'success';
                        } catch (_) {
                          return false;
                        }
                      }
                      return false;
                    },
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
      error: (e, st) => const SliverFillRemaining(
        hasScrollBody: false,
        child: AniseEmptyState(
          title: 'Belum Ada Data Jadwal',
          subtitle: 'Tidak ada agenda akademik atau kegiatan pembelajaran pada hari ini.',
        ),
      ),
    );
  }
}
