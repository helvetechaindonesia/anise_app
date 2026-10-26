import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';

class BkSuratScreen extends ConsumerWidget {
  const BkSuratScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Surat Panggilan BK',
      ),
      body: Center(
        child: AniseEmptyState(
          icon: PhosphorIconsRegular.envelope,
          title: 'Segera Hadir',
          subtitle: 'Fitur pembuatan dan pemantauan surat panggilan BK sedang dalam tahap pengembangan dan akan segera hadir.',
        ),
      ),
    );
  }
}
