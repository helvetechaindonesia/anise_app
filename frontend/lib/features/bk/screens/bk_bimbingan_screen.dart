import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/main_header.dart';
import '../../../core/widgets/anise_empty_state.dart';
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
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    // Senin minggu ini
    _weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bkSelectedDateProvider.notifier).state = _selectedDate;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    ref.read(bkSelectedDateProvider.notifier).state = date;
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bkCounselingRequestsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),
                    _buildHeader(context),
                    SizedBox(height: 20.h(context)),
                    _buildBuatJadwalCard(context),
                    SizedBox(height: 20.h(context)),
                    _buildWeeklyDateSelector(context),
                    SizedBox(height: 16.h(context)),
                  ],
                ),
              ),
            ),
            _buildCounselingRequestList(context),
            SliverToBoxAdapter(
              child: SizedBox(height: 40.h(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          'Bimbingan Konseling',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      );
    }

    return const MainHeader();
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
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                letterSpacing: 1.1,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              widget.className != null ? 'Jadwal ${widget.className}' : 'Permohonan Bimbingan',
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
            );
            if (picked != null) {
              _onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 8.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: Colors.white, size: 14.w(context)),
                SizedBox(width: 6.w(context)),
                Text(
                  'Pilih Tanggal',
                  style: AppTextStyles.labelMedium(context, color: Colors.white),
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
        padding: EdgeInsets.all(18.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.onBackground.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.plus(PhosphorIconsStyle.bold),
                color: AppColors.primary,
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
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    'Atur sesi bimbingan individu atau klasikal',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
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

  Widget _buildWeeklyDateSelector(BuildContext context) {
    const daysLabel = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];

    return SizedBox(
      height: 72.h(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = _weekStart.add(Duration(days: index));
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          return GestureDetector(
            onTap: () => _onDateSelected(date),
            child: Container(
              width: 54.w(context),
              margin: EdgeInsets.only(right: 10.w(context)),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16.w(context)),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    daysLabel[index],
                    style: GoogleFonts.outfit(
                      fontSize: 11.sp(context),
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.onBackground.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp(context),
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.onBackground,
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
                  icon: PhosphorIconsRegular.calendarBlank,
                  title: 'Tidak Ada Bimbingan',
                  subtitle: 'Belum ada pengajuan bimbingan siswa pada ${_formatDateHeader(_selectedDate)}.',
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
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h(context)),
                  child: _buildRequestCard(context, req),
                );
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
          child: Text('Gagal memuat permohonan bimbingan: $err'),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> req) {
    final String id = req['id']?.toString() ?? '';
    final String studentName = req['student_name']?.toString() ?? 'Siswa';
    final String className = req['class_name']?.toString() ?? '';
    final String topic = req['topic']?.toString() ?? 'Bimbingan';
    final String date = req['schedule_date']?.toString() ?? '-';
    final String time = req['schedule_time']?.toString() ?? '-';
    final String desc = (req['description'] != null && req['description'].toString().isNotEmpty)
        ? req['description'].toString()
        : 'Tidak ada deskripsi keluhan tambahan.';
    final String status = req['status']?.toString() ?? 'PENDING';
    final bool isApproved = status == 'APPROVED' || status == 'COMPLETED';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.w(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Nama Siswa, Kelas & Badge Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.w(context),
                height: 42.w(context),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.user(PhosphorIconsStyle.bold),
                  color: AppColors.onPrimaryContainer,
                  size: 20.w(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (className.isNotEmpty) ...[
                      SizedBox(height: 2.h(context)),
                      Text(
                        'Kelas: $className',
                        style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: isApproved
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.w(context)),
                ),
                child: Text(
                  isApproved ? 'Disetujui' : 'Menunggu',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp(context),
                    fontWeight: FontWeight.w600,
                    color: isApproved ? AppColors.primary : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h(context)),

          // Baris 2: Topik Bimbingan
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w(context), vertical: 6.h(context)),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.w(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.tag(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.primary),
                SizedBox(width: 6.w(context)),
                Text(
                  'Topik: $topic',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h(context)),

          // Baris 3: Tanggal & Waktu Pelaksanaan
          Row(
            children: [
              Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), size: 16.w(context), color: AppColors.onBackground.withValues(alpha: 0.7)),
              SizedBox(width: 6.w(context)),
              Text(
                '$date • Pukul $time WIB',
                style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.8)).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),

          // Baris 4: Deskripsi Keluhan
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w(context)),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deskripsi / Catatan Siswa:',
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp(context),
                    color: AppColors.onBackground.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp(context),
                    color: AppColors.onBackground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h(context)),

          // Baris 5: Tombol Setujui Bimbingan di Paling Bawah
          if (!isApproved) ...[
            SizedBox(
              width: double.infinity,
              height: 46.h(context),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  elevation: 0,
                ),
                icon: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.bold), size: 18.w(context)),
                label: Text(
                  'Setujui Bimbingan',
                  style: AppTextStyles.titleSmall(context, color: Colors.white).copyWith(
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
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h(context)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.check(PhosphorIconsStyle.bold), color: AppColors.primary, size: 16.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'Sesi bimbingan telah dikonfirmasi',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
