import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user_model.dart';

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
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);

      final Map<String, dynamic> dataMap = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'parent_name': _parentController.text.trim(),
        'address': _addressController.text.trim(),
      };

      final formData = FormData.fromMap(dataMap);

      if (_selectedImage != null) {
        formData.files.add(MapEntry(
          'avatar',
          await MultipartFile.fromFile(_selectedImage!.path),
        ));
      }

      final response = await dio.post('/auth/profile', data: formData);

      if (response.statusCode == 200) {
        await ref.read(authProvider.notifier).checkAuth();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil & biodata berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui profil. Periksa data Anda.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanBase = ApiConstants.baseUrl.replaceAll('/api', '');
    return '$cleanBase$path';
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
    final isSiswa = user?.role == UserRole.siswa;
    final avatarUrl = _formatAvatarUrl(user?.avatar);

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
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 104.w(context),
                      height: 104.w(context),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryContainer,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : (avatarUrl.isNotEmpty
                                ? Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        user?.fullName.isNotEmpty == true ? user!.fullName.substring(0, 1).toUpperCase() : 'U',
                                        style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimaryContainer),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      user?.fullName.isNotEmpty == true ? user!.fullName.substring(0, 1).toUpperCase() : 'U',
                                      style: AppTextStyles.headlineLarge(context, color: AppColors.onPrimaryContainer),
                                    ),
                                  )),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundLight,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        PhosphorIcons.camera(PhosphorIconsStyle.fill),
                        color: AppColors.onPrimary,
                        size: 18.w(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h(context)),
            Center(
              child: Text(
                'Ketuk foto untuk mengganti',
                style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
              ),
            ),
            SizedBox(height: 28.h(context)),
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
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Simpan Perubahan',
                        style: AppTextStyles.titleSmall(context, color: Colors.white).copyWith(fontWeight: FontWeight.bold),
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
