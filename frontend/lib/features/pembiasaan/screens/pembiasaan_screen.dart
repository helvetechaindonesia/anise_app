import 'package:flutter/material.dart';
import '../../notifications/screens/notification_screen.dart';
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
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isGuruOrBk = user?.role == UserRole.pengajar || user?.role == UserRole.bk;
    print('DEBUG PEMBIASAAN: user is , role is , isGuruOrBk: ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: isGuruOrBk 
            ? _buildGuruView(context)
            : _buildSiswaView(context),
      ),
    );
  }

  Widget _buildGuruView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 24.h(context)),
            child: Text(
              'Daftar Siswa Pantauan',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
            ),
          ),
        ),
        const GuruPemantauanWidget(),
      ],
    );
  }

  Widget _buildSiswaView(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h(context)),
                  _buildCustomTabBar(context),
                  SizedBox(height: 16.h(context)),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _mainTabController,
        physics: const BouncingScrollPhysics(),
        children: const [
          HarianTabWidget(),
          AnalisisTabWidget(),
        ],
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
        'Pembiasaan Diri',
        style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
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
        controller: _mainTabController,
        indicator: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: BorderRadius.circular(100),
        ),
        labelColor: AppColors.surface,
        unselectedLabelColor: AppColors.onSurface.withValues(alpha: 0.5),
        labelStyle: AppTextStyles.bodyMedium(context),
        unselectedLabelStyle: AppTextStyles.bodyMedium(context),
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(100),
        tabs: const [
          Tab(text: 'Checklist Harian'),
          Tab(text: 'Analisis Grafik'),
        ],
      ),
    );
  }
}




