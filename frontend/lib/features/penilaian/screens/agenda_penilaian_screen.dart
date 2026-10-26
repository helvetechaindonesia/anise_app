import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';

class AgendaPenilaianScreen extends ConsumerWidget {
  const AgendaPenilaianScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Agenda Penilaian',
      ),
      body: Center(
        child: AniseEmptyState(
          icon: PhosphorIconsRegular.calendarBlank,
          title: 'Segera Hadir',
          subtitle: 'Fitur agenda penilaian sedang dalam tahap pengembangan dan akan segera tersedia.',
        ),
      ),
    );
  }
}
