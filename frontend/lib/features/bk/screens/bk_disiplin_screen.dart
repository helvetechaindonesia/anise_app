import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_card.dart';
import '../../../core/widgets/anise_date_filter.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../../poin/screens/poin_screen.dart';
import '../providers/disiplin_provider.dart';
import 'bk_input_disiplin_screen.dart';

class BkDisiplinScreen extends ConsumerStatefulWidget {
  const BkDisiplinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BkDisiplinScreen> createState() => _BkDisiplinScreenState();
}

class _BkDisiplinScreenState extends ConsumerState<BkDisiplinScreen> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;
  bool _isCustomDateSelected = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
  }

  void _resetToCurrentWeek(Map<String, dynamic>? offDaysData) {
    setState(() {
      _currentWeekStart = computeActiveWeekMonday(offDaysData);
      final activeDates = filterActiveWeekDates(
        weekMonday: _currentWeekStart,
        offDaysData: offDaysData,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      _selectedDate = activeDates.firstWhere(
        (d) => d.year == today.year && d.month == today.month && d.day == today.day,
        orElse: () => activeDates.isNotEmpty ? activeDates.first : today,
      );
      _isCustomDateSelected = false;
    });
    ref.read(selectedDisiplinDateProvider.notifier).state = _selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final offDaysAsync = ref.watch(offDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // 1. Header Standar Sub-Page: SliverSubHeader (AniseSliverAppBar) dengan Back Button & Center Title
          const SliverSubHeader(
            title: 'Pantau Disiplin',
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h(context)),

                  // 2. Baris Aksi Konten: Label Status & AniseDatePickerButton
                  offDaysAsync.when(
                    data: (offDays) => _buildDatePickerBar(context, offDays),
                    loading: () => _buildDatePickerBar(context, null),
                    error: (_, __) => _buildDatePickerBar(context, null),
                  ),
                  SizedBox(height: 16.h(context)),

                  // 3. Card Input Pelanggaran / Lapor (Terstandarisasi AniseCard)
                  _buildInputDisiplinCard(context),
                  SizedBox(height: 20.h(context)),

                  // 4. Filter Item Tanggal (AniseDateFilter Terstandarisasi)
                  offDaysAsync.when(
                    data: (offDaysData) {
                      final activeDates = filterActiveWeekDates(
                        weekMonday: _currentWeekStart,
                        offDaysData: offDaysData,
                      );

                      if (activeDates.isNotEmpty && !_isCustomDateSelected) {
                        final isSelectedInActive = activeDates.any((d) =>
                            d.year == _selectedDate.year &&
                            d.month == _selectedDate.month &&
                            d.day == _selectedDate.day);
                        if (!isSelectedInActive) {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          _selectedDate = activeDates.firstWhere(
                            (d) => d.year == today.year && d.month == today.month && d.day == today.day,
                            orElse: () => activeDates.first,
                          );
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
                          ref.read(selectedDisiplinDateProvider.notifier).state = date;
                        },
                        onReset: () => _resetToCurrentWeek(offDaysData),
                      );
                    },
                    loading: () => SizedBox(
                      height: 72.h(context),
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
                          ref.read(selectedDisiplinDateProvider.notifier).state = date;
                        },
                        onReset: () => _resetToCurrentWeek(null),
                      );
                    },
                  ),
                  SizedBox(height: 20.h(context)),

                  // 5. Tombol Pintas KPI Poin Disiplin
                  _buildKpiButton(context),
                  SizedBox(height: 28.h(context)),

                  // 6. Judul Seksi Daftar Laporan
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
                        color: AppColors.onBackground,
                        size: 20.w(context),
                      ),
                      SizedBox(width: 8.w(context)),
                      Text(
                        'Laporan Kedisiplinan Siswa',
                        style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h(context)),

                  // 7. Daftar Baris Laporan Terstandarisasi ItemListTile
                  _buildDisciplineReportsList(context),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Baris Tanggal & Tombol Picker Standarisasi Anise
  Widget _buildDatePickerBar(BuildContext context, Map<String, dynamic>? offDaysData) {
    final releaseDateStr = offDaysData?['app_release_date']?.toString();
    final releaseDate = (releaseDateStr != null ? DateTime.tryParse(releaseDateStr) : null) ?? ApiConstants.appReleaseDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AGENDA KEDISIPLINAN',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2.h(context)),
            Text(
              'Laporan & Catatan',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        // Tombol Standarisasi: AniseDatePickerButton (Pilih / Ubah Tanggal)
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
            ref.read(selectedDisiplinDateProvider.notifier).state = _selectedDate;
          },
        ),
      ],
    );
  }

  /// Standarisasi Bentuk Card Input Pelanggaran / Lapor berbasis AniseCard
  Widget _buildInputDisiplinCard(BuildContext context) {
    return AniseCard(
      color: AppColors.primary,
      borderRadius: 16.w(context),
      padding: EdgeInsets.all(18.w(context)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BkInputDisiplinScreen()),
        );
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.plus(PhosphorIconsStyle.bold),
              color: AppColors.surface,
              size: 24.w(context),
            ),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input Pelanggaran / Lapor',
                  style: AppTextStyles.titleMedium(context, color: AppColors.surface).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Catat siswa telat atau pelanggaran tata tertib',
                  style: AppTextStyles.labelSmall(context, color: AppColors.surface.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
            color: AppColors.surface,
            size: 20.w(context),
          ),
        ],
      ),
    );
  }

  /// Tombol Pintas KPI Poin Disiplin
  Widget _buildKpiButton(BuildContext context) {
    return AniseCard(
      borderRadius: 16.w(context),
      padding: EdgeInsets.symmetric(horizontal: 18.w(context), vertical: 14.h(context)),
      color: AppColors.surface,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PoinScreen()),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.w(context)),
                ),
                child: Icon(
                  PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold),
                  color: AppColors.primary,
                  size: 20.w(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Text(
                'Lihat Grafik KPI & Poin Siswa',
                style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
            color: AppColors.onBackground.withValues(alpha: 0.6),
            size: 16.w(context),
          ),
        ],
      ),
    );
  }

  /// Daftar Baris Laporan Terstandarisasi ItemListTile
  Widget _buildDisciplineReportsList(BuildContext context) {
    final reportsAsync = ref.watch(disiplinReportsProvider);

    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const AniseEmptyState(
            title: 'Belum Ada Laporan Kedisiplinan',
            subtitle: 'Tidak ada catatan pelanggaran pada tanggal yang dipilih.',
          );
        }

        return AniseCard(
          borderRadius: 20.w(context),
          padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 8.h(context)),
          child: Column(
            children: reports.asMap().entries.map((entry) {
              final idx = entry.key;
              final report = entry.value as Map<String, dynamic>;
              final isLast = idx == reports.length - 1;

              final student = report['siswa'] as Map<String, dynamic>?;
              final reporter = report['reporter'] as Map<String, dynamic>?;
              final String studentName = student?['full_name']?.toString() ?? 'Siswa';
              final String category = report['category']?.toString() ?? 'Pelanggaran';
              final String status = report['status']?.toString() ?? 'LAPORAN';
              final String? notes = report['notes']?.toString();
              final String? reporterName = reporter?['full_name']?.toString();
              final bool canApprove = report['can_approve'] == true;
              final bool isGuruWali = report['is_guru_wali'] == true;

              Color statusColor;
              IconData statusIcon;
              String statusLabel;

              if (status == 'INPUT') {
                statusColor = AppColors.error;
                statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
                statusLabel = 'INPUT (Sah - Guru Wali)';
              } else if (status == 'APPROVED') {
                statusColor = AppColors.primary;
                statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
                statusLabel = 'DISETUJUI (Sah)';
              } else {
                statusColor = AppColors.warning;
                statusIcon = PhosphorIcons.clock(PhosphorIconsStyle.fill);
                statusLabel = 'LAPORAN (Menunggu Guru Wali)';
              }

              // Metadata teks: Pelapor & Catatan
              String metaText = 'Kategori: $category';
              if (reporterName != null) {
                metaText += ' • Pelapor: $reporterName';
              }

              Widget? actionTrailing;
              if (canApprove && report['id'] != null) {
                actionTrailing = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.w(context)),
                    ),
                  ),
                  icon: Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), size: 14.w(context)),
                  label: Text('Setujui', style: AppTextStyles.labelSmall(context, color: AppColors.onPrimary)),
                  onPressed: () async {
                    final ok = await ref.read(disiplinNotifierProvider.notifier).approveReport(reportId: report['id']);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Laporan siswa berhasil disetujui!' : 'Gagal menyetujui laporan'),
                          backgroundColor: ok ? AppColors.primary : AppColors.error,
                        ),
                      );
                    }
                  },
                );
              }

              return ItemListTile(
                category: isGuruWali ? 'Anak Asuh Guru Wali' : 'Siswa Terlapor',
                subcategory: notes != null && notes.isNotEmpty ? 'Catatan: $notes' : null,
                title: studentName,
                metadataIcon: PhosphorIcons.tag(PhosphorIconsStyle.regular),
                metadataText: metaText,
                statusText: statusLabel,
                statusIcon: statusIcon,
                statusColor: statusColor,
                statusTrailing: actionTrailing,
                showDivider: !isLast,
                dividerThickness: 1.5.h(context),
              );
            }).toList(),
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h(context)),
        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => AniseEmptyState(
        title: 'Gagal Memuat Laporan',
        subtitle: e.toString(),
      ),
    );
  }
}
