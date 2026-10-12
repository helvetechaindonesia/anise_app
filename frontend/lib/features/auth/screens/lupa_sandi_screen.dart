import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_text_field.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/decorative_background.dart';

class LupaSandiScreen extends StatefulWidget {
  const LupaSandiScreen({super.key});

  @override
  State<LupaSandiScreen> createState() => _LupaSandiScreenState();
}

class _LupaSandiScreenState extends State<LupaSandiScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
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

    setState(() {
      _isLoading = true;
    });

    try {
      String? targetPhone;
      String userName = 'Pengguna';

      try {
        final dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));
        final response = await dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.forgotPasswordEndpoint}',
          data: {'email': email},
          options: Options(headers: {'Accept': 'application/json'}),
        );

        if (response.statusCode == 200 && response.data['data'] != null) {
          final data = response.data['data'];
          targetPhone = data['whatsapp_phone'];
          userName = data['user_name'] ?? userName;
        }
      } catch (e) {
        // Fallback untuk akun demo siswa jika endpoint belum dideploy ke server VPS
        if (email.toLowerCase() == 'siswa@sipena.sch.id') {
          targetPhone = '6287794274408';
          userName = 'Andi Wijaya';
        } else {
          rethrow;
        }
      }

      if (targetPhone == null || targetPhone.isEmpty) {
        throw Exception('Nomor WhatsApp tidak ditemukan pada akun ini.');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membuka WhatsApp ke $targetPhone...', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
          backgroundColor: AppColors.primary,
        ),
      );

      final message = 'Halo $userName, ini adalah permohonan pemulihan kata sandi aplikasi Anise untuk akun ($email).';
      final encodedMessage = Uri.encodeComponent(message);
      final waUrl = Uri.parse('https://wa.me/$targetPhone?text=$encodedMessage');

      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka WhatsApp. Pastikan aplikasi WhatsApp terpasang.', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
            backgroundColor: AppColors.error,
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      String errorMsg = 'Terjadi kesalahan saat memverifikasi nomor WhatsApp.';
      if (e is DioException && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                        'Masukkan alamat email yang terdaftar. Sistem akan memverifikasi akun Anda dan langsung mengarahkan Anda ke WhatsApp untuk pemulihan kata sandi.',
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
                        hintText: 'contoh: siswa@sipena.sch.id',
                        icon: PhosphorIcons.envelopeSimple(),
                      ),
                      SizedBox(height: 32.h(context)),
                      AniseButton(
                        text: 'Kirim Kata Sandi ke WhatsApp',
                        icon: PhosphorIcons.whatsappLogo(PhosphorIconsStyle.fill),
                        variant: AniseButtonVariant.primary,
                        isLoading: _isLoading,
                        onPressed: _handleForgotPassword,
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

