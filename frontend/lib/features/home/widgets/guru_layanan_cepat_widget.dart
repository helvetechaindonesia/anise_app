import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/widgets/anise_layanan_cepat.dart';

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

class GuruLayananCepatWidget extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const GuruLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final items = [
      QuickActionItem(
        icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.bold),
        label: 'Presensi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuruPresensiScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.bold),
        label: 'Jurnal',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(1);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalScreen()));
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.notebook(PhosphorIconsStyle.bold),
        label: 'Penugasan',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuruTugasScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.heart(PhosphorIconsStyle.bold),
        label: 'Pembiasaan',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuruPembiasaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold),
        label: 'KPI',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(3);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PoinScreen()));
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold),
        label: 'Agenda',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuruAgendaPenilaianScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
        label: 'Lapor',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporKesiswaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.folderUser(PhosphorIconsStyle.bold),
        label: 'E-File',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BerkasSayaScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        label: 'Disiplin',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BkDisiplinScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.scroll(PhosphorIconsStyle.bold),
        label: 'Dispensasi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuDispensasiScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.envelopeOpen(PhosphorIconsStyle.bold),
        label: 'Izin Siswa',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuIzinScreen())),
      ),
    ];

    return AniseLayananCepat(items: items);
  }
}
