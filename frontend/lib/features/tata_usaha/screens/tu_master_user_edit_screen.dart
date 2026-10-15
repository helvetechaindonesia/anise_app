import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/network/dio_client.dart';

class TuMasterUserEditScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? user;
  final String role; // the selected role for this user

  const TuMasterUserEditScreen({super.key, this.user, required this.role});

  @override
  ConsumerState<TuMasterUserEditScreen> createState() => _TuMasterUserEditScreenState();
}

class _TuMasterUserEditScreenState extends ConsumerState<TuMasterUserEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _nipController;
  late TextEditingController _nisnController;
  late TextEditingController _nisController;
  late TextEditingController _religionController;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?['full_name'] ?? '');
    _usernameController = TextEditingController(text: u?['username'] ?? '');
    _emailController = TextEditingController(text: u?['email'] ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: u?['phone'] ?? '');
    _addressController = TextEditingController(text: u?['address'] ?? '');
    _religionController = TextEditingController(text: u?['religion'] ?? '');

    String initNip = '';
    if (u?['guru_profile']?['nip_nuptk'] != null) {
      initNip = u!['guru_profile']['nip_nuptk'].toString();
    }
    _nipController = TextEditingController(text: initNip);

    String initNisn = '';
    String initNis = '';
    if (u?['siswa_profile'] != null) {
      initNisn = u!['siswa_profile']['nisn']?.toString() ?? '';
      initNis = u['siswa_profile']['nis']?.toString() ?? '';
    }
    _nisnController = TextEditingController(text: initNisn);
    _nisController = TextEditingController(text: initNis);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _religionController.dispose();
    _nipController.dispose();
    _nisnController.dispose();
    _nisController.dispose();
    super.dispose();
  }

  bool get _isSiswa => widget.role.toUpperCase().contains('SISWA');
  bool get _isGuruOrGtk =>
      widget.role.toUpperCase().contains('GURU') ||
      widget.role.toUpperCase().contains('KEPALA') ||
      widget.role.toUpperCase().contains('TATA_USAHA');

  Future<void> _saveChanges() async {
    final fullName = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    if (fullName.isEmpty || username.isEmpty || email.isEmpty) {
      AniseFeedbackDialog.showWarning(
        context,
        title: 'Data Belum Lengkap',
        message: 'Nama lengkap, username, dan email wajib diisi!',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);

      final Map<String, dynamic> data = {
        'full_name': fullName,
        'username': username,
        'email': email,
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'religion': _religionController.text.trim(),
      };

      if (_passwordController.text.trim().isNotEmpty) {
        data['password'] = _passwordController.text.trim();
      }

      if (_isSiswa) {
        if (_nisnController.text.trim().isNotEmpty) {
          data['nisn'] = _nisnController.text.trim();
        }
        if (_nisController.text.trim().isNotEmpty) {
          data['nis'] = _nisController.text.trim();
        }
      } else {
        if (_nipController.text.trim().isNotEmpty) {
          data['nip_nuptk'] = _nipController.text.trim();
        }
      }

      if (widget.user != null) {
        // Edit User
        await dio.put('/master/users/${widget.user!['id']}', data: data);
      } else {
        // Tambah User Baru
        final rolesRes = await dio.get('/master/roles');
        final roles = rolesRes.data['data'] as List<dynamic>? ?? [];
        final sanitizedRole = widget.role.toUpperCase().replaceAll(' ', '_');

        final roleObj = roles.firstWhere(
          (r) => r['name'] == sanitizedRole || r['name'] == widget.role,
          orElse: () => null,
        );

        if (roleObj == null) {
          throw Exception("Role '${widget.role}' tidak ditemukan di sistem.");
        }

        data['role_id'] = roleObj['id'];
        await dio.post('/master/users', data: data);
      }

      if (mounted) {
        await AniseFeedbackDialog.showSuccess(
          context,
          title: 'Berhasil Disimpan',
          message: widget.user == null ? 'Pengguna baru berhasil ditambahkan!' : 'Data pengguna berhasil diperbarui!',
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal menyimpan perubahan: $e';
        if (e is DioException && e.response?.data != null) {
          final resData = e.response!.data;
          if (resData is Map && resData['message'] != null) {
            errorMessage = resData['message'].toString();
          }
        }
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Menyimpan',
          message: errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.user != null;

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
          isEdit ? 'Sunting Data Pengguna' : 'Tambah Pengguna Baru',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kategori Hak Akses / Role
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.w(context)),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.bold), color: AppColors.primary, size: 18.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'Peran: ${widget.role.replaceAll('_', ' ')}',
                    style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h(context)),

            Text('Informasi Akun & Pribadi', style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h(context)),

            // 1. Nama Lengkap
            _buildTextField(
              context: context,
              controller: _nameController,
              label: 'Nama Lengkap *',
              hint: 'Contoh: Ahmad Fauzan, S.Pd.',
              icon: PhosphorIcons.user(PhosphorIconsStyle.bold),
            ),
            SizedBox(height: 14.h(context)),

            // 2. Username / Kredensial
            _buildTextField(
              context: context,
              controller: _usernameController,
              label: 'Username / Kredensial Login *',
              hint: _isSiswa ? 'Nomor NISN atau username' : 'NIP / NUPTK atau username',
              icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.bold),
            ),
            SizedBox(height: 14.h(context)),

            // 3. Email
            _buildTextField(
              context: context,
              controller: _emailController,
              label: 'Alamat Email *',
              hint: 'user@sekolah.com',
              keyboardType: TextInputType.emailAddress,
              icon: PhosphorIcons.envelopeSimple(PhosphorIconsStyle.bold),
            ),
            SizedBox(height: 14.h(context)),

            // 4. Password Baru / Reset Password
            _buildTextField(
              context: context,
              controller: _passwordController,
              label: isEdit ? 'Reset Kata Sandi (Opsional)' : 'Kata Sandi Baru (Opsional)',
              hint: isEdit ? 'Biarkan kosong jika tidak diubah' : 'Default: sama dengan username',
              obscureText: _obscurePassword,
              icon: PhosphorIcons.lockKey(PhosphorIconsStyle.bold),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye(),
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  size: 20.w(context),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            SizedBox(height: 20.h(context)),

            // Informasi Tambahan
            Text('Data Tambahan (Opsional)', style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h(context)),

            // 5. NIP / NUPTK jika Guru atau GTK
            if (_isGuruOrGtk) ...[
              _buildTextField(
                context: context,
                controller: _nipController,
                label: 'NIP / NUPTK',
                hint: '198501012010011001',
                keyboardType: TextInputType.number,
                icon: PhosphorIcons.briefcase(PhosphorIconsStyle.bold),
              ),
              SizedBox(height: 14.h(context)),
            ],

            // 6. NISN & NIS jika Siswa
            if (_isSiswa) ...[
              _buildTextField(
                context: context,
                controller: _nisnController,
                label: 'Nomor Induk Siswa Nasional (NISN)',
                hint: '0051234567',
                keyboardType: TextInputType.number,
                icon: PhosphorIcons.student(PhosphorIconsStyle.bold),
              ),
              SizedBox(height: 14.h(context)),
              _buildTextField(
                context: context,
                controller: _nisController,
                label: 'Nomor Induk Siswa (NIS)',
                hint: '2425001',
                keyboardType: TextInputType.number,
                icon: PhosphorIcons.tag(PhosphorIconsStyle.bold),
              ),
              SizedBox(height: 14.h(context)),
            ],

            // 7. Nomor WhatsApp / HP
            _buildTextField(
              context: context,
              controller: _phoneController,
              label: 'Nomor WhatsApp / HP',
              hint: '081234567890',
              keyboardType: TextInputType.phone,
              icon: PhosphorIcons.phone(PhosphorIconsStyle.bold),
            ),
            SizedBox(height: 14.h(context)),

            // 8. Alamat Rumah
            _buildTextField(
              context: context,
              controller: _addressController,
              label: 'Alamat Tinggal',
              hint: 'Jl. Merdeka No. 10...',
              maxLines: 2,
              icon: PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
            ),
            SizedBox(height: 14.h(context)),

            // 9. Agama
            _buildTextField(
              context: context,
              controller: _religionController,
              label: 'Agama',
              hint: 'Islam / Kristen / Katolik / Hindu / Buddha / Khonghucu',
              icon: PhosphorIcons.handsPraying(PhosphorIconsStyle.bold),
            ),
            SizedBox(height: 28.h(context)),

            // Tombol Simpan
            AniseButton(
              text: isEdit ? 'Simpan Perubahan' : 'Tambah Pengguna',
              icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
              onPressed: _isLoading ? null : _saveChanges,
            ),
            SizedBox(height: 24.h(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
        ),
        SizedBox(height: 6.h(context)),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.35)),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20.w(context)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
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
              borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
            ),
          ),
        ),
      ],
    );
  }
}
