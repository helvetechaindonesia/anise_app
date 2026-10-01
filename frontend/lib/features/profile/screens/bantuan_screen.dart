import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSectionTitle(context, 'Pusat Bantuan'),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.question(PhosphorIconsStyle.fill),
                    title: 'FAQ (Pertanyaan Umum)',
                    subtitle: 'Cari tahu jawaban dari masalah umum',
                    onTap: () {},
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.headset(PhosphorIconsStyle.fill),
                    title: 'Hubungi Support',
                    subtitle: 'Chat dengan tim IT sekolah via WhatsApp',
                    onTap: () {},
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(context, 'Legal & PlayStore Requirements'),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.fileText(PhosphorIconsStyle.fill),
                    title: 'Syarat & Ketentuan',
                    subtitle: 'Terms of Service penggunaan aplikasi Anise',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Buka URL Syarat & Ketentuan')));
                    },
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.shield(PhosphorIconsStyle.fill),
                    title: 'Kebijakan Privasi',
                    subtitle: 'Privacy Policy terkait data siswa & guru',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Buka URL Kebijakan Privasi')));
                    },
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.database(PhosphorIconsStyle.fill),
                    title: 'Kebijakan Penghapusan Data',
                    subtitle: 'Formulir request hapus data akun (Wajib PlayStore)',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Buka URL Penghapusan Data')));
                    },
                  ),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
          Text(
            'Bantuan & Kebijakan',
            style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w(context)),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.secondary, size: 24.w(context)),
            ),
            SizedBox(width: 16.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                  SizedBox(height: 4.h(context)),
                  Text(subtitle, style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.3), size: 16.w(context)),
          ],
        ),
      ),
    );
  }
}
