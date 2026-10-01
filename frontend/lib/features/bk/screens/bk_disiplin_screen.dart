import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../notifications/screens/notification_screen.dart';
import 'bk_input_disiplin_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../providers/disiplin_provider.dart';

class BkDisiplinScreen extends ConsumerStatefulWidget {
  const BkDisiplinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BkDisiplinScreen> createState() => _BkDisiplinScreenState();
}

class _BkDisiplinScreenState extends ConsumerState<BkDisiplinScreen> {
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
                  _buildInputDisiplinCard(context),
                  Spacing.custom(context, 24),
                  _buildDateSelector(context),
                  Spacing.custom(context, 24),
                  _buildKpiButton(context),
                  Spacing.custom(context, 32),
                  Text(
                    'Laporan Kedisiplinan Terbaru',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  Spacing.custom(context, 16),
                  _buildTopOffendersList(context),
                  Spacing.custom(context, 40),
                ],
              ),
            ),
          ),
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
              'GURU & BK',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              'Pantau Disiplin',
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
                  content: Text('Data untuk tanggal ${picked.day}/${picked.month}/${picked.year} ditampilkan.'),
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

  Widget _buildInputDisiplinCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BkInputDisiplinScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.error,
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
                    'Input Pelanggaran / Lapor',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Catat atau laporkan pelanggaran siswa',
                    style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
              color: AppColors.error,
              size: 20.w(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PoinScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(16.w(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer),
                SizedBox(width: 12.w(context)),
                Text(
                  'Lihat Grafik KPI Sekolah',
                  style: AppTextStyles.labelLarge(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onPrimaryContainer, size: 16.w(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopOffendersList(BuildContext context) {
    final reportsAsync = ref.watch(disiplinReportsProvider);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.onBackground.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h(context)),
              child: Center(
                child: Text(
                  'Belum ada laporan kedisiplinan',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: reports.asMap().entries.map((entry) {
              final idx = entry.key;
              final report = entry.value;
              final student = report['siswa'];
              final status = report['status'];
              
              Color pointColor = status == 'INPUT' ? AppColors.error : AppColors.warning;

              return Column(
                children: [
                  _buildStudentDisciplineRow(
                    context,
                    student != null ? student['full_name'] : 'Unknown',
                    report['category'] ?? '-',
                    status ?? 'LAPORAN',
                    pointColor,
                  ),
                  if (idx < reports.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                      child: Divider(color: AppColors.outline.withValues(alpha: 0.2), height: 1),
                    ),
                ],
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Gagal memuat data: $error')),
      ),
    );
  }

  Widget _buildStudentDisciplineRow(BuildContext context, String name, String category, String status, Color pointColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 40.w(context),
                height: 40.w(context),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name.substring(0, 1) : '?',
                    style: AppTextStyles.titleSmall(context, color: AppColors.onPrimaryContainer).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.labelLarge(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w(context)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
          decoration: BoxDecoration(
            color: pointColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.w(context)),
          ),
          child: Text(
            status,
            style: AppTextStyles.labelSmall(context, color: pointColor).copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
