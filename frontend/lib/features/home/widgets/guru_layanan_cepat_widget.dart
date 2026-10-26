import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../tata_usaha/screens/ajukan_ijin_screen.dart';
import '../../tata_usaha/screens/perijinan_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../ai/screens/sipena_ai_screen.dart';
import '../../humas/screens/humas_screen.dart';

class GuruLayananCepatWidget extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const GuruLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isWaliKelas = user?.isWaliKelas ?? false;
    final isHumas = user?.role == UserRole.tataUsaha ||
        user?.role == UserRole.kepalaSekolah ||
        (user?.tugasTambahan.any((t) => t.toUpperCase().contains('HUMAS')) ?? false);

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
        label: 'G7-KAIH',
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
      // Menu Ajukan Ijin (Eksklusif Pegawai ke Kepsek)
      QuickActionItem(
        icon: PhosphorIcons.envelopeOpen(PhosphorIconsStyle.bold),
        label: 'Ajukan Ijin',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AjukanIjinScreen())),
      ),
      // Menu Perijinan (Eksklusif Tenaga Pendidik yang berstatus WALI KELAS)
      if (isWaliKelas)
        QuickActionItem(
          icon: PhosphorIcons.scroll(PhosphorIconsStyle.bold),
          label: 'Perijinan',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerijinanScreen())),
        ),
      // Menu Humas (Eksklusif Penugasan Humas, Staf TU, dan Kepala Sekolah)
      if (isHumas)
        QuickActionItem(
          icon: PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
          label: 'Humas',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HumasScreen())),
        ),
      // Menu Sipena AI (Semua user tanpa terkecuali)
      QuickActionItem(
        icon: PhosphorIcons.robot(PhosphorIconsStyle.bold),
        label: 'Sipena AI',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SipenaAiScreen())),
      ),
    ];

    return AniseLayananCepat(items: items);
  }
}
