import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

import '../../jadwal/screens/jadwal_screen.dart';
import '../../presensi/screens/presensi_screen.dart';
import '../../tugas/screens/tugas_screen.dart';
import '../../pembiasaan/screens/pembiasaan_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../penilaian/screens/agenda_penilaian_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../../tata_usaha/screens/siswa_ajukan_dispensasi_screen.dart';
import '../../tata_usaha/screens/siswa_ajukan_izin_screen.dart';
import '../../bk/screens/siswa_ajukan_bimbingan_screen.dart';

class LayananCepatWidget extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const LayananCepatWidget({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  State<LayananCepatWidget> createState() => _LayananCepatWidgetState();
}

class _LayananCepatWidgetState extends State<LayananCepatWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), 'label': 'Presensi', 'color': AppColors.menuPastelGreen},
      {'icon': PhosphorIcons.clock(PhosphorIconsStyle.bold), 'label': 'Jadwal', 'color': AppColors.menuPastelBlue},
      {'icon': PhosphorIcons.clipboardText(PhosphorIconsStyle.bold), 'label': 'Tugas', 'color': AppColors.menuPastelPurple},
      {'icon': PhosphorIcons.heart(PhosphorIconsStyle.bold), 'label': 'Pembiasaan', 'color': AppColors.menuPastelLilac},
      {'icon': PhosphorIcons.star(PhosphorIconsStyle.bold), 'label': 'Poin', 'color': AppColors.menuPastelGreen},
      {'icon': PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold), 'label': 'Agenda', 'color': AppColors.menuPastelGreyish},
      {'icon': PhosphorIcons.megaphone(PhosphorIconsStyle.bold), 'label': 'Lapor', 'color': AppColors.menuPastelRed},
      {'icon': PhosphorIcons.folderUser(PhosphorIconsStyle.bold), 'label': 'E-File', 'color': AppColors.menuPastelMint},
      {'icon': PhosphorIcons.scroll(PhosphorIconsStyle.bold), 'label': 'Dispensasi', 'color': AppColors.menuPastelBlue},
      {'icon': PhosphorIcons.envelopeOpen(PhosphorIconsStyle.bold), 'label': 'Izin', 'color': AppColors.menuPastelPurple},
      {'icon': PhosphorIcons.chats(PhosphorIconsStyle.bold), 'label': 'Bimbingan', 'color': AppColors.menuPastelGreen},
    ];

    final displayItems = _isExpanded
        ? (List.from(items)..add({'icon': PhosphorIcons.caretUp(PhosphorIconsStyle.bold), 'label': 'Tutup', 'color': AppColors.menuPastelGreyish}))
        : (items.sublist(0, 7)..add({'icon': PhosphorIcons.dotsNine(PhosphorIconsStyle.bold), 'label': 'Lainnya', 'color': AppColors.menuPastelGreyish}));

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
              childAspectRatio: 0.8,
              crossAxisSpacing: 8.w(context),
              mainAxisSpacing: 16.h(context),
            ),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return GestureDetector(
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
                      MaterialPageRoute(builder: (context) => const PresensiScreen()),
                    );
                  } else if (item['label'] == 'Jadwal') {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(1);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JadwalScreen()),
                      );
                    }
                  } else if (item['label'] == 'Tugas') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TugasScreen()),
                    );
                  } else if (item['label'] == 'Pembiasaan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PembiasaanScreen()),
                    );
                  } else if (item['label'] == 'Poin') {
                    if (widget.onNavigateTab != null) {
                      widget.onNavigateTab!(2);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PoinScreen()),
                      );
                    }
                  } else if (item['label'] == 'Agenda') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgendaPenilaianScreen()),
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
                  } else if (item['label'] == 'Dispensasi') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SiswaAjukanDispensasiScreen()),
                    );
                  } else if (item['label'] == 'Izin') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SiswaAjukanIzinScreen()),
                    );
                  } else if (item['label'] == 'Bimbingan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SiswaAjukanBimbinganScreen()),
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
                child: Column(
                  children: [
                    Container(
                      width: 56.w(context),
                      height: 56.w(context),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        borderRadius: BorderRadius.circular(20.w(context)),
                      ),
                      child: item['icon'] != null
                          ? Icon(
                              item['icon'] as IconData,
                              color: AppColors.onPrimaryContainer,
                              size: 24.w(context),
                            )
                          : null,
                    ),
                    Spacing.custom(context, 8),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}




