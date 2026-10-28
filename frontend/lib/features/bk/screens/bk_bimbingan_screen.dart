import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/main_header.dart';
import '../../../core/widgets/anise_card.dart';
import '../../../core/widgets/anise_date_filter.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../providers/counseling_provider.dart';
import 'bk_input_bimbingan_screen.dart';

class BkBimbinganScreen extends ConsumerStatefulWidget {
  final String? className;
  const BkBimbinganScreen({Key? key, this.className}) : super(key: key);

  @override
  ConsumerState<BkBimbinganScreen> createState() => _BkBimbinganScreenState();
}

class _BkBimbinganScreenState extends ConsumerState<BkBimbinganScreen> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;
  bool _isCustomDateSelected = false;

  @override
  void initState() {
    super.initState();
    _initDefaultDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bkSelectedDateProvider.notifier).state = _selectedDate;
    });
  }

  void _initDefaultDates([Map<String, dynamic>? offDaysData]) {
    _isCustomDateSelected = false;
    _currentWeekStart = computeActiveWeekMonday(offDaysData);
    final activeDates = filterActiveWeekDates(
      weekMonday: _currentWeekStart,
      offDaysData: offDaysData,
    );
    final serverTimeStr = offDaysData?['server_time_iso'] ?? offDaysData?['server_time'];
    final now = (serverTimeStr != null ? DateTime.tryParse(serverTimeStr.toString()) : null) ?? DateTime.now();
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
  }

  void _resetToCurrentWeek([Map<String, dynamic>? offDaysData]) {
    setState(() {
      _initDefaultDates(offDaysData);
    });
    ref.read(bkSelectedDateProvider.notifier).state = _selectedDate;
  }

  String _formatDateHeader(DateTime d) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final offDaysAsync = ref.watch(offDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bkCounselingRequestsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // 1. Header Utama Standar Aplikasi (MainHeader)
            MainHeader(
              showBackButton: widget.className != null,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h(context)),

                    // 2. Baris Judul & Tombol Pilih Tanggal (Shared Component AniseDatePickerButton)
                    offDaysAsync.when(
                      data: (offDays) => _buildDatePickerBar(context, offDays),
                      loading: () => _buildDatePickerBar(context, null),
                      error: (_, __) => _buildDatePickerBar(context, null),
                    ),
                    SizedBox(height: 16.h(context)),

                    // 3. Card Buat Jadwal Bimbingan Baru (Shared Component AniseCard)
                    _buildBuatJadwalCard(context),
                    SizedBox(height: 20.h(context)),

                    // 4. Filter Item Tanggal Mingguan (Shared Component AniseDateFilter)
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
                            final serverTimeStr = offDaysData?['server_time_iso'] ?? offDaysData?['server_time'];
                            final now = (serverTimeStr != null ? DateTime.tryParse(serverTimeStr.toString()) : null) ?? DateTime.now();
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
                            ref.read(bkSelectedDateProvider.notifier).state = date;
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
                            ref.read(bkSelectedDateProvider.notifier).state = date;
                          },
                          onReset: () => _resetToCurrentWeek(null),
                        );
                      },
                    ),
                    SizedBox(height: 24.h(context)),

                    // 5. Header Seksi Daftar Bimbingan
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
                          color: AppColors.onBackground,
                          size: 20.w(context),
                        ),
                        SizedBox(width: 8.w(context)),
                        Text(
                          'Daftar Sesi Bimbingan',
                          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h(context)),
                  ],
                ),
              ),
            ),

            // 6. Daftar Item Bimbingan Menggunakan Shared Component ItemListTile
            _buildCounselingRequestList(context),

            SliverToBoxAdapter(
              child: SizedBox(height: 40.h(context)),
            ),
          ],
        ),
      ),
    );
  }

  /// Baris Tanggal & Tombol Picker Standarisasi AniseDatePickerButton
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
              'AGENDA BIMBINGAN',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 2.h(context)),
            Text(
              'Jadwal & Permohonan',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        // Shared Component: AniseDatePickerButton
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
            ref.read(bkSelectedDateProvider.notifier).state = _selectedDate;
          },
        ),
      ],
    );
  }

  /// Card Tambah / Jadwalkan Bimbingan berbasis AniseCard
  Widget _buildBuatJadwalCard(BuildContext context) {
    return AniseCard(
      color: AppColors.primary,
      borderRadius: 16.w(context),
      padding: EdgeInsets.all(18.w(context)),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BkInputBimbinganScreen()),
        );
        ref.invalidate(bkCounselingRequestsProvider);
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
              color: Colors.white,
              size: 22.w(context),
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwalkan Bimbingan Baru',
                  style: AppTextStyles.titleMedium(context, color: Colors.white).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  'Bimbingan Klasikal (Kelas), Kelompok, atau Individu',
                  style: AppTextStyles.labelSmall(context, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
            color: Colors.white,
            size: 20.w(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCounselingRequestList(BuildContext context) {
    final requestsAsync = ref.watch(bkCounselingRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.w(context)),
                child: AniseEmptyState(
                  title: 'Belum Ada Data Bimbingan',
                  subtitle: 'Belum ada agenda bimbingan yang dijadwalkan pada ${_formatDateHeader(_selectedDate)}.',
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final req = requests[index];
                return _buildCounselingItemTile(context, req);
              },
              childCount: requests.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => SliverFillRemaining(
        child: Center(
          child: Text('Gagal memuat agenda bimbingan: $err'),
        ),
      ),
    );
  }

  /// Render item bimbingan menggunakan shared component ItemListTile
  Widget _buildCounselingItemTile(BuildContext context, Map<String, dynamic> req) {
    final String id = req['id']?.toString() ?? '';
    final String studentName = req['student_name']?.toString() ?? 'Siswa';
    final String className = req['class_name']?.toString() ?? '';
    final String topic = req['topic']?.toString() ?? 'Bimbingan';
    final String date = req['schedule_date']?.toString() ?? '-';
    final String time = req['schedule_time']?.toString() ?? '-';
    final String desc = (req['description'] != null && req['description'].toString().isNotEmpty)
        ? req['description'].toString()
        : '';
    final String status = req['status']?.toString() ?? 'PENDING';
    final String type = req['type']?.toString() ?? 'INDIVIDU';
    final bool isApproved = status == 'APPROVED' || status == 'COMPLETED';

    // Label Kategori
    String categoryLabel = 'BIMBINGAN INDIVIDU';
    if (type == 'KLASIKAL' || topic.contains('Klasikal')) {
      categoryLabel = 'BIMBINGAN KLASIKAL';
    } else if (type == 'KELOMPOK' || topic.contains('Kelompok')) {
      categoryLabel = 'BIMBINGAN KELOMPOK';
    }

    // Status label & color
    String statusLabel = 'Menunggu Persetujuan';
    Color statusColor = AppColors.warning;
    IconData statusIcon = PhosphorIcons.clock(PhosphorIconsStyle.bold);

    if (isApproved) {
      statusLabel = 'Terkonfirmasi';
      statusColor = Colors.green;
      statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
    } else if (status == 'REJECTED') {
      statusLabel = 'Ditolak';
      statusColor = AppColors.error;
      statusIcon = PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
    }

    return ItemListTile(
      category: categoryLabel,
      title: studentName,
      subcategory: className.isNotEmpty ? 'Kelas $className' : null,
      metadataText: '$date • $time WIB',
      metadataIcon: PhosphorIcons.clock(PhosphorIconsStyle.regular),
      secondaryMetadataText: topic,
      secondaryMetadataIcon: PhosphorIcons.tag(PhosphorIconsStyle.regular),
      statusText: statusLabel,
      statusIcon: statusIcon,
      statusColor: statusColor,
      bottomWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desc.isNotEmpty) ...[
            SizedBox(height: 6.h(context)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp(context),
                  color: AppColors.onBackground.withValues(alpha: 0.8),
                  height: 1.35,
                ),
              ),
            ),
          ],
          if (!isApproved && !id.startsWith('journal-')) ...[
            SizedBox(height: 10.h(context)),
            SizedBox(
              width: double.infinity,
              height: 40.h(context),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.w(context)),
                  ),
                  elevation: 0,
                ),
                icon: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.bold), size: 16.w(context)),
                label: Text(
                  'Setujui Bimbingan Ini',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  final ok = await ref.read(counselingNotifierProvider.notifier).updateStatus(
                        counselingId: id,
                        status: 'APPROVED',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Bimbingan dengan $studentName berhasil disetujui!' : 'Gagal menyetujui jadwal'),
                        backgroundColor: ok ? Colors.green : AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
