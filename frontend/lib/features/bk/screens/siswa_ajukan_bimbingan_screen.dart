import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_card.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../providers/counseling_provider.dart';
import '../widgets/bk_counseling_card.dart';
import 'siswa_form_ajukan_bimbingan_screen.dart';

class SiswaAjukanBimbinganScreen extends ConsumerWidget {
  const SiswaAjukanBimbinganScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riwayatAsync = ref.watch(siswaKonsultasiProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Bimbingan Konseling (BK)',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(siswaKonsultasiProvider);
          ref.invalidate(guruBkListProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Card CTA untuk Masuk ke Form Input Ajukan Bimbingan
              _buildAjukanBimbinganCard(context),
              SizedBox(height: 24.h(context)),

              // 2. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Bimbingan Saya',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Status Terkini',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              SizedBox(height: 12.h(context)),

              // 3. List Riwayat Pengajuan Bimbingan
              riwayatAsync.when(
                data: (riwayatList) {
                  if (riwayatList.isEmpty) {
                    return AniseCard(
                      padding: EdgeInsets.symmetric(vertical: 30.h(context), horizontal: 16.w(context)),
                      child: const AniseEmptyState(
                        title: 'Belum Ada Data Bimbingan',
                        subtitle: 'Kamu belum memiliki riwayat bimbingan atau konsultasi dengan Guru BK. Klik tombol "Ajukan Sesi Bimbingan" di atas untuk membuat jadwal baru.',
                      ),
                    );
                  }

                  return Column(
                    children: riwayatList.map((item) {
                      DateTime cardDate = DateTime.now();
                      if (item['schedule_date'] != null) {
                        cardDate = DateTime.tryParse(item['schedule_date'].toString()) ?? DateTime.now();
                      }
                      return BkCounselingCard(
                        item: item,
                        selectedDate: cardDate,
                        isStudent: true,
                        onRefresh: () {
                          ref.invalidate(siswaKonsultasiProvider);
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => AniseCard(
                  padding: EdgeInsets.all(16.w(context)),
                  child: Text('Gagal memuat riwayat bimbingan: $err'),
                ),
              ),
              SizedBox(height: 30.h(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAjukanBimbinganCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SiswaFormAjukanBimbinganScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.w(context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.chatsCircle(PhosphorIconsStyle.bold),
                color: Colors.white,
                size: 26.w(context),
              ),
            ),
            SizedBox(width: 16.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajukan Sesi Bimbingan',
                    style: AppTextStyles.titleMedium(context, color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Pilih Guru BK dan tentukan waktu konsultasi',
                    style: AppTextStyles.bodySmall(context, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w(context)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                color: Colors.white,
                size: 18.w(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
