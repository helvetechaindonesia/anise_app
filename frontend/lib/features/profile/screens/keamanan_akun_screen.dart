import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class KeamananAkunScreen extends StatelessWidget {
  const KeamananAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle(context, 'Kata Sandi & Autentikasi'),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.key(PhosphorIconsStyle.fill),
                    title: 'Ubah Kata Sandi',
                    subtitle: 'Terakhir diubah 3 bulan lalu',
                    onTap: () {},
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.fill),
                    title: 'Autentikasi Biometrik',
                    subtitle: 'Gunakan sidik jari untuk login',
                    isToggle: true,
                    toggleValue: true,
                    onTap: () {},
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(context, 'Perangkat Terhubung'),
                  SizedBox(height: 12.h(context)),
                  _buildDeviceCard(
                    context: context,
                    deviceName: 'Samsung Galaxy S23',
                    location: 'Jakarta, Indonesia',
                    time: 'Sedang aktif',
                    isCurrentDevice: true,
                    icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill),
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildDeviceCard(
                    context: context,
                    deviceName: 'Windows PC (Chrome)',
                    location: 'Jakarta, Indonesia',
                    time: 'Terakhir aktif 2 hari lalu',
                    isCurrentDevice: false,
                    icon: PhosphorIcons.monitor(PhosphorIconsStyle.fill),
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(context, 'Data Akun'),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
                    title: 'Hapus Akun',
                    subtitle: 'Hapus akun dan semua data Anda permanen',
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
                    onTap: () {},
                  ),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
          Text(
            'Keamanan & Privasi',
            style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isToggle = false,
    bool toggleValue = false,
    Color? titleColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: isToggle ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24.w(context)),
            ),
            SizedBox(width: 16.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium(context, color: titleColor ?? AppColors.onSurface)),
                  SizedBox(height: 4.h(context)),
                  Text(subtitle, style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            if (isToggle)
              Switch(
                value: toggleValue,
                onChanged: (val) {},
                activeColor: AppColors.primary,
              )
            else
              Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.3), size: 16.w(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required String deviceName,
    required String location,
    required String time,
    required bool isCurrentDevice,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.onPrimaryContainer, size: 24.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(deviceName, style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                    if (isCurrentDevice) ...[
                      SizedBox(width: 8.w(context)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w(context), vertical: 2.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('Ini', style: AppTextStyles.labelSmall(context, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h(context)),
                Text(location, style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                SizedBox(height: 4.h(context)),
                Text(time, style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5))),
              ],
            ),
          ),
          if (!isCurrentDevice)
            IconButton(
              onPressed: () {},
              icon: Icon(PhosphorIcons.signOut(PhosphorIconsStyle.bold), color: AppColors.error, size: 20.w(context)),
            ),
        ],
      ),
    );
  }
}
