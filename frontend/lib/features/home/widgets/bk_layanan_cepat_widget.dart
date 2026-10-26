import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/widgets/anise_layanan_cepat.dart';

import '../../presensi/screens/guru_presensi_screen.dart';
import '../../pembiasaan/screens/guru_pembiasaan_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../lapor/screens/lapor_kesiswaan_screen.dart';
import '../../berkas/screens/berkas_saya_screen.dart';
import '../../bk/screens/bk_disiplin_screen.dart';
import '../../bk/screens/bk_surat_screen.dart';
import '../../bk/screens/bk_bimbingan_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../../humas/screens/humas_screen.dart';
import '../../ai/screens/sipena_ai_screen.dart';

class BkLayananCepatWidget extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const BkLayananCepatWidget({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
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
        icon: PhosphorIcons.usersThree(PhosphorIconsStyle.bold),
        label: 'Bimbingan',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(1);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BkBimbinganScreen(className: 'Semua Kelas')));
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.star(PhosphorIconsStyle.bold),
        label: 'G7-KAIH',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuruPembiasaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.bold),
        label: 'KPI',
        onTap: () {
          if (onNavigateTab != null) {
            onNavigateTab!(2);
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PoinScreen()));
          }
        },
      ),
      QuickActionItem(
        icon: PhosphorIcons.warningCircle(PhosphorIconsStyle.bold),
        label: 'Disiplin',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BkDisiplinScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
        label: 'Lapor',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LaporKesiswaanScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.envelope(PhosphorIconsStyle.bold),
        label: 'Surat',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BkSuratScreen())),
      ),
      QuickActionItem(
        icon: PhosphorIcons.folderUser(PhosphorIconsStyle.bold),
        label: 'E-File',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BerkasSayaScreen())),
      ),
      if (isHumas)
        QuickActionItem(
          icon: PhosphorIcons.megaphone(PhosphorIconsStyle.bold),
          label: 'Humas',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HumasScreen())),
        ),
      QuickActionItem(
        icon: PhosphorIcons.robot(PhosphorIconsStyle.bold),
        label: 'Sipena AI',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SipenaAiScreen())),
      ),
    ];

    return AniseLayananCepat(items: items);
  }
}
