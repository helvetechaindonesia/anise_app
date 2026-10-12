import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../providers/auth_provider.dart';
import '../../home/screens/main_navigation_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_text_field.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/utils/shared_prefs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lupa_sandi_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _loadSavedCredentials() async {
    final creds = await SharedPrefs.getSavedCredentials();
    if (creds['rememberMe'] == true && mounted) {
      setState(() {
        _rememberMe = true;
        _usernameController.text = creds['username'];
        _passwordController.text = creds['password'];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email dan Kata Sandi wajib diisi', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(username, password);

    if (success && mounted) {
      // Simpan credentials jika sukses
      await SharedPrefs.saveCredentials(username, password, _rememberMe);
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: DecorativeBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Komponen 1: Header (Logo + Nama)
                    Container(
                      padding: EdgeInsets.all(16.w(context)),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'logo-smk',
                          child: Image.asset(
                            'assets/images/logo-smk.png',
                            height: 80.h(context),
                            width: 80.h(context),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Spacing.item(context),
                    
                    Center(
                      child: Hero(
                        tag: 'school-name',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            'SMA N 1 Peunaron',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineLarge(context, color: AppColors.onBackground),
                          ),
                        ),
                      ),
                    ),
                    Spacing.custom(context, 8),
                    
                    Center(
                      child: Hero(
                        tag: 'school-tagline',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(
                            'Anise by Helvetecha',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.8)),
                          ),
                        ),
                      ),
                    ),
                    
                    Spacing.component(context),

                    // Komponen 2: Form Login
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24.w(context)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          )
                        ],
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
                      ),
                      padding: EdgeInsets.all(24.w(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                          ),
                          Spacing.custom(context, 8),
                          AniseTextField(
                            controller: _usernameController,
                            hintText: 'Masukkan alamat email Anda...',
                            icon: PhosphorIcons.envelopeSimple(),
                          ),
                          Spacing.item(context),
                          
                          Text(
                            'Kata Sandi',
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                          ),
                          Spacing.custom(context, 8),
                          AniseTextField(
                            controller: _passwordController,
                            hintText: 'Masukan Password',
                            icon: PhosphorIcons.lockKey(),
                            isPassword: true,
                          ),
                          
                          if (authState.errorMessage != null) ...[
                            Spacing.item(context),
                            Container(
                              padding: EdgeInsets.all(12.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.w(context)),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), color: AppColors.error, size: 20.w(context)),
                                  SizedBox(width: 8.w(context)),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: AppTextStyles.labelMedium(context, color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          Spacing.item(context),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24.w(context),
                                    height: 24.w(context),
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _rememberMe = value;
                                          });
                                        }
                                      },
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      activeColor: AppColors.primary,
                                      side: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.5)),
                                    ),
                                  ),
                                  SizedBox(width: 8.w(context)),
                                  Text(
                                    'Ingat Saya',
                                    style: AppTextStyles.bodySmall(context, color: AppColors.onSurface),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LupaSandiScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Lupa Sandi?',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.bodySmall(context, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          Spacing.component(context),
                          
                          Spacing.component(context),
                          
                          // Submit Button (PillButton)
                          AniseButton(
                            text: 'Masuk ke Akun',
                            icon: PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                            isLoading: authState.status == AuthStatus.loading,
                            variant: AniseButtonVariant.primary,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                    Spacing.component(context),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIcons.question(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onBackground.withValues(alpha: 0.7)),
                        SizedBox(width: 6.w(context)),
                        Text(
                          'Butuh bantuan login?',
                          style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                        ),
                      ],
                    ),
                    Spacing.custom(context, 4),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          final uri = Uri.parse(ApiConstants.developerSupportUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tidak dapat membuka WhatsApp developer.', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Hubungi Helpdesk IT (Developer)',
                          style: AppTextStyles.bodyMedium(context, color: AppColors.primary).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Spacing.custom(context, 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

