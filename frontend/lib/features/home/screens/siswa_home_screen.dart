import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../jadwal/screens/jadwal_screen.dart';
import '../../presensi/screens/presensi_screen.dart';
import '../../tugas/screens/tugas_screen.dart';
import '../../pembiasaan/screens/pembiasaan_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../penilaian/screens/agenda_penilaian_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../notifications/screens/notification_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../../jadwal/screens/jadwal_guru_detail_screen.dart';
import '../../jadwal/screens/semua_pengajar_screen.dart';
import '../../tugas/screens/tugas_detail_screen.dart';
import '../../tugas/widgets/tugas_item_card.dart';
import '../widgets/identity_card_3d_widget.dart';
import '../widgets/layanan_cepat_widget.dart';
import '../widgets/bimbingan_mentor_widget.dart';
import '../widgets/tugas_mendatang_widget.dart';
import '../widgets/siswa_home_header.dart';
import '../../../core/utils/time_helper.dart';

class SiswaHomeScreen extends ConsumerStatefulWidget {
  final Function(int)? onNavigateTab;

  const SiswaHomeScreen({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  ConsumerState<SiswaHomeScreen> createState() => _SiswaHomeScreenState();
}

class _SiswaHomeScreenState extends ConsumerState<SiswaHomeScreen> {
  // Waktu logic


  final int _currentPoin = 85;
  final int _maxPoin = 100;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final userName = user?.fullName ?? 'Alivia Renata';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Background handled by DecorativeBackground
      body: DecorativeBackground(
        child: CustomScrollView(
          slivers: [
            // 1. Header (Fixed/Pinned)
            const SiswaHomeHeader(),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacing.custom(context, 10),
                    // 2. Greeting
                    Text(
                      TimeHelper.getGreeting(),
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                    ),
                    Text(
                      '$userName!!',
                      style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground), 
                    ),
                    // Spacer to Identity Card
                    Spacing.custom(context, 20),
                    
                    // 4. Kartu Identitas Digital
                    _buildIdentityCard(user),
                    Spacing.custom(context, 20),
                    
                    // 5. Layanan Cepat Grid
                    LayananCepatWidget(onNavigateTab: widget.onNavigateTab),
                    Spacing.custom(context, 24),
                    
                    // 6. Bimbingan & Mentor
                    const BimbinganMentorWidget(),
                    Spacing.custom(context, 24),
                    
                    // 7. Tugas Mendatang
                    const TugasMendatangWidget(),
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



  Widget _buildIdentityCard(UserModel? user) {
    return IdentityCard3DWidget(user: user);
  }
}


