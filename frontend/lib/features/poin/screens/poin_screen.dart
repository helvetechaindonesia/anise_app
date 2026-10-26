import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/main_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../kepala_sekolah/widgets/predikat_kinerja_card.dart';
import '../../kepala_sekolah/screens/kepsek_kpi_monitoring_screen.dart';

import '../widgets/poin_header_widget.dart';
import '../widgets/poin_main_card_widget.dart';
import '../widgets/poin_activity_list_widget.dart';
import '../widgets/poin_target_card_widget.dart';

class PoinScreen extends ConsumerStatefulWidget {
  const PoinScreen({super.key});

  @override
  ConsumerState<PoinScreen> createState() => _PoinScreenState();
}

class _PoinScreenState extends ConsumerState<PoinScreen> {
  bool _isLoadingEval = false;
  Map<String, dynamic>? _myEvaluation;
  Map<String, dynamic>? _currentAcademicYear;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null && user.role != UserRole.siswa && user.role != UserRole.kepalaSekolah) {
        _fetchMyEvaluation();
      }
    });
  }

  Future<void> _fetchMyEvaluation() async {
    setState(() => _isLoadingEval = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/kpi/evaluations');
      if (response.data['status'] == 'success') {
        final data = response.data['data'] as Map<String, dynamic>;
        setState(() {
          _myEvaluation = data['my_evaluation'] as Map<String, dynamic>?;
          _currentAcademicYear = data['current_academic_year'] as Map<String, dynamic>?;
        });
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingEval = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final bool isSiswa = user?.role == UserRole.siswa;
    final bool isKepsek = user?.role == UserRole.kepalaSekolah;

    // Jika user adalah Kepala Sekolah, tampilkan Layar Monitoring KPI seluruh tendik
    if (isKepsek) {
      return const KepsekKpiMonitoringScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          const MainHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h(context)),

                  // Jika user adalah Tenaga Pendidik / Guru / TU: Tampilkan Kartu Predikat Kinerja dari Kepala Sekolah
                  if (!isSiswa) ...[
                    _buildKpiTendikHeader(context),
                    SizedBox(height: 16.h(context)),
                    if (_isLoadingEval)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (_myEvaluation != null)
                      PredikatKinerjaCard(
                        praktikKinerja: _myEvaluation!['praktik_kinerja'] ?? 'SESUAI_EKSPEKTASI',
                        perilakuKerja: _myEvaluation!['perilaku_kerja'] ?? 'SESUAI_EKSPEKTASI',
                        predikatKinerja: _myEvaluation!['predikat_kinerja'] ?? 'BAIK',
                        periodLabel: _currentAcademicYear?['semester'] == 'GENAP' ? 'Januari - Juni' : 'Juli - Desember',
                        notes: _myEvaluation!['notes'],
                      )
                    else
                      _buildBelumAdaEvaluasiCard(context),
                    SizedBox(height: 24.h(context)),
                  ],

                  // Poin Disiplin Siswa / Komponen Poin Universal
                  const PoinHeaderWidget(),
                  SizedBox(height: 24.h(context)),
                  const PoinMainCardWidget(),
                  SizedBox(height: 24.h(context)),
                  const PoinActivityListWidget(),
                  SizedBox(height: 24.h(context)),
                  const PoinTargetCardWidget(),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiTendikHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EVALUASI KINERJA TENDIK',
          style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4.h(context)),
        Text(
          'Penilaian Kepala Sekolah',
          style: AppTextStyles.headlineMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildBelumAdaEvaluasiCard(BuildContext context) {
    final periodLabel = _currentAcademicYear?['semester'] == 'GENAP' ? 'Januari - Juni' : 'Juli - Desember';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.pending_actions_rounded, size: 48.w(context), color: AppColors.primary.withValues(alpha: 0.6)),
          SizedBox(height: 12.h(context)),
          Text(
            'Evaluasi Periode Ini Belum Diterbitkan',
            style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'Penilaian kualitatif untuk semester ($periodLabel) sedang dalam proses penilaian oleh Kepala Sekolah.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
