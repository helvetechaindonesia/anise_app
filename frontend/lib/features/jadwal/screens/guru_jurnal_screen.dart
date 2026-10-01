import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import 'guru_input_jurnal_screen.dart';
import 'guru_terbit_jurnal_screen.dart';
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
        // Filter jurnal berdasarkan _selectedDate
        final filteredJournals = journals.where((journal) {
          final date = DateTime.parse(journal['created_at']);
          return date.year == _selectedDate.year &&
                 date.month == _selectedDate.month &&
                 date.day == _selectedDate.day;
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
                    'Tidak ada jurnal pada tanggal ini',
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
                final date = DateTime.parse(journal['created_at']);
                final dateStr = DateFormat('HH:mm').format(date);
                
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h(context)),
                  padding: EdgeInsets.all(20.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20.w(context)),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onBackground.withValues(alpha: 0.02),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8.w(context)),
                                      ),
                                      child: Text(
                                        journal['subject'],
                                        style: AppTextStyles.labelSmall(context, color: AppColors.primary), 
                                      ),
                                    ),
                                    SizedBox(width: 8.w(context)),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8.w(context)),
                                      ),
                                      child: Text(
                                        journal['class'],
                                        style: AppTextStyles.labelSmall(context, color: AppColors.secondary), 
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h(context)),
                                Text(
                                  journal['topic'],
                                  style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                                ),
                              ],
                            ),
                          ),
                          Icon(PhosphorIcons.dotsThree(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.4)),
                        ],
                      ),
                      Spacing.custom(context, 12),
                      Text(
                        journal['description'],
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacing.custom(context, 16),
                      Divider(color: AppColors.outline.withValues(alpha: 0.1), height: 1),
                      Spacing.custom(context, 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), size: 16.w(context), color: AppColors.onBackground.withValues(alpha: 0.5)),
                              SizedBox(width: 6.w(context)),
                              Text(
                                'Diterbitkan jam $dateStr',
                                style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                              ),
                            ],
                          ),
                          if (journal['has_task'] == true)
                            Row(
                              children: [
                                Icon(PhosphorIcons.clipboardText(PhosphorIconsStyle.fill), size: 16.w(context), color: AppColors.primary),
                                SizedBox(width: 4.w(context)),
                                Text('Ada Tugas', style: AppTextStyles.labelMedium(context, color: AppColors.primary)),
                              ],
                            ),
                        ],
                      ),
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
          child: Text('Gagal memuat jurnal: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
