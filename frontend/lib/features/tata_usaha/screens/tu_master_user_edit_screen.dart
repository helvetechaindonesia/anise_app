import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';

class TuMasterUserEditScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? user;
  final String role; // the selected role for this user

  const TuMasterUserEditScreen({Key? key, this.user, required this.role}) : super(key: key);

  @override
  ConsumerState<TuMasterUserEditScreen> createState() => _TuMasterUserEditScreenState();
}

class _TuMasterUserEditScreenState extends ConsumerState<TuMasterUserEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['full_name'] ?? '');
    _usernameController = TextEditingController(text: widget.user?['username'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = ref.read(dioProvider);
      
      final data = {
        'full_name': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
      };

      if (widget.user == null) {
        // Find role_id somehow, but for now we just use a generic implementation or skip it since role_id is required
        // We'll pass it if we have roles, wait we don't have role_id in this widget. 
        // We will just fetch it or we can pass it from previous screen.
        // For now, let's assume update is the main thing
      }

      if (widget.user != null) {
        await dio.put('/master/users/${widget.user!['id']}', data: data);
      } else {
        // If it's add, we need role_id. For now we will fetch roles and match by string, 
        // but it's easier to just pass role_id from previous screen if needed. 
        // We'll just show not implemented for Add for now unless we do a full query.
        final response = await dio.get('/master/roles');
        final roles = response.data['data'] as List;
        final role = roles.firstWhere((r) => r['name'] == widget.role, orElse: () => null);
        
        if (role == null) throw Exception("Role tidak ditemukan");
        
        data['role_id'] = role['id'];
        await dio.post('/master/users', data: data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.user == null ? 'Data berhasil ditambahkan' : 'Data berhasil diperbarui', 
              style: AppTextStyles.bodyMedium(context, color: Colors.white)
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal menyimpan perubahan';
        if (e is DioException && e.response?.data != null) {
          errorMessage = e.response!.data['message'] ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user == null ? 'Tambah User' : 'Edit User',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Dasar',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: PhosphorIcons.user(),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _usernameController,
              label: 'Username / NIK / NISN',
              icon: PhosphorIcons.identificationCard(),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email / Nomor HP',
              icon: PhosphorIcons.envelopeSimple(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Simpan Perubahan', style: AppTextStyles.titleSmall(context, color: AppColors.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyLarge(context, color: AppColors.onBackground),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
