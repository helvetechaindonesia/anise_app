import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../tugas/widgets/tugas_item_card.dart';
import 'bk_input_surat_screen.dart';
import 'bk_detail_surat_screen.dart';

class BkSuratScreen extends StatefulWidget {
  const BkSuratScreen({Key? key}) : super(key: key);

  @override
  State<BkSuratScreen> createState() => _BkSuratScreenState();
}

class _BkSuratScreenState extends State<BkSuratScreen> {
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
                  _buildBuatSuratCard(context),
                  Spacing.custom(context, 24),
                  _buildDateSelector(context),
                  Spacing.custom(context, 24),
                ],
              ),
            ),
          ),
          _buildSuratList(context),
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
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
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
              'Surat Peringatan',
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
                  content: Text('Surat untuk tanggal ${picked.day}/${picked.month}/${picked.year} ditampilkan.'),
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

  Widget _buildBuatSuratCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BkInputSuratScreen()),
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
                PhosphorIcons.plus(PhosphorIconsStyle.bold),
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
                    'Buat Surat Baru',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Keluarkan SP1/SP2 atau panggilan orang tua',
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

  List<Map<String, dynamic>> _getSuratForDate() {
    switch (_selectedDateIndex) {
      case 0:
        return [
          {
            'subject': 'Siswa: Fajar Ramadan (X E)',
            'teacher': 'Pelanggaran: Merokok di Kantin',
            'title': 'Surat Panggilan Orang Tua',
            'timeInfo': 'Jam Ke 1-2',
            'statusText': 'Selesai',
            'statusColor': AppColors.success,
            'statusIcon': PhosphorIcons.check(PhosphorIconsStyle.bold),
            'timeBgColor': AppColors.success.withValues(alpha: 0.1),
            'timeIconColor': AppColors.success,
          }
        ];
      case 4:
        return [
          {
            'subject': 'Siswa: Aji Akbar (X CND)',
            'teacher': 'Pelanggaran: Bolos Sekolah 3x',
            'title': 'Surat Panggilan Orang Tua (SP1)',
            'timeInfo': 'Besok, 09:00 WIB',
            'statusText': 'Menunggu TTD',
            'statusColor': AppColors.warning,
            'statusIcon': PhosphorIcons.clock(PhosphorIconsStyle.bold),
            'timeBgColor': AppColors.warning.withValues(alpha: 0.1),
            'timeIconColor': AppColors.warning,
          },
          {
            'subject': 'Siswa: Sendi Aritanoga (XI JS)',
            'teacher': 'Pelanggaran: Berkelahi',
            'title': 'Surat Peringatan (SP2)',
            'timeInfo': 'Hari ini, 13:00 WIB',
            'statusText': 'Terkirim',
            'statusColor': AppColors.primary,
            'statusIcon': PhosphorIcons.checkCircle(PhosphorIconsStyle.bold),
            'timeBgColor': AppColors.primary.withValues(alpha: 0.1),
            'timeIconColor': AppColors.primary,
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildSuratList(BuildContext context) {
    final suratList = _getSuratForDate();

    if (suratList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.envelopeOpen(PhosphorIconsStyle.light), size: 64.w(context), color: AppColors.onBackground.withValues(alpha: 0.3)),
              SizedBox(height: 16.h(context)),
              Text(
                'Tidak ada surat diterbitkan hari ini',
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
            if (index == suratList.length) return SizedBox(height: 40.h(context));
            final surat = suratList[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h(context)),
              child: TugasItemCard(
                subject: surat['subject'] as String,
                teacher: surat['teacher'] as String,
                title: surat['title'] as String,
                timeInfo: surat['timeInfo'] as String,
                statusText: surat['statusText'] as String,
                statusColor: surat['statusColor'] as Color,
                statusIcon: surat['statusIcon'] as IconData,
                timeBgColor: surat['timeBgColor'] as Color,
                timeIconColor: surat['timeIconColor'] as Color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BkDetailSuratScreen(
                        subject: surat['subject'] as String,
                        teacher: surat['teacher'] as String,
                        title: surat['title'] as String,
                        timeInfo: surat['timeInfo'] as String,
                        statusText: surat['statusText'] as String,
                        statusColor: surat['statusColor'] as Color,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          childCount: suratList.length + 1,
        ),
      ),
    );
  }
}
