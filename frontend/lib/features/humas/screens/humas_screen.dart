import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';

class HumasScreen extends ConsumerWidget {
  const HumasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Layanan Humas',
      ),
      body: Center(
        child: AniseEmptyState(
          icon: PhosphorIconsRegular.megaphone,
          title: 'Segera Hadir',
          subtitle: 'Fitur Hubungan Masyarakat (Humas) sedang dalam tahap pengembangan dan akan segera tersedia.',
        ),
      ),
    );
  }
}
