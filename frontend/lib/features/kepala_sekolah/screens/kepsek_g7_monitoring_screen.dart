import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../pembiasaan/widgets/guru_pemantauan_widget.dart';

class KepsekG7MonitoringScreen extends ConsumerWidget {
  const KepsekG7MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: const CustomScrollView(
        slivers: [
          SliverSubHeader(
            title: 'Pantau G7-KAIH',
            subtitle: 'Monitoring Pembiasaan Karakter Seluruh Warga Sekolah',
          ),
          SliverPadding(padding: EdgeInsets.only(top: 12)),
          GuruPemantauanWidget(),
          SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
