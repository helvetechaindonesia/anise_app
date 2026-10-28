import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/utils/responsive.dart';
import 'package:frontend/core/widgets/anise_app_bar.dart';
import 'package:frontend/core/widgets/anise_feedback_dialog.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class GantiPasswordScreen extends ConsumerStatefulWidget {
  const GantiPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends ConsumerState<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final dio = ref.read(dioProvider);

    try {
      final response = await dio.post(
        '/auth/change-password',
        data: {
          'old_password': _oldPasswordController.text,
          'new_password': _newPasswordController.text,
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.data['status'] == 'success') {
        await AniseFeedbackDialog.showSuccess(
          context,
          title: 'Kata Sandi Diperbarui',
          message: 'Kata sandi akun Anda berhasil diperbarui dengan aman!',
          buttonText: 'Selesai',
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        final msg = response.data['message'] ?? 'Gagal memperbarui kata sandi.';
        _showErrorDialog(msg);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMsg = 'Gagal mengganti password. Periksa koneksi Anda.';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMsg = data['message'] ??
            (data['errors'] != null
                ? (data['errors'] as Map).values.first[0]
                : errorMsg);
      }
      _showErrorDialog(errorMsg);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  void _showErrorDialog(String message) {
    AniseFeedbackDialog.showError(
      context,
      title: 'Gagal Ganti Kata Sandi',
      message: message,
      buttonText: 'Tutup',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverSubHeader(title: 'Ganti Kata Sandi'),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info banner
                    Container(
                      padding: EdgeInsets.all(14.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16.w(context)),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), color: AppColors.primary, size: 22.w(context)),
                          SizedBox(width: 12.w(context)),
                          Expanded(
                            child: Text(
                              'Untuk keamanan akun Anda, masukkan password lama terlebih dahulu kemudian buat password baru minimal 4 karakter.',
                              style: GoogleFonts.outfit(
                                fontSize: 13.sp(context),
                                color: AppColors.onBackground.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h(context)),

                    // 1. Password Lama
                    _buildFieldLabel('Password Lama'),
                    SizedBox(height: 8.h(context)),
                    TextFormField(
                      controller: _oldPasswordController,
                      obscureText: _obscureOld,
                      style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.onBackground),
                      decoration: _inputDecoration(
                        hint: 'Masukkan password lama Anda',
                        isObscured: _obscureOld,
                        onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Password lama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h(context)),

                    // 2. Password Baru
                    _buildFieldLabel('Password Baru'),
                    SizedBox(height: 8.h(context)),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.onBackground),
                      decoration: _inputDecoration(
                        hint: 'Masukkan password baru minimal 4 karakter',
                        isObscured: _obscureNew,
                        onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Password baru wajib diisi';
                        }
                        if (val.trim().length < 4) {
                          return 'Password baru minimal 4 karakter';
                        }
                        if (val.trim() == _oldPasswordController.text.trim()) {
                          return 'Password baru harus berbeda dari password lama';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h(context)),

                    // 3. Konfirmasi Password Baru
                    _buildFieldLabel('Konfirmasi Password Baru'),
                    SizedBox(height: 8.h(context)),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.onBackground),
                      decoration: _inputDecoration(
                        hint: 'Ulangi password baru Anda',
                        isObscured: _obscureConfirm,
                        onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Konfirmasi password baru wajib diisi';
                        }
                        if (val.trim() != _newPasswordController.text.trim()) {
                          return 'Konfirmasi password tidak cocok dengan password baru';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 36.h(context)),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 52.h(context),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w(context))),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                'Simpan Password Baru',
                                style: AppTextStyles.titleMedium(context, color: Colors.white).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 40.h(context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(fontSize: 13.sp(context), color: AppColors.onBackground.withValues(alpha: 0.45)),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Icon(PhosphorIcons.lock(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured ? PhosphorIcons.eyeClosed(PhosphorIconsStyle.bold) : PhosphorIcons.eye(PhosphorIconsStyle.bold),
          color: AppColors.onBackground.withValues(alpha: 0.5),
          size: 20.w(context),
        ),
        onPressed: onToggleVisibility,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.w(context)),
        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.w(context)),
        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.w(context)),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.w(context)),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
    );
  }
}
