import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../notifications/screens/notification_screen.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../widgets/lapor_form_widget.dart';

class LaporKesiswaanScreen extends StatelessWidget {
  const LaporKesiswaanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h(context)),

                    _buildInfoBanner(context),
                    SizedBox(height: 24.h(context)),
                    const LaporFormWidget(),
                    SizedBox(height: 40.h(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Lapor Kesiswaan',
        style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20.w(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w(context)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.w(context)),
            ),
            child: Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), color: AppColors.onPrimary, size: 24.w(context)),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pusat Layanan Kesiswaan & BK',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimaryContainer),
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  'Setiap laporan ditindaklanjuti secara profesional dan menjaga kode etik kerahasiaan penuh.',
                  style: AppTextStyles.labelMedium(context, color: AppColors.onPrimaryContainer.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


