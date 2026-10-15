import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/item_list_tile.dart';
import '../../../core/widgets/anise_search_bar.dart';
import '../../../core/widgets/anise_slidable_tile.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import 'tu_master_user_edit_screen.dart';
import '../widgets/custom_expandable_fab.dart';

class TuMasterUserScreen extends ConsumerStatefulWidget {
  const TuMasterUserScreen({super.key});

  @override
  ConsumerState<TuMasterUserScreen> createState() => _TuMasterUserScreenState();
}

class _TuMasterUserScreenState extends ConsumerState<TuMasterUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;

  bool _isLoadingRoles = true;
  List<dynamic> _roles = [];

  bool _isLoadingUsers = false;
  bool _isUploading = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatRoleName(String role) {
    if (role.isEmpty) return role;
    return role.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _fetchRoles() async {
    setState(() => _isLoadingRoles = true);

    try {
      final dio = ref.read(dioProvider);
      final rolesRes = await dio.get('/master/roles');

      if (mounted) {
        setState(() {
          _roles = rolesRes.data['data'] ?? [];
          if (_roles.isNotEmpty && _selectedFilter == null) {
            _selectedFilter = _roles.first['name'];
          }
          _isLoadingRoles = false;
        });

        if (_selectedFilter != null) {
          _fetchUsers();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRoles = false);
      }
    }
  }

  Future<void> _fetchUsers() async {
    if (_selectedFilter == null) return;

    setState(() => _isLoadingUsers = true);

    try {
      final dio = ref.read(dioProvider);
      final sanitizedRole = _selectedFilter!.toUpperCase().replaceAll(' ', '_');
      final usersRes = await dio.get('/master/users', queryParameters: {'role': sanitizedRole});

      if (mounted) {
        setState(() {
          _users = usersRes.data['data'] ?? [];
          _isLoadingUsers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  /// Toggle Freeze / Unfreeze Akun
  Future<void> _toggleFreezeUser(Map<String, dynamic> user) async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.put('/master/users/${user['id']}/freeze');

      if (mounted) {
        final message = res.data['message'] ?? 'Status akun berhasil diperbarui!';
        AniseFeedbackDialog.showSuccess(
          context,
          title: 'Status Akun',
          message: message,
        );
        _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal mengubah status akun: $e';
        if (e is DioException && e.response?.data != null) {
          final resData = e.response!.data;
          if (resData is Map && resData['message'] != null) {
            errorMessage = resData['message'].toString();
          }
        }
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Mengubah Status',
          message: errorMessage,
        );
      }
    }
  }

  /// Konfirmasi Hapus Akun
  Future<void> _confirmDeleteUser(Map<String, dynamic> user) async {
    final confirmed = await AniseFeedbackDialog.showConfirm(
      context,
      title: 'Hapus Pengguna?',
      message: 'Apakah Anda yakin ingin menghapus akun "${user['full_name']}"? Akun yang dihapus tidak akan dapat mengakses sistem kembali.',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('/master/users/${user['id']}');

        if (mounted) {
          AniseFeedbackDialog.showSuccess(
            context,
            title: 'Akun Dihapus',
            message: 'Akun "${user['full_name']}" berhasil dihapus!',
          );
          _fetchUsers();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Gagal menghapus akun: $e';
          if (e is DioException && e.response?.data != null) {
            final resData = e.response!.data;
            if (resData is Map && resData['message'] != null) {
              errorMessage = resData['message'].toString();
            }
          }
          AniseFeedbackDialog.showError(
            context,
            title: 'Gagal Menghapus Akun',
            message: errorMessage,
          );
        }
      }
    }
  }

  /// Upload Berkas Excel
  Future<void> _pickExcelFile(String title) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        PlatformFile picked = result.files.first;
        String fileName = picked.name;
        String filePath = picked.path!;

        final ext = fileName.split('.').last.toLowerCase();
        if (ext != 'xlsx' && ext != 'xls') {
          if (mounted) {
            _showRejectionDialog(
              ext == 'pdf'
                  ? 'Berkas PDF ditolak! Fitur ini membutuhkan file spreadsheet Excel (.xlsx / .xls).'
                  : 'Berkas ditolak! Format berkas .$ext tidak didukung, harap pilih berkas Excel (.xlsx / .xls).',
            );
          }
          return;
        }

        setState(() => _isUploading = true);

        if (!mounted) return;
        // Tampilkan loading overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );

        String type = 'siswa';
        String lowerTitle = title.toLowerCase().replaceAll('_', ' ');
        if (lowerTitle.contains('siswa')) {
          type = 'siswa';
        } else if (lowerTitle.contains('kepala') || lowerTitle.contains('kepsek')) {
          type = 'kepsek';
        } else if (lowerTitle.contains('tata usaha') || lowerTitle.contains('tu') || lowerTitle.contains('staf')) {
          type = 'staff-tu';
        } else if (lowerTitle.contains('bk')) {
          type = 'guru-bk';
        } else if (lowerTitle.contains('guru')) {
          type = 'guru';
        }

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final dio = ref.read(dioProvider);
        final response = await dio.post('/parse/user/$type', data: formData);

        if (mounted) {
          Navigator.pop(context); // Tutup loading overlay
          setState(() => _isUploading = false);

          AniseFeedbackDialog.showSuccess(
            context,
            title: 'Upload Berhasil',
            message: response.data['message'] ?? 'Upload berhasil!',
          );
          _fetchUsers();
        }
      }
    } catch (e) {
      if (_isUploading && mounted) {
        Navigator.pop(context);
        setState(() => _isUploading = false);
      }

      String errorMessage = 'Gagal mengupload berkas: $e';
      if (e is DioException && e.response?.data != null) {
        final resData = e.response!.data;
        if (resData is Map && resData['message'] != null) {
          errorMessage = resData['message'].toString();
        }
      }

      if (mounted) {
        _showRejectionDialog(errorMessage);
      }
    }
  }

  /// Popup Dialog Penolakan Berkas Modern (Menggunakan Standar AniseFeedbackDialog)
  void _showRejectionDialog(String errorMessage) {
    if (!mounted) return;
    AniseFeedbackDialog.showWarning(
      context,
      title: 'Berkas Ditolak',
      message: errorMessage,
    );
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
          'Manajemen User',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              _buildFilterDropdown(context),
              _buildHeaderCounter(context),
              Expanded(
                child: _isLoadingRoles
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _buildUserList(context, _selectedFilter ?? ''),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomExpandableFab(
        onUploadPressed: () => _showUploadOptions(context),
        onAddPressed: () => _showAddOptions(context),
      ),
    );
  }

  /// 1. Search Bar Realtime
  Widget _buildSearchBar(BuildContext context) {
    return AniseSearchBar(
      controller: _searchController,
      hintText: 'Cari nama, username, NISN, atau NIP...',
      onChanged: (_) => setState(() {}),
      onClear: () => setState(() {}),
    );
  }

  /// 2. Dropdown Filter Role Full-Width
  Widget _buildFilterDropdown(BuildContext context) {
    if (_isLoadingRoles || _roles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 6.h(context)),
      child: DropdownButtonFormField<String>(
        key: ValueKey(_selectedFilter),
        initialValue: _selectedFilter,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.w(context)),
            borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.w(context)),
            borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.w(context)),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
        ),
        dropdownColor: AppColors.surface,
        icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.onSurface.withValues(alpha: 0.6)),
        items: _roles.map<DropdownMenuItem<String>>((dynamic role) {
          String roleName = role['name'] ?? 'Unknown';
          return DropdownMenuItem<String>(
            value: roleName,
            child: Text(
              _formatRoleName(roleName),
              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(
                fontWeight: _selectedFilter == roleName ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null && newValue != _selectedFilter) {
            setState(() {
              _selectedFilter = newValue;
              _searchController.clear();
            });
            _fetchUsers();
          }
        },
      ),
    );
  }

  /// 3. Header Counter Total Pengguna
  Widget _buildHeaderCounter(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 4.h(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Daftar Pengguna ${_formatRoleName(_selectedFilter ?? '')}',
            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.w(context)),
            ),
            child: Text(
              '${_users.length} Akun',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. List User dengan Standar `ItemListTile` & `Slidable`
  Widget _buildUserList(BuildContext context, String filter) {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    List<dynamic> filteredUsers = _users;
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filteredUsers = _users.where((user) {
        final name = (user['full_name'] ?? '').toString().toLowerCase();
        final username = (user['username'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final phone = (user['phone'] ?? '').toString().toLowerCase();
        final nisn = (user['siswa_profile']?['nisn'] ?? '').toString().toLowerCase();
        final nip = (user['guru_profile']?['nip_nuptk'] ?? '').toString().toLowerCase();
        final religion = (user['religion'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            username.contains(query) ||
            email.contains(query) ||
            phone.contains(query) ||
            nisn.contains(query) ||
            nip.contains(query) ||
            religion.contains(query);
      }).toList();
    }

    if (filteredUsers.isEmpty) {
      return AniseEmptyState(
        title: 'Belum Ada Data ${_formatRoleName(_selectedFilter ?? 'User')}',
        subtitle: query.isNotEmpty
            ? 'Tidak ada pengguna yang cocok dengan kata kunci "$query".'
            : 'Daftar pengguna dengan role ini belum ditambahkan ke sistem sekolah.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(left: 24.w(context), right: 24.w(context), top: 8.h(context), bottom: 90.h(context)),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = Map<String, dynamic>.from(filteredUsers[index]);
        final fullName = user['full_name'] ?? 'Unknown Name';
        final username = user['username'] ?? '-';
        final email = user['email'] ?? '-';
        final roleName = user['role_name'] ?? _selectedFilter ?? filter;
        final bool isActive = user['is_active'] == true || user['is_active'] == 1;
        final bool isLast = index == filteredUsers.length - 1;

        final religion = (user['religion'] ?? '').toString().trim();
        final credText = religion.isNotEmpty
            ? 'Kredensial: $username • Agama: $religion'
            : 'Kredensial: $username';

        final tile = ItemListTile(
          category: 'Hak Akses: ${_formatRoleName(roleName)}',
          title: fullName,
          metadataIcon: PhosphorIcons.envelope(),
          metadataText: 'Email: $email',
          secondaryMetadataIcon: PhosphorIcons.identificationCard(),
          secondaryMetadataText: credText,
          statusIcon: isActive
              ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
              : PhosphorIcons.snowflake(PhosphorIconsStyle.fill),
          statusText: isActive ? 'Status: Aktif' : 'Status: Dibekukan',
          statusColor: isActive ? AppColors.success : AppColors.error,
          showDivider: !isLast,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TuMasterUserEditScreen(user: user, role: user['role_name'] ?? _selectedFilter ?? ''),
              ),
            );
            if (result == true) {
              _fetchUsers();
            }
          },
          trailing: PopupMenuButton<String>(
            icon: Icon(
              PhosphorIcons.list(PhosphorIconsStyle.bold), // Hamburger Menu Icon
              color: AppColors.onSurface.withValues(alpha: 0.6),
              size: 22.w(context),
            ),
            color: AppColors.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
            onSelected: (value) async {
              if (value == 'edit') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TuMasterUserEditScreen(user: user, role: user['role_name'] ?? _selectedFilter ?? ''),
                  ),
                );
                if (result == true) {
                  _fetchUsers();
                }
              } else if (value == 'freeze') {
                _toggleFreezeUser(user);
              } else if (value == 'delete') {
                _confirmDeleteUser(user);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                    SizedBox(width: 10.w(context)),
                    Text('Edit', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'freeze',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.snowflake(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.menuPastelBlue),
                    SizedBox(width: 10.w(context)),
                    Text(isActive ? 'Bekukan (Freeze)' : 'Aktifkan Kembali', style: AppTextStyles.bodyMedium(context, color: AppColors.menuPastelBlue)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.error),
                    SizedBox(width: 10.w(context)),
                    Text('Hapus', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        );

        return AniseSlidableTile(
          key: ValueKey(user['id'] ?? index),
          isFrozen: !isActive,
          onEdit: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TuMasterUserEditScreen(user: user, role: user['role_name'] ?? _selectedFilter ?? ''),
              ),
            );
            if (result == true) {
              _fetchUsers();
            }
          },
          onFreeze: () => _toggleFreezeUser(user),
          onDelete: () => _confirmDeleteUser(user),
          child: tile,
        );
      },
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w(context),
                height: 4.h(context),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 18.h(context)),
            Text(
              'Unggah Berkas Master User',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 6.h(context)),
            Text(
              'Pilih jenis peran pengguna yang ingin diunggah via Excel.',
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 16.h(context)),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoadingRoles
                      ? [const Center(child: CircularProgressIndicator(color: AppColors.primary))]
                      : _roles.map((role) {
                          String roleName = role['name'] ?? 'Unknown';
                          String formattedRole = _formatRoleName(roleName);
                          IconData icon = PhosphorIcons.user();
                          final lRole = roleName.toLowerCase();
                          if (lRole.contains('siswa')) {
                            icon = PhosphorIcons.student();
                          } else if (lRole.contains('guru')) {
                            icon = PhosphorIcons.chalkboardTeacher();
                          } else if (lRole.contains('kepala') || lRole.contains('kepsek')) {
                            icon = PhosphorIcons.crown();
                          } else if (lRole.contains('staf') || lRole.contains('tu')) {
                            icon = PhosphorIcons.desktop();
                          }

                          return _buildUploadOption(context, 'Master $formattedRole', icon, roleName);
                        }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h(context)),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w(context),
                height: 4.h(context),
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 18.h(context)),
            Text(
              'Tambah Pengguna Baru',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
            ),
            SizedBox(height: 6.h(context)),
            Text(
              'Pilih role pengguna yang ingin ditambahkan secara manual.',
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            SizedBox(height: 16.h(context)),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoadingRoles
                      ? [const Center(child: CircularProgressIndicator(color: AppColors.primary))]
                      : _roles.map((role) {
                          String roleName = role['name'] ?? 'Unknown';
                          String formattedRole = _formatRoleName(roleName);
                          IconData icon = PhosphorIcons.user();
                          final lRole = roleName.toLowerCase();
                          if (lRole.contains('siswa')) {
                            icon = PhosphorIcons.student();
                          } else if (lRole.contains('guru')) {
                            icon = PhosphorIcons.chalkboardTeacher();
                          } else if (lRole.contains('kepala') || lRole.contains('kepsek')) {
                            icon = PhosphorIcons.crown();
                          } else if (lRole.contains('staf') || lRole.contains('tu')) {
                            icon = PhosphorIcons.desktop();
                          }

                          return _buildAddOption(context, 'Tambah $formattedRole', icon, roleName);
                        }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(BuildContext context, String title, IconData icon, String originalRoleName) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.w(context)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.w(context)),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.3), size: 16.w(context)),
      contentPadding: EdgeInsets.zero,
      onTap: () async {
        Navigator.pop(context);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TuMasterUserEditScreen(role: originalRoleName),
          ),
        );
        if (result == true) {
          _fetchUsers();
        }
      },
    );
  }

  Widget _buildUploadOption(BuildContext context, String title, IconData icon, String originalRoleName) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.w(context)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.w(context)),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.3), size: 16.w(context)),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.pop(context);
        _pickExcelFile(originalRoleName);
      },
    );
  }
}
