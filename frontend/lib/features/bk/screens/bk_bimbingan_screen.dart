import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import 'bk_input_bimbingan_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import 'bk_detail_bimbingan_screen.dart';

class BkBimbinganScreen extends StatefulWidget {
  final String? className;
  const BkBimbinganScreen({Key? key, this.className}) : super(key: key);

  @override
  State<BkBimbinganScreen> createState() => _BkBimbinganScreenState();
}

class _BkBimbinganScreenState extends State<BkBimbinganScreen> {
  int _selectedDateIndex = 4; // Assuming 24 is at index 4

  final List<Map<String, String>> dates = [
    {'day': 'SEN', 'date': '20'},
    {'day': 'SEL', 'date': '21'},
    {'day': 'RAB', 'date': '22'},
    {'day': 'KAM', 'date': '23'},
    {'day': 'JUM', 'date': '24'},
    {'day': 'SAB', 'date': '25'},
    {'day': 'MIN', 'date': '26'},
  ];

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
                  _buildBuatJadwalCard(context),
                  Spacing.custom(context, 24),
                  _buildDateSelector(context),
                  Spacing.custom(context, 24),
                ],
              ),
            ),
          ),
          _buildJadwalList(context),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final canPop = Navigator.canPop(context);
    
    if (canPop) {
      return SliverAppBar(
        pinned: true,
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Bimbingan',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      );
    }

    // Header untuk Menu Tab (Home style)
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
              'BIMBINGAN & KONSELING',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              widget.className != null ? 'Jadwal ${widget.className}' : 'Jadwal Konseling',
              style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Jadwal untuk tanggal ${picked.day}/${picked.month}/${picked.year} ditampilkan.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.surface,
                ),
              );
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

  Widget _buildBuatJadwalCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BkInputBimbinganScreen()),
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
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.calendarPlus(PhosphorIconsStyle.bold),
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
                    'Jadwalkan Konseling',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Atur sesi bimbingan individu atau klasikal',
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
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDateIndex;
          final date = dates[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
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
                    date['day']!,
                    style: AppTextStyles.labelSmall(context, color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurface),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    date['date']!,
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

  List<Map<String, dynamic>> _getSchedulesForDate() {
    switch (_selectedDateIndex) {
      case 0:
        return [
          {
            'title': 'Konseling Individu: Aji Akbar',
            'type': 'Individu',
            'desc': 'Membahas sering membolos dan masalah motivasi belajar.',
            'time': 'Jam Ke 1-2',
            'location': 'Ruang BK',
            'color': AppColors.warning,
          },
          {
            'title': 'Konseling Kelompok (Kasus X CND)',
            'type': 'Kelompok',
            'desc': 'Mediasi pertengkaran antar siswa di kelas X CND.',
            'time': 'Jam Ke 5-6',
            'location': 'Ruang Mediasi',
            'color': AppColors.error,
          }
        ];
      case 4:
        return [
          {
            'title': 'Bimbingan Klasikal X E',
            'type': 'Klasikal',
            'desc': 'Materi: Pengenalan Minat dan Bakat Karir',
            'time': 'Jam Ke 3-4',
            'location': 'Ruang Kelas X E',
            'color': AppColors.primary,
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildJadwalList(BuildContext context) {
    final schedules = _getSchedulesForDate();

    if (schedules.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.light), size: 64.w(context), color: AppColors.onBackground.withValues(alpha: 0.3)),
              SizedBox(height: 16.h(context)),
              Text(
                'Tidak ada jadwal konseling hari ini',
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
            if (index == schedules.length) return SizedBox(height: 40.h(context));
            final jadwal = schedules[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BkDetailBimbinganScreen(
                      title: jadwal['title'] as String,
                      type: jadwal['type'] as String,
                      desc: jadwal['desc'] as String,
                      time: jadwal['time'] as String,
                      location: jadwal['location'] as String,
                      typeColor: jadwal['color'] as Color,
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h(context)),
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onBackground.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 4.h(context)),
                          decoration: BoxDecoration(
                            color: (jadwal['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.w(context)),
                          ),
                          child: Text(
                            jadwal['type'] as String,
                            style: AppTextStyles.labelSmall(context, color: jadwal['color'] as Color).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.onSurface.withValues(alpha: 0.6)),
                            SizedBox(width: 4.w(context)),
                            Text(
                              jadwal['time'] as String,
                              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Spacing.custom(context, 12),
                    Text(
                      jadwal['title'] as String,
                      style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    Spacing.custom(context, 8),
                    Text(
                      jadwal['desc'] as String,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                    Spacing.custom(context, 16),
                    Row(
                      children: [
                        Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), size: 16.w(context), color: AppColors.primary),
                        SizedBox(width: 6.w(context)),
                        Text(
                          jadwal['location'] as String,
                          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
          childCount: schedules.length + 1,
        ),
      ),
    );
  }
}
