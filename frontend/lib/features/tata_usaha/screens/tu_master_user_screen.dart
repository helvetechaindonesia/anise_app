import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/network/dio_client.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'tu_master_user_edit_screen.dart';
import '../widgets/custom_expandable_fab.dart';

class TuMasterUserScreen extends ConsumerStatefulWidget {
  const TuMasterUserScreen({Key? key}) : super(key: key);

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

  String _formatRoleName(String role) {
    if (role.isEmpty) return role;
    return role.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _fetchRoles() async {
    setState(() {
      _isLoadingRoles = true;
    });

    try {
      final dio = ref.read(dioProvider);
      final rolesRes = await dio.get('/master/roles');
      
      setState(() {
        _roles = rolesRes.data['data'] ?? [];
        if (_roles.isNotEmpty) {
          _selectedFilter = _roles.first['name'];
        }
        _isLoadingRoles = false;
      });
      
      if (_selectedFilter != null) {
        _fetchUsers();
      }
    } catch (e) {
      setState(() {
        _isLoadingRoles = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data role', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchUsers() async {
    if (_selectedFilter == null) return;
    
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final dio = ref.read(dioProvider);
      // Memastikan parameter role selalu dalam format UPPERCASE_UNDERSCORE (contoh: TATA_USAHA)
      final sanitizedRole = _selectedFilter!.toUpperCase().replaceAll(' ', '_');
      final usersRes = await dio.get('/master/users', queryParameters: {'role': sanitizedRole});
      
      setState(() {
        _users = usersRes.data['data'] ?? [];
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data user', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile(String title) async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        String fileName = result.name;
        String filePath = result.path!;
        
        setState(() {
          _isUploading = true;
        });

        // Tampilkan loading overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );

        String type = 'siswa';
        String lowerTitle = title.toLowerCase().replaceAll('_', ' ');
        if (lowerTitle.contains('siswa')) type = 'siswa';
        else if (lowerTitle.contains('kepala') || lowerTitle.contains('kepsek')) type = 'kepsek';
        else if (lowerTitle.contains('tata usaha') || lowerTitle.contains('tu')) type = 'staff-tu';
        else if (lowerTitle.contains('bk')) type = 'guru-bk';
        else if (lowerTitle.contains('guru')) type = 'guru';

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final dio = ref.read(dioProvider);
        final response = await dio.post('/parse/user/$type', data: formData);

        // Tutup loading overlay
        if (mounted) {
          Navigator.pop(context);
        }

        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Upload berhasil!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
              backgroundColor: Colors.green,
            ),
          );
          _fetchUsers();
        }
      }
    } catch (e) {
      // Tutup loading overlay jika masih terbuka
      if (_isUploading && mounted) {
        Navigator.pop(context);
        setState(() {
          _isUploading = false;
        });
      }
      
      String errorMessage = 'Gagal mengupload file: $e';
      
      // Jika errornya dari Dio, coba ambil pesan asli dari backend
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = 'Backend Error: ${e.response!.data['message']}';
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
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
              Expanded(
                child: _isLoadingRoles 
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUserList(context, _selectedFilter ?? ''),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomExpandableFab(
        onUploadPressed: () {
          _showUploadOptions(context);
        },
        onAddPressed: () {
          _showAddOptions(context);
        },
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upload Data Master',
              style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih jenis data user yang ingin diupload.',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoadingRoles
                      ? [const Center(child: CircularProgressIndicator())]
                      : _roles.map((role) {
                          String roleName = role['name'] ?? 'Unknown';
                          String formattedRole = _formatRoleName(roleName);
                          IconData icon = PhosphorIcons.user(); // Default
                          if (roleName.toLowerCase().contains('siswa')) icon = PhosphorIcons.student();
                          else if (roleName.toLowerCase().contains('guru')) icon = PhosphorIcons.chalkboardTeacher();
                          else if (roleName.toLowerCase().contains('kepala') || roleName.toLowerCase().contains('kepsek')) icon = PhosphorIcons.crown();
                          else if (roleName.toLowerCase().contains('staf') || roleName.toLowerCase().contains('tu')) icon = PhosphorIcons.desktop();
                          
                          return _buildUploadOption(context, 'Master $formattedRole', icon, roleName);
                        }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tambah Data Master',
              style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih role user yang ingin ditambahkan.',
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoadingRoles
                      ? [const Center(child: CircularProgressIndicator())]
                      : _roles.map((role) {
                          String roleName = role['name'] ?? 'Unknown';
                          String formattedRole = _formatRoleName(roleName);
                          IconData icon = PhosphorIcons.user(); // Default
                          if (roleName.toLowerCase().contains('siswa')) icon = PhosphorIcons.student();
                          else if (roleName.toLowerCase().contains('guru')) icon = PhosphorIcons.chalkboardTeacher();
                          else if (roleName.toLowerCase().contains('kepala') || roleName.toLowerCase().contains('kepsek')) icon = PhosphorIcons.crown();
                          else if (roleName.toLowerCase().contains('staf') || roleName.toLowerCase().contains('tu')) icon = PhosphorIcons.desktop();
                          
                          return _buildAddOption(context, 'Tambah $formattedRole', icon, roleName);
                        }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(BuildContext context, String title, IconData icon, String originalRoleName) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.3)),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
      trailing: Icon(PhosphorIcons.caretRight(), color: AppColors.onBackground.withValues(alpha: 0.3)),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Navigator.pop(context);
        _pickExcelFile(originalRoleName);
      },
    );
  }



  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama, NISN, atau NIP...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(PhosphorIcons.slidersHorizontal(), color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(BuildContext context) {
    if (_isLoadingRoles || _roles.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedFilter,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          ),
        ),
        dropdownColor: AppColors.surface,
        icon: Icon(PhosphorIcons.caretDown(), color: AppColors.onSurface.withValues(alpha: 0.6)),
        items: _roles.map<DropdownMenuItem<String>>((dynamic role) {
          String roleName = role['name'] ?? 'Unknown';
          return DropdownMenuItem<String>(
            value: roleName,
            child: Text(_formatRoleName(roleName), style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            setState(() {
              _selectedFilter = newValue;
            });
            _fetchUsers();
          }
        },
      ),
    );
  }

  Widget _buildUserList(BuildContext context, String filter) {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_users.isEmpty) {
      return const Center(child: Text("Belum ada data user."));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
      itemCount: _users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _users[index];
        final fullName = user['full_name'] ?? 'Unknown Name';
        final username = user['username'] ?? '-';
        final isSiswa = filter.toLowerCase().contains('siswa');
        
        return Slidable(
          key: ValueKey(user['id'] ?? index),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
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
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
                label: 'Edit',
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: AppColors.menuPastelBlue,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.snowflake(PhosphorIconsStyle.fill),
                label: 'Freeze',
              ),
              SlidableAction(
                onPressed: (context) {},
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
                label: 'Hapus',
                borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(
                    isSiswa ? PhosphorIcons.student() : PhosphorIcons.user(),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: AppTextStyles.titleSmall(context, color: AppColors.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSiswa ? 'Username/NISN: $username' : 'Username/NUPTK: $username',
                        style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.onSurface.withValues(alpha: 0.5)),
                  color: AppColors.surface,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.pencilSimple(), size: 18, color: AppColors.onSurface),
                          const SizedBox(width: 8),
                          Text('Edit', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'freeze',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.snowflake(), size: 18, color: AppColors.menuPastelBlue),
                          const SizedBox(width: 8),
                          Text('Freeze', style: AppTextStyles.bodyMedium(context, color: AppColors.menuPastelBlue)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.trash(), size: 18, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Hapus', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
