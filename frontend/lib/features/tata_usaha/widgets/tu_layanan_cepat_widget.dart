import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/menu_icon_button.dart';
import '../../presensi/screens/presensi_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../screens/tu_dispensasi_screen.dart';
import '../screens/tu_kurikulum_screen.dart';
import '../screens/tu_inventaris_screen.dart';
import '../screens/tu_kesiswaan_screen.dart';
import '../screens/tu_master_user_screen.dart';
import '../screens/tu_manajemen_sekolah_screen.dart';

class TuLayananCepatWidget extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const TuLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  State<TuLayananCepatWidget> createState() => _TuLayananCepatWidgetState();
}

class _TuLayananCepatWidgetState extends State<TuLayananCepatWidget> {
  bool _isExpanded = false;

  void _navigate(BuildContext context, String label) {
    if (label == 'Presensi') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PresensiScreen()));
    } else if (label == 'Surat') {
      if (widget.onNavigateTab != null) {
        widget.onNavigateTab!(1);
      }
    } else if (label == 'Dispensasi') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TuDispensasiScreen()));
    } else if (label == 'Kurikulum') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TuKurikulumScreen()));
    } else if (label == 'Inventaris') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TuInventarisScreen()));
    } else if (label == 'Kesiswaan') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TuKesiswaanScreen()));
    } else if (label == 'Lapor') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LaporKesiswaanScreen()));
    } else if (label == 'E-File') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BerkasSayaScreen()));
    } else if (label == 'Manajemen User') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TuMasterUserScreen()));
    } else if (label == 'Manajemen Sekolah') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const TuManajemenSekolahScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label segera hadir!', style: AppTextStyles.bodyMedium(context)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allItems = [
      {'icon': PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), 'label': 'Presensi'},
      {'icon': PhosphorIcons.envelope(PhosphorIconsStyle.bold), 'label': 'Surat'},
      {'icon': PhosphorIcons.ticket(PhosphorIconsStyle.bold), 'label': 'Dispensasi'},
      {'icon': PhosphorIcons.books(PhosphorIconsStyle.bold), 'label': 'Kurikulum'},
      {'icon': PhosphorIcons.archive(PhosphorIconsStyle.bold), 'label': 'Inventaris'},
      {'icon': PhosphorIcons.usersThree(PhosphorIconsStyle.bold), 'label': 'Kesiswaan'},
      {'icon': PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), 'label': 'Lapor'},
      {'icon': PhosphorIcons.folderUser(PhosphorIconsStyle.bold), 'label': 'E-File'},
      {'icon': PhosphorIcons.buildings(PhosphorIconsStyle.bold), 'label': 'Manajemen Sekolah'},
      {'icon': PhosphorIcons.identificationCard(PhosphorIconsStyle.bold), 'label': 'Manajemen User'},
    ];

    final displayedItems = _isExpanded
        ? (List.from(allItems)..add({'icon': PhosphorIcons.caretUp(PhosphorIconsStyle.bold), 'label': 'Tutup'}))
        : (allItems.sublist(0, 7)..add({'icon': PhosphorIcons.dotsNine(PhosphorIconsStyle.bold), 'label': 'Lainnya'}));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Administrasi',
          style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
        ),
        Spacing.custom(context, 16),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.72,
              crossAxisSpacing: 8.w(context),
              mainAxisSpacing: 16.h(context),
            ),
            itemCount: displayedItems.length,
            itemBuilder: (context, index) {
              final item = displayedItems[index];
              return MenuIconButton(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                onTap: () {
                  if (item['label'] == 'Lainnya') {
                    setState(() {
                      _isExpanded = true;
                    });
                  } else if (item['label'] == 'Tutup') {
                    setState(() {
                      _isExpanded = false;
                    });
                  } else {
                    _navigate(context, item['label'] as String);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
