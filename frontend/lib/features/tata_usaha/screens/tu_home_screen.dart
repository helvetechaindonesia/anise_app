import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/time_helper.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../home/widgets/siswa_home_header.dart';
import '../../home/widgets/guru_identity_card_3d_widget.dart';
import '../widgets/tu_layanan_cepat_widget.dart';
import '../widgets/tu_ringkasan_surat_widget.dart';
import '../widgets/tu_pengajuan_dispensasi_widget.dart';
import '../../auth/providers/auth_provider.dart';
class TuHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const TuHomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  ConsumerState<TuHomeScreen> createState() => _TuHomeScreenState();
}

class _TuHomeScreenState extends ConsumerState<TuHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = user?.fullName ?? 'Staf Tata Usaha';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            const SiswaHomeHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing.custom(context, 10),
                    Text(
                      TimeHelper.getGreeting(),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                    ),
                    Text(
                      '$userName!!',
                      style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground), 
                    ),
                    Spacing.custom(context, 20),
                    GuruIdentityCard3DWidget(user: user),
                    Spacing.custom(context, 20),
                    TuLayananCepatWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 24),
                    const TuRingkasanSuratWidget(),
                    Spacing.custom(context, 24),
                    const TuPengajuanDispensasiWidget(),
                    Spacing.custom(context, 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
