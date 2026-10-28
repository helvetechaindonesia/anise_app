import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import 'faq_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import 'data_deletion_policy_screen.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  Future<void> _contactSupportWhatsApp(BuildContext context) async {
    const phone = ApiConstants.developerWhatsApp;
    const message = "Halo Tim Helpdesk Developer Helvetecha,\n\n"
        "Saya pengguna aplikasi Anise memerlukan bantuan / konsultasi teknis terkait sistem aplikasi sekolah.\n\n"
        "Mohon bantuannya ya tim. Terima kasih!";

    final encodedMessage = Uri.encodeComponent(message);
    final nativeUri = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
    final universalUri = Uri.parse('https://wa.me/$phone?text=$encodedMessage');
    final webUri = Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage');

    try {
      bool launched = false;
      if (await canLaunchUrl(nativeUri)) {
        launched = await launchUrl(nativeUri);
      }
      if (!launched && await canLaunchUrl(universalUri)) {
        launched = await launchUrl(universalUri, mode: LaunchMode.externalApplication);
      }
      if (!launched && await canLaunchUrl(webUri)) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      if (!launched && context.mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Tidak Dapat Membuka WhatsApp',
          message: 'Silakan hubungi kontak WhatsApp Developer langsung di nomor +62 819-3131-5944.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Kendala Membuka WhatsApp',
          message: 'Terjadi kendala saat membuka WhatsApp. Nomor resmi developer: +62 819-3131-5944.',
        );
      }
    }
  }

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
                  _buildSectionTitle(context, 'Pusat Bantuan & Layanan'),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.question(PhosphorIconsStyle.fill),
                    title: 'FAQ (Pertanyaan Umum)',
                    subtitle: 'Cari tahu jawaban dari masalah umum seputar aplikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FaqScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.headset(PhosphorIconsStyle.fill),
                    title: 'Hubungi Support Developer',
                    subtitle: 'Chat langsung dengan tim developer Helvetecha via WhatsApp',
                    onTap: () => _contactSupportWhatsApp(context),
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(context, 'Legalitas & Syarat Play Store'),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.fileText(PhosphorIconsStyle.fill),
                    title: 'Syarat & Ketentuan',
                    subtitle: 'Ketentuan resmi penggunaan aplikasi Anise di sekolah',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.shield(PhosphorIconsStyle.fill),
                    title: 'Kebijakan Privasi',
                    subtitle: 'Perlindungan data biometrik, lokasi, dan privasi pengguna',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildMenuCard(
                    context: context,
                    icon: PhosphorIcons.database(PhosphorIconsStyle.fill),
                    title: 'Kebijakan Penghapusan Data',
                    subtitle: 'Prosedur & formulir pengajuan hapus data akun (Play Store)',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DataDeletionPolicyScreen()),
                      );
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
