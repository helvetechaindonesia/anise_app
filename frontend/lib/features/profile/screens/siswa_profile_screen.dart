import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/profile_menu_widget.dart';
import '../widgets/siswa_profile_card_widget.dart';
import '../widgets/siswa_stats_row_widget.dart';

class SiswaProfileScreen extends ConsumerStatefulWidget {
  const SiswaProfileScreen({super.key});

  @override
  ConsumerState<SiswaProfileScreen> createState() => _SiswaProfileScreenState();
}

class _SiswaProfileScreenState extends ConsumerState<SiswaProfileScreen> {
  bool _isReminderActive = true;
  String _selectedLanguage = 'Bahasa Indonesia';

  void _showLanguagePicker(BuildContext context) {
    final languages = [
      'Bahasa Indonesia',
      'English',
      'Basa Sunda',
      'Basa Jawa',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.w(context)),
        ),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Bahasa Aplikasi',
                style: AppTextStyles.bodyLarge(
                  context,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 16.h(context)),
              ...languages.map((lang) {
                final isSelected = lang == _selectedLanguage;
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.w(context),
                  ),
                  title: Text(lang, style: AppTextStyles.bodyMedium(context)),
                  trailing: isSelected
                      ? Icon(
                          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLanguage = lang;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h(context)),
                  const SiswaProfileCardWidget(),
                  SizedBox(height: 24.h(context)),
                  const SiswaStatsRowWidget(),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(
                    context,
                    'BIODATA DIRI SINKRON DAPODIK',
                    'Perbarui',
                  ),
                  SizedBox(height: 12.h(context)),
                  const BiodataSectionWidget(),
                  SizedBox(height: 24.h(context)),

                  // 4. Pengaturan
                  _buildSectionTitle(context, 'PENGATURAN & LAINNYA', null),
                  SizedBox(height: 12.h(context)),
                  SettingsSectionWidget(
                    isReminderActive: _isReminderActive,
                    onReminderChanged: (value) {
                      setState(() {
                        _isReminderActive = value;
                      });
                    },
                    selectedLanguage: _selectedLanguage,
                    onLanguageTap: () => _showLanguagePicker(context),
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildLogoutButton(context),
                  SizedBox(height: 40.h(context)),
                  _buildFooter(context),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ),
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
                'Anise By Helvetecha',
                style: AppTextStyles.labelMedium(
                  context,
                  color: AppColors.onSurface,
                ),
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
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          icon: Icon(
            PhosphorIcons.bell(PhosphorIconsStyle.bold),
            color: AppColors.onSurface,
            size: 24.w(context),
          ),
        ),
        SizedBox(width: 16.w(context)),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    String? actionText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.labelMedium(
            context,
            color: AppColors.onBackground,
          ),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: AppTextStyles.labelMedium(
              context,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final navigator = Navigator.of(context);
        await ref.read(authProvider.notifier).logout();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.w(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.signOut(PhosphorIconsStyle.bold),
              color: AppColors.error,
              size: 20.w(context),
            ),
            SizedBox(width: 12.w(context)),
            Text(
              'Keluar dari Akun Siswa',
              style: AppTextStyles.bodyMedium(
                context,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        'Anise SIS Client â€¢ Versi 2.4.1 (Build 890)',
        style: AppTextStyles.labelMedium(
          context,
          color: AppColors.onBackground.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}


