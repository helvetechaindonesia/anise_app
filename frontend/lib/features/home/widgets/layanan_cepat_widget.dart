import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/widgets/anise_layanan_cepat.dart';

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

class LayananCepatWidget extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const LayananCepatWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final items = [
      QuickActionItem(
        icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.bold),
        label: 'Presensi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.clock(PhosphorIconsStyle.bold),
        label: 'Jadwal',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(1);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalScreen()));
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.clipboardText(PhosphorIconsStyle.bold),
        label: 'Tugas',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TugasScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.heart(PhosphorIconsStyle.bold),
        label: 'Pembiasaan',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PembiasaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.star(PhosphorIconsStyle.bold),
        label: 'Poin',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(2);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PoinScreen()));
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.calendarCheck(PhosphorIconsStyle.bold),
        label: 'Agenda',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendaPenilaianScreen())),
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
        icon: PhosphorIcons.scroll(PhosphorIconsStyle.bold),
        label: 'Dispensasi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiswaAjukanDispensasiScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.envelopeOpen(PhosphorIconsStyle.bold),
        label: 'Izin',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiswaAjukanIzinScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.chats(PhosphorIconsStyle.bold),
        label: 'Bimbingan',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiswaAjukanBimbinganScreen())),
      ),
    ];

    return AniseLayananCepat(items: items);
  }
}
