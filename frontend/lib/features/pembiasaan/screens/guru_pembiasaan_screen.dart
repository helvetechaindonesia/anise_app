import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/guru_pemantauan_widget.dart';

class GuruPembiasaanScreen extends StatelessWidget {
  const GuruPembiasaanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daftar Siswa Pantauan',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
        ],
      ),
      body: const CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.only(top: 24)),
          GuruPemantauanWidget(),
        ],
      ),
    );
  }
}
