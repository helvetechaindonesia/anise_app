import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/widgets/anise_layanan_cepat.dart';

import '../../presensi/screens/presensi_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../../tata_usaha/screens/tu_dispensasi_screen.dart';
import '../../tata_usaha/screens/tu_kurikulum_screen.dart';
import '../../tata_usaha/screens/tu_inventaris_screen.dart';
import '../../tata_usaha/screens/tu_kesiswaan_screen.dart';
import '../../tata_usaha/screens/tu_master_user_screen.dart';
import '../../tata_usaha/screens/tu_manajemen_sekolah_screen.dart';
import '../../humas/screens/humas_screen.dart';
import '../../ai/screens/sipena_ai_screen.dart';
import '../screens/kepsek_evaluasi_tendik_screen.dart';

class KepsekLayananCepatWidget extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const KepsekLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final items = [
      QuickActionItem(
        icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold),
        label: 'Evaluasi Tendik',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KepsekEvaluasiTendikScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.fingerprint(PhosphorIconsStyle.bold),
        label: 'Presensi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PresensiScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.bold),
        label: 'Jurnal',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(1);
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.ticket(PhosphorIconsStyle.bold),
        label: 'Dispensasi',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuDispensasiScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.books(PhosphorIconsStyle.bold),
        label: 'Kurikulum',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuKurikulumScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.archive(PhosphorIconsStyle.bold),
        label: 'Inventaris',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuInventarisScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
        label: 'Kesiswaan',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuKesiswaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
        label: 'Humas',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HumasScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        label: 'Lapor',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporKesiswaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.folderUser(PhosphorIconsStyle.bold),
        label: 'E-File',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BerkasSayaScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.buildings(PhosphorIconsStyle.bold),
        label: 'Manajemen Sekolah',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuManajemenSekolahScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.bold),
        label: 'Manajemen User',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TuMasterUserScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.robot(PhosphorIconsStyle.bold),
        label: 'Sipena AI',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SipenaAiScreen())),
      ),
    ];

    return AniseLayananCepat(
      title: 'Layanan Eksekutif & Administrasi',
      items: items,
    );
  }
}
