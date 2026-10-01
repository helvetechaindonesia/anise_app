import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/dio_client.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nisnController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isInit = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        _nameController.text = user.fullName;
        _nisnController.text = user.uniqueId ?? '';
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
        _parentController.text = user.parentName ?? '';
        _addressController.text = user.address ?? '';
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nisnController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _parentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/profile', data: {
        'full_name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'parent_name': _parentController.text,
        'address': _addressController.text,
      });

      if (response.statusCode == 200) {
        // Refresh auth state to get new profile data
        await ref.read(authProvider.notifier).checkAuth();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h(context), left: 4.w(context)),
      child: Text(
        label,
        style: AppTextStyles.bodySmall(
          context,
          color: AppColors.onBackground.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isSiswa = user?.role == 'SISWA';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'Edit Profil',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
            color: AppColors.onBackground,
            size: 20.w(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 24.w(context),
          vertical: 24.h(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100.w(context),
                    height: 100.w(context),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer,
                      border: Border.all(
                        color: AppColors.primaryContainer,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      PhosphorIcons.user(PhosphorIconsStyle.fill),
                      color: AppColors.onPrimaryContainer,
                      size: 48.w(context),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundLight,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      PhosphorIcons.camera(PhosphorIconsStyle.fill),
                      color: AppColors.onPrimary,
                      size: 16.w(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h(context)),
            _buildFieldLabel('Nama Lengkap'),
            AniseTextField(
              controller: _nameController,
              hintText: 'Masukkan nama lengkap',
              icon: PhosphorIcons.user(),
            ),
            SizedBox(height: 16.h(context)),
            _buildFieldLabel(isSiswa ? 'NISN / NIS' : 'ID Pengguna'),
            AniseTextField(
              controller: _nisnController,
              hintText: 'ID',
              icon: PhosphorIcons.identificationCard(),
              enabled: false, 
            ),
            SizedBox(height: 16.h(context)),
            _buildFieldLabel('Email'),
            AniseTextField(
              controller: _emailController,
              hintText: 'Masukkan email aktif',
              icon: PhosphorIcons.envelopeSimple(),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h(context)),
            _buildFieldLabel('Nomor Telepon'),
            AniseTextField(
              controller: _phoneController,
              hintText: 'Masukkan nomor telepon',
              icon: PhosphorIcons.phone(),
              keyboardType: TextInputType.phone,
            ),
            if (isSiswa) ...[
              SizedBox(height: 16.h(context)),
              _buildFieldLabel('Nama Orang Tua / Wali'),
              AniseTextField(
                controller: _parentController,
                hintText: 'Masukkan nama orang tua',
                icon: PhosphorIcons.users(),
              ),
            ],
            SizedBox(height: 16.h(context)),
            _buildFieldLabel('Alamat Tempat Tinggal'),
            AniseTextField(
              controller: _addressController,
              hintText: 'Masukkan alamat lengkap',
              icon: PhosphorIcons.mapPin(),
              maxLines: 3,
            ),
            SizedBox(height: 40.h(context)),
            SizedBox(
              width: double.infinity,
              height: 52.h(context),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w(context)),
                  ),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan Perubahan',
                        style: AppTextStyles.titleSmall(context),
                      ),
              ),
            ),
            SizedBox(height: 24.h(context)),
          ],
        ),
      ),
    );
  }
}
