import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/menu_icon_button.dart';
import '../../presensi/screens/guru_presensi_screen.dart';
import '../../pembiasaan/screens/guru_pembiasaan_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../../bk/screens/bk_disiplin_screen.dart';
import '../../bk/screens/bk_surat_screen.dart';
import '../../bk/screens/bk_bimbingan_screen.dart';

class BkLayananCepatWidget extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const BkLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), 'label': 'Presensi'},
      {'icon': PhosphorIcons.usersThree(PhosphorIconsStyle.bold), 'label': 'Bimbingan'},
      {'icon': PhosphorIcons.star(PhosphorIconsStyle.bold), 'label': 'Pembiasaan'},
      {'icon': PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold), 'label': 'KPI'},
      {'icon': PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), 'label': 'Disiplin'},
      {'icon': PhosphorIcons.megaphone(PhosphorIconsStyle.bold), 'label': 'Lapor'},
      {'icon': PhosphorIcons.envelope(PhosphorIconsStyle.bold), 'label': 'Surat'},
      {'icon': PhosphorIcons.folderUser(PhosphorIconsStyle.bold), 'label': 'E-File'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Cepat',
          style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
        ),
        Spacing.custom(context, 16),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.72,
            crossAxisSpacing: 8.w(context),
            mainAxisSpacing: 16.h(context),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return MenuIconButton(
              icon: item['icon'] as IconData,
              label: item['label'] as String,
              onTap: () {
                if (item['label'] == 'Presensi') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuruPresensiScreen()),
                  );
                } else if (item['label'] == 'Bimbingan') {
                  if (onNavigateTab != null) {
                    onNavigateTab!(1);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BkBimbinganScreen(className: 'Semua Kelas')),
                    );
                  }
                } else if (item['label'] == 'Pembiasaan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GuruPembiasaanScreen()),
                  );
                } else if (item['label'] == 'KPI') {
                  if (onNavigateTab != null) {
                    onNavigateTab!(2);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PoinScreen()),
                    );
                  }
                } else if (item['label'] == 'Disiplin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BkDisiplinScreen()),
                  );
                } else if (item['label'] == 'Lapor') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LaporKesiswaanScreen()),
                  );
                } else if (item['label'] == 'Surat') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BkSuratScreen()),
                  );
                } else if (item['label'] == 'E-File') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BerkasSayaScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['label']} segera hadir!', style: AppTextStyles.bodyMedium(context)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}



