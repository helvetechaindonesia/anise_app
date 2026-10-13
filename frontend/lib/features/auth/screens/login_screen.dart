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
  final _usernameFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _rememberMe = false;
  bool _isUsernameFocused = false;
  Map<String, String> _savedAccounts = {};

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isUsernameFocused = _usernameFocusNode.hasFocus;
        });
      }
    });
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
    final accounts = await SharedPrefs.getRememberedAccounts();
    final creds = await SharedPrefs.getSavedCredentials();
    if (mounted) {
      setState(() {
        _savedAccounts = accounts;
        if (creds['rememberMe'] == true && creds['username'].toString().isNotEmpty) {
          _rememberMe = true;
          _usernameController.text = creds['username'];
          _passwordController.text = creds['password'];
        } else if (_savedAccounts.isNotEmpty) {
          // Default ke akun yang ada di daftar
          final firstEmail = _savedAccounts.keys.first;
          _usernameController.text = firstEmail;
          _passwordController.text = _savedAccounts[firstEmail] ?? '';
          _rememberMe = true;
        }
      });
    }
  }

  void _selectSavedAccount(String email, String password) {
    setState(() {
      _usernameController.text = email;
      _passwordController.text = password;
      _rememberMe = true;
    });
  }

  void _removeSavedAccount(String email) async {
    await SharedPrefs.removeRememberedAccount(email);
    final updated = await SharedPrefs.getRememberedAccounts();
    if (mounted) {
      setState(() {
        _savedAccounts = updated;
        if (_usernameController.text == email) {
          _usernameController.clear();
          _passwordController.clear();
          _rememberMe = false;
        }
      });
    }
  }

  List<MapEntry<String, String>> _getFilteredAccounts() {
    final query = _usernameController.text.trim().toLowerCase();
    if (query.isEmpty) return _savedAccounts.entries.toList();
    return _savedAccounts.entries
        .where((e) => e.key.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
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

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Format email tidak valid (contoh: siswa@sipena.sch.id)', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(username, password);

    if (success && mounted) {
      // Simpan credentials & timpa password akun jika rememberMe aktif
      await SharedPrefs.saveCredentials(username, password, _rememberMe);
      if (!mounted) return;
      
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

  Future<void> _contactHelpdeskWhatsApp() async {
    const phone = ApiConstants.developerWhatsApp; // '6281931315944'
    const message = "Halo Tim Helpdesk Developer Helvetecha Group,\n\n"
        "Saya pengguna aplikasi Anise butuh bantuan terkait kendala login / akun sekolah saya.\n\n"
        "Mohon bantuannya ya tim. Terima kasih!";

    final encodedMessage = Uri.encodeComponent(message);

    // 1. Native WhatsApp intent (langsung buka chat WhatsApp di HP)
    final nativeUri = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
    // 2. Universal wa.me URL
    final universalUri = Uri.parse('https://wa.me/$phone?text=$encodedMessage');
    // 3. Web API URL fallback
    final webUri = Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage');

    try {
      bool launched = false;

      // Coba native scheme dulu
      if (await canLaunchUrl(nativeUri)) {
        launched = await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
      }

      // Jika native belum merespon, buka via universal wa.me
      if (!launched) {
        if (await canLaunchUrl(universalUri)) {
          launched = await launchUrl(universalUri, mode: LaunchMode.externalApplication);
        } else {
          launched = await launchUrl(universalUri, mode: LaunchMode.externalApplication);
        }
      }

      if (!launched) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(universalUri, mode: LaunchMode.externalApplication);
      } catch (err) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka WhatsApp. Silakan hubungi: $phone', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
                            focusNode: _usernameFocusNode,
                            onChanged: (_) {
                              if (mounted) setState(() {});
                            },
                            hintText: 'Masukkan alamat email Anda...',
                            icon: PhosphorIcons.envelopeSimple(),
                          ),
                          // Dropdown Autofill: Hanya muncul tepat di bawah form ketika cursor/form sedang aktif
                          if (_isUsernameFocused && _getFilteredAccounts().isNotEmpty) ...[
                            Container(
                              margin: EdgeInsets.only(top: 6.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16.w(context)),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(PhosphorIcons.key(PhosphorIconsStyle.fill), size: 14.w(context), color: AppColors.primary),
                                            SizedBox(width: 6.w(context)),
                                            Text(
                                              'Pilih Akun Tersimpan (Autofill)',
                                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _usernameFocusNode.unfocus();
                                          },
                                          child: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
                                  ..._getFilteredAccounts().map((entry) {
                                    final email = entry.key;
                                    final pass = entry.value;
                                    return InkWell(
                                      onTap: () {
                                        _selectSavedAccount(email, pass);
                                        _usernameFocusNode.unfocus();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 10.h(context)),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 0.5),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(6.w(context)),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryContainer,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(PhosphorIcons.user(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.primary),
                                            ),
                                            SizedBox(width: 10.w(context)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    email,
                                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    '•••••••• (Klik untuk autofill kata sandi)',
                                                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => _removeSavedAccount(email),
                                              child: Padding(
                                                padding: EdgeInsets.all(4.w(context)),
                                                child: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 14.w(context), color: AppColors.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
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
                        onTap: _contactHelpdeskWhatsApp,
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

