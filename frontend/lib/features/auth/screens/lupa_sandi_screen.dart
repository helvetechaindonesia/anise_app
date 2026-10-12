import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_text_field.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/decorative_background.dart';
import 'package:url_launcher/url_launcher.dart';

class LupaSandiScreen extends StatefulWidget {
  const LupaSandiScreen({super.key});

  @override
  State<LupaSandiScreen> createState() => _LupaSandiScreenState();
}

class _LupaSandiScreenState extends State<LupaSandiScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(24.w(context)),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface, size: 24.w(context)),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h(context)),
                      Container(
                        padding: EdgeInsets.all(16.w(context)),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(PhosphorIcons.lockKey(PhosphorIconsStyle.fill), color: AppColors.onPrimaryContainer, size: 48.w(context)),
                      ),
                      SizedBox(height: 32.h(context)),
                      Text(
                        'Lupa\nKata Sandi?',
                        style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
                      ),
                      SizedBox(height: 16.h(context)),
                      Text(
                        'Jangan khawatir! Masukkan alamat email yang terdaftar, dan kami akan mengirimkan instruksi untuk mengatur ulang kata sandi Anda.',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                      ),
                      SizedBox(height: 48.h(context)),
                      Text(
                        'Alamat Email',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                      ),
                      SizedBox(height: 12.h(context)),
                      AniseTextField(
                        controller: _emailController,
                        hintText: 'contoh@siswa.helvetecha.sch.id',
                        icon: PhosphorIcons.envelopeSimple(),
                      ),
                      SizedBox(height: 32.h(context)),
                      AniseButton(
                        text: 'Kirim Kata Sandi ke WhatsApp',
                        icon: PhosphorIcons.whatsappLogo(PhosphorIconsStyle.fill),
                        variant: AniseButtonVariant.primary,
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Alamat email wajib diisi', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          // Tampilkan notifikasi konfirmasi WhatsApp
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Memverifikasi akun dan nomor WhatsApp...', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                              backgroundColor: AppColors.primary,
                            ),
                          );

                          // Buka WhatsApp bantuan pemulihan sandi
                          final waUrl = Uri.parse(
                            'https://wa.me/6281234567890?text=Halo%20Admin%20Sekolah%2C%20saya%20lupa%20kata%20sandi%20untuk%20akun%20email%3A%20$email.%20Mohon%20bantuan%20reset%20kata%20sandi.',
                          );
                          if (await canLaunchUrl(waUrl)) {
                            await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                          }
                          if (mounted) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

