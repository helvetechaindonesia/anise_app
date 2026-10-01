import 'dart:io';

void main() {
  final content = '''
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

class LayananCepatWidget extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const LayananCepatWidget({Key? key, this.onNavigateTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), 'label': 'Presensi', 'color': const Color(0xFF90F0D5)},
      {'icon': PhosphorIcons.clock(PhosphorIconsStyle.bold), 'label': 'Jadwal', 'color': const Color(0xFFBCE3F7)},
      {'icon': PhosphorIcons.clipboardText(PhosphorIconsStyle.bold), 'label': 'Tugas', 'color': const Color(0xFFDCDAFB)},
      {'icon': PhosphorIcons.heart(PhosphorIconsStyle.bold), 'label': 'Pembiasaan', 'color': const Color(0xFFE2E0FF)},
      {'icon': PhosphorIcons.star(PhosphorIconsStyle.bold), 'label': 'Poin dan\\nPrestasi', 'color': const Color(0xFF90F0D5)},
      {'icon': PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold), 'label': 'Agenda\\nPenilaian', 'color': const Color(0xFFEBE9FF)},
      {'icon': PhosphorIcons.megaphone(PhosphorIconsStyle.bold), 'label': 'Lapor\\nKesiswaan', 'color': const Color(0xFFFFCDCD)},
      {'icon': PhosphorIcons.folderUser(PhosphorIconsStyle.bold), 'label': 'Berkas Saya', 'color': const Color(0xFF67F69B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Cepat',
          style: AppTextStyles.bodyLarge(context, color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        Spacing.custom(context, 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8.w(context),
            mainAxisSpacing: 16.h(context),
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                if (item['label'] == 'Presensi') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PresensiScreen()),
                  );
                } else if (item['label'] == 'Jadwal') {
                  if (onNavigateTab != null) {
                    onNavigateTab!(1);
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
                } else if (item['label'] == 'Poin dan\\nPrestasi') {
                  if (onNavigateTab != null) {
                    onNavigateTab!(2);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PoinScreen()),
                    );
                  }
                } else if (item['label'] == 'Agenda\\nPenilaian') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AgendaPenilaianScreen()),
                  );
                } else if (item['label'] == 'Lapor\\nKesiswaan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LaporKesiswaanScreen()),
                  );
                } else if (item['label'] == 'Berkas Saya') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BerkasSayaScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Layanan \ segera hadir!', style: AppTextStyles.bodyMedium(context)),
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
                      color: AppColors.textPrimary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.circular(20.w(context)),
                    ),
                    child: item['icon'] != null
                        ? Icon(
                            item['icon'] as IconData,
                            color: AppColors.primary,
                            size: 24.w(context),
                          )
                        : null,
                  ),
                  Spacing.custom(context, 8),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.overline(context, color: AppColors.textDark.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
''';
  File('f:/projek/anise_app/frontend/lib/features/home/widgets/layanan_cepat_widget.dart').writeAsStringSync(content);
}
