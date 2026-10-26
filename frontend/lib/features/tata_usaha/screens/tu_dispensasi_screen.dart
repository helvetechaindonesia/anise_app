import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';

class TuDispensasiScreen extends StatelessWidget {
  const TuDispensasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(title: 'Dispensasi'),
      body: Center(
        child: AniseEmptyState(
          icon: PhosphorIconsRegular.fileText,
          title: 'Segera Hadir',
          subtitle: 'Fitur permohonan dan persetujuan dispensasi sedang dalam tahap pengembangan dan akan segera hadir.',
        ),
      ),
    );
  }
}
