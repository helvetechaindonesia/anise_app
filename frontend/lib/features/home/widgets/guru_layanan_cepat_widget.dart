import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/menu_icon_button.dart';

import '../../jadwal/screens/jadwal_screen.dart';
import '../../tugas/screens/guru_tugas_screen.dart';
import '../../pembiasaan/screens/guru_pembiasaan_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../../presensi/screens/guru_presensi_screen.dart';
import '../../penilaian/screens/guru_agenda_penilaian_screen.dart';
import '../../bk/screens/bk_disiplin_screen.dart';
import '../../tata_usaha/screens/tu_dispensasi_screen.dart';
import '../../tata_usaha/screens/tu_izin_screen.dart';

class GuruLayananCepatWidget extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const GuruLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  State<GuruLayananCepatWidget> createState() => _GuruLayananCepatWidgetState();
}

class _GuruLayananCepatWidgetState extends State<GuruLayananCepatWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), 'label': 'Presensi'},
      {'icon': PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.bold), 'label': 'Jurnal'},
      {'icon': PhosphorIcons.notebook(PhosphorIconsStyle.bold), 'label': 'Penugasan'},
      {'icon': PhosphorIcons.heart(PhosphorIconsStyle.bold), 'label': 'Pembiasaan'},
      {'icon': PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold), 'label': 'KPI'},
      {'icon': PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold), 'label': 'Agenda'},
      {'icon': PhosphorIcons.megaphone(PhosphorIconsStyle.bold), 'label': 'Lapor'},
      {'icon': PhosphorIcons.folderUser(PhosphorIconsStyle.bold), 'label': 'E-File'},
      {'icon': PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), 'label': 'Disiplin'},
      {'icon': PhosphorIcons.scroll(PhosphorIconsStyle.bold), 'label': 'Dispensasi'},
      {'icon': PhosphorIcons.envelopeOpen(PhosphorIconsStyle.bold), 'label': 'Izin Siswa'},
    ];

    final displayItems = _isExpanded
        ? (List.from(items)..add({'icon': PhosphorIcons.caretUp(PhosphorIconsStyle.bold), 'label': 'Tutup'}))
        : (items.sublist(0, 7)..add({'icon': PhosphorIcons.dotsNine(PhosphorIconsStyle.bold), 'label': 'Lainnya'}));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Cepat',
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
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
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
                  } else if (item['label'] == 'Presensi') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuruPresensiScreen()),
                    );
                  } else if (item['label'] == 'Jurnal') {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(1);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JadwalScreen()),
                      );
                    }
                  } else if (item['label'] == 'Penugasan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuruTugasScreen()),
                    );
                  } else if (item['label'] == 'Pembiasaan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuruPembiasaanScreen()),
                    );
                  } else if (item['label'] == 'KPI') {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(3);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PoinScreen()),
                      );
                    }
                  } else if (item['label'] == 'Agenda') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuruAgendaPenilaianScreen()),
                    );
                  } else if (item['label'] == 'Lapor') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LaporKesiswaanScreen()),
                    );
                  } else if (item['label'] == 'E-File') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BerkasSayaScreen()),
                    );
                  } else if (item['label'] == 'Disiplin') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BkDisiplinScreen()),
                    );
                  } else if (item['label'] == 'Dispensasi') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TuDispensasiScreen()),
                    );
                  } else if (item['label'] == 'Izin Siswa') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TuIzinScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Layanan segera hadir!', style: AppTextStyles.bodyMedium(context)),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
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




