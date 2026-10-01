import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../screens/keamanan_akun_screen.dart';
import '../screens/bantuan_screen.dart';

class InfoItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  const InfoItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.showDivider,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h(context)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12.w(context)),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.onPrimaryContainer,
                    size: 20.w(context),
                  ),
                ),
                SizedBox(width: 16.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium(
                          context,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelMedium(
                          context,
                          color: AppColors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: 12.w(context)),
                  trailing!,
                ],
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: EdgeInsets.only(left: 48.w(context)),
              child: Divider(color: AppColors.outline, height: 1),
            ),
        ],
      ),
    );
  }
}

class BiodataSectionWidget extends StatelessWidget {
  const BiodataSectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 8.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
        
      ),
      child: Column(
        children: [
          InfoItemWidget(
            icon: PhosphorIcons.cake(PhosphorIconsStyle.fill),
            title: 'Tempat, Tanggal Lahir',
            subtitle: 'Jakarta, 14 Mei 2008',
            showDivider: true,
          ),
          InfoItemWidget(
            icon: PhosphorIcons.deviceMobile(PhosphorIconsStyle.fill),
            title: 'Nomor Telepon Siswa',
            subtitle: '+62 812-9844-3210',
            showDivider: true,
          ),
          InfoItemWidget(
            icon: PhosphorIcons.users(PhosphorIconsStyle.fill),
            title: 'Nama Wali / Orang Tua',
            subtitle: 'Ir. Hendro Prabowo',
            showDivider: true,
          ),
          InfoItemWidget(
            icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
            title: 'Alamat Domisili',
            subtitle: 'Jl. Senopati No. 42, Kebayoran Baru, Jakarta Selatan',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class SettingsSectionWidget extends StatelessWidget {
  final bool isReminderActive;
  final ValueChanged<bool> onReminderChanged;
  final String selectedLanguage;
  final VoidCallback onLanguageTap;

  const SettingsSectionWidget({
    Key? key,
    required this.isReminderActive,
    required this.onReminderChanged,
    required this.selectedLanguage,
    required this.onLanguageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 8.h(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.w(context)),
      ),
      child: Column(
        children: [
          InfoItemWidget(
            icon: PhosphorIcons.bellRinging(PhosphorIconsStyle.fill),
            title: 'Pengingat Tugas & Presensi',
            subtitle: 'Aktifkan notifikasi',
            trailing: CupertinoSwitch(
              value: isReminderActive,
              onChanged: onReminderChanged,
              activeColor: AppColors.primary,
            ),
            showDivider: true,
          ),
          InfoItemWidget(
            icon: PhosphorIcons.translate(PhosphorIconsStyle.fill),
            title: 'Bahasa Aplikasi',
            subtitle: selectedLanguage,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.5), size: 16.w(context)),
              ],
            ),
            showDivider: true,
            onTap: onLanguageTap,
          ),
          InfoItemWidget(
            icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
            title: 'Keamanan Akun & Kata Sandi',
            subtitle: 'Terakhir diubah 3 bulan lalu',
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.5), size: 16.w(context)),
            showDivider: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KeamananAkunScreen()),
              );
            },
          ),
          InfoItemWidget(
            icon: PhosphorIcons.newspaper(PhosphorIconsStyle.fill),
            title: 'Bantuan & Kebijakan',
            subtitle: 'Pusat bantuan',
            trailing: Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.5), size: 16.w(context)),
            showDivider: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BantuanScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

