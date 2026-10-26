import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/harian_tab.dart';
import '../widgets/analisis_tab.dart';
import '../widgets/guru_pemantauan_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

class PembiasaanScreen extends ConsumerStatefulWidget {
  const PembiasaanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PembiasaanScreen> createState() => _PembiasaanScreenState();
}

class _PembiasaanScreenState extends ConsumerState<PembiasaanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabCount = 2;
  bool _canMonitor = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkTabs(UserModel? user) {
    // Guru, BK, Tendik, Kepala Sekolah bisa memantau
    final canMonitor = user?.role == UserRole.pengajar ||
        user?.role == UserRole.bk ||
        user?.role == UserRole.kepalaSekolah ||
        user?.role == UserRole.tataUsaha;

    final targetCount = canMonitor ? 3 : 2;

    if (targetCount != _tabCount || canMonitor != _canMonitor) {
      _tabCount = targetCount;
      _canMonitor = canMonitor;
      _tabController.dispose();
      _tabController = TabController(length: _tabCount, vsync: this);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    _checkTabs(user);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h(context)),
                      _buildCustomTabBar(context),
                      SizedBox(height: 16.h(context)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Tab 1: Checklist Harian Mandiri (Siswa, Guru, Tendik, Kepsek)
              const HarianTabWidget(),

              // Tab 2: Analisis Grafik Diri Sendiri (Siswa, Guru, Tendik, Kepsek)
              const AnalisisTabWidget(),

              // Tab 3: Pantauan Anggota (Hanya untuk Guru Wali, Guru BK, Kepsek)
              if (_canMonitor)
                const CustomScrollView(
                  slivers: [
                    SliverPadding(padding: EdgeInsets.only(top: 8)),
                    GuruPemantauanWidget(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'G7-KAIH',
        style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      height: 46.h(context),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        labelColor: AppColors.surface,
        unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.5),
        labelStyle: AppTextStyles.bodySmall(context).copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.bodySmall(context),
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(100),
        tabs: [
          const Tab(text: 'Checklist'),
          const Tab(text: 'Grafik Saya'),
          if (_canMonitor)
            const Tab(text: 'Pantauan'),
        ],
      ),
    );
  }
}
