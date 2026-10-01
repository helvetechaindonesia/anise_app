import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';
import 'biometric_registration_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile_menu_widget.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isReminderActive = true;
  String _selectedLanguage = 'Bahasa Indonesia';

  void _showLanguagePicker(BuildContext context) {
    final languages = ['Bahasa Indonesia', 'English', 'Basa Sunda', 'Basa Jawa'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w(context))),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Bahasa Aplikasi', style: AppTextStyles.bodyLarge(context, color: AppColors.onSurface)),
              SizedBox(height: 16.h(context)),
              ...languages.map((lang) {
                final isSelected = lang == _selectedLanguage;
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.w(context)),
                  title: Text(lang, style: AppTextStyles.bodyMedium(context)),
                  trailing: isSelected
                      ? Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
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
    final user = ref.watch(authProvider).user;
    final fullName = user?.fullName ?? 'Nama User';
    final role = user?.role.name.toUpperCase() ?? 'ROLE';
    final email = '${user?.username ?? 'user'}@sekolah.id';

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
                  _buildProfileCard(context, fullName, role, email),
                  SizedBox(height: 24.h(context)),
                  
                  // Biometric Registration Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24.w(context)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.menuPastelBlue.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(PhosphorIcons.userFocus(PhosphorIconsStyle.fill), color: AppColors.menuPastelBlue, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Biometrik Wajah', style: AppTextStyles.titleMedium(context)),
                                  const SizedBox(height: 4),
                                  Text('Untuk presensi & keamanan akun', style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const BiometricRegistrationScreen()),
                              );
                            },
                            icon: Icon(PhosphorIcons.scan(PhosphorIconsStyle.bold), color: Colors.white),
                            label: const Text('Daftarkan Wajah', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h(context)),
                  _buildMenuSection(context),
                  SizedBox(height: 120.h(context)),
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
      expandedHeight: 120.h(context),
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 24.w(context), bottom: 16.h(context)),
        title: Text('Profil Saya', style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground)),
      ),
      actions: [
        IconButton(
          icon: Icon(PhosphorIcons.gearSix(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
          },
        ),
        SizedBox(width: 8.w(context)),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, String fullName, String role, String email) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.w(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 72.w(context),
                    height: 72.w(context),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceVariant,
                    ),
                    child: Center(
                      child: Text(
                        fullName.substring(0, 1).toUpperCase(),
                        style: AppTextStyles.headlineMedium(context, color: AppColors.onSurface),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20.w(context),
                      height: 20.w(context),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4.h(context)),
                    Text(fullName, style: AppTextStyles.titleLarge(context, color: AppColors.onSurface)),
                    SizedBox(height: 6.h(context)),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12.w(context)),
                          ),
                          child: Text(role, style: AppTextStyles.labelSmall(context, color: AppColors.onSurface)),
                        ),
                        SizedBox(width: 8.w(context)),
                        Text('Aktif', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h(context)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Row(
              children: [
                Icon(PhosphorIcons.envelopeSimple(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 16.w(context)),
                SizedBox(width: 8.w(context)),
                Expanded(
                  child: Text(email, style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        SettingsSectionWidget(
          isReminderActive: _isReminderActive,
          onReminderChanged: (value) => setState(() => _isReminderActive = value),
          selectedLanguage: _selectedLanguage,
          onLanguageTap: () => _showLanguagePicker(context),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            icon: Icon(PhosphorIcons.signOut(), color: AppColors.error),
            label: Text('Keluar Akun', style: AppTextStyles.labelLarge(context, color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
