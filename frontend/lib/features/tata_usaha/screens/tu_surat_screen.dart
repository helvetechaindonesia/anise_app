import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';

class TuSuratScreen extends ConsumerWidget {
  const TuSuratScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Persuratan Tata Usaha',
      ),
      body: Center(
        child: AniseEmptyState(
          icon: PhosphorIconsRegular.envelopeSimple,
          title: 'Segera Hadir',
          subtitle: 'Fitur persuratan dan administrasi TU sedang dalam tahap pengembangan dan akan segera hadir.',
        ),
      ),
    );
  }
}
