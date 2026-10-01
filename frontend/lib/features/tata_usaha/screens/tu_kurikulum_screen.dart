import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/network/dio_client.dart';

final kurikulumFilterProvider = StateProvider<String>((ref) => 'Wali Kelas');

final kurikulumDataProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final type = ref.watch(kurikulumFilterProvider);
  final dio = ref.read(dioProvider);
  String endpoint = '';
  switch (type) {
    case 'Wali Kelas': endpoint = '/master/wali-kelas'; break;
    case 'Guru Wali': endpoint = '/master/guru-wali'; break;
    case 'Penugasan': endpoint = '/master/penugasan'; break;
    case 'Mapel': endpoint = '/master/mapel'; break;
    case 'Jadwal KBM': endpoint = '/master/schedules'; break;
  }
  final response = await dio.get(endpoint);
  return response.data['data'] as List<dynamic>;
});

class TuKurikulumScreen extends ConsumerStatefulWidget {
  const TuKurikulumScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TuKurikulumScreen> createState() => _TuKurikulumScreenState();
}

class _TuKurikulumScreenState extends ConsumerState<TuKurikulumScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(kurikulumFilterProvider);
    final dataAsync = ref.watch(kurikulumDataProvider);

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
          'Kurikulum',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(context),
              _buildDropdownFilter(context, selectedFilter),
              Expanded(
                child: dataAsync.when(
                  data: (data) => _buildDataList(context, selectedFilter, data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUploadOptions(context);
        },
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.upload(PhosphorIconsStyle.bold), color: AppColors.onPrimary),
        label: Text('Upload Excel', style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary)),
      ),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                  'Upload Data Kurikulum',
                  style: AppTextStyles.headlineSmall(context, color: AppColors.onBackground),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih jenis data konektor/penugasan yang ingin diupload.',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 16),
                _buildUploadOption(context, 'Master Wali Kelas', PhosphorIcons.chalkboardTeacher()),
                _buildUploadOption(context, 'Master Guru Wali (BK)', PhosphorIcons.usersThree()),
                _buildUploadOption(context, 'Master Penugasan', PhosphorIcons.briefcase()),
                _buildUploadOption(context, 'Master Mapel', PhosphorIcons.books()),
                _buildUploadOption(context, 'Master Jadwal KBM', PhosphorIcons.calendar()),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleUpload(String title) async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        String? filePath = result.path;
        String? fileName = result.name;
        
        if (filePath == null) return;

        setState(() {
          _isUploading = true;
        });

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 24),
                      Text('Mengupload data ${title}...', style: AppTextStyles.bodyMedium(context)),
                    ],
                  ),
                ),
              );
            },
          );
        }

        String type = 'mapel';
        String lowerTitle = title.toLowerCase().replaceAll('_', ' ');
        if (lowerTitle.contains('wali kelas')) type = 'wali_kelas';
        else if (lowerTitle.contains('guru wali')) type = 'guru_wali';
        else if (lowerTitle.contains('penugasan')) type = 'penugasan';
        else if (lowerTitle.contains('mapel')) type = 'mapel';
        else if (lowerTitle.contains('jadwal')) type = 'jurnal_mengajar';

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final dio = ref.read(dioProvider);
        final response = await dio.post('/parse/kurikulum/$type', data: formData);

        if (mounted) {
          Navigator.pop(context); // close dialog
        }

        setState(() {
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['message'] ?? 'Upload berhasil!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          ref.invalidate(kurikulumDataProvider); // Refresh data
        }
      }
    } catch (e) {
      if (_isUploading && mounted) {
        Navigator.pop(context);
        setState(() {
          _isUploading = false;
        });
      }
      
      String errorMessage = 'Gagal mengupload file: $e';
      
      if (e is DioException && e.response?.data != null) {
        if (e.response!.data is Map && e.response!.data['message'] != null) {
          errorMessage = e.response!.data['message']; // The backend sends our formatted message!
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  Widget _buildUploadOption(BuildContext context, String title, IconData icon) {
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
        Navigator.pop(context); // Pops the bottom sheet
        _handleUpload(title);
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
                  hintText: 'Cari jadwal, guru, mapel...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(BuildContext context, String selectedFilter) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          isExpanded: true,
          icon: Icon(PhosphorIcons.caretDown(), color: AppColors.onSurface.withValues(alpha: 0.5)),
          style: AppTextStyles.titleSmall(context, color: AppColors.onSurface),
          onChanged: (String? newValue) {
            if (newValue != null) {
              ref.read(kurikulumFilterProvider.notifier).state = newValue;
            }
          },
          items: <String>['Wali Kelas', 'Guru Wali', 'Penugasan', 'Mapel', 'Jadwal KBM']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDataList(BuildContext context, String type, List<dynamic> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data untuk $type',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }

    IconData icon;
    switch (type) {
      case 'Wali Kelas': icon = PhosphorIcons.chalkboardTeacher(); break;
      case 'Guru Wali': icon = PhosphorIcons.usersThree(); break;
      case 'Penugasan': icon = PhosphorIcons.briefcase(); break;
      case 'Mapel': icon = PhosphorIcons.books(); break;
      case 'Jadwal KBM': icon = PhosphorIcons.calendar(); break;
      default: icon = PhosphorIcons.file();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80),
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = data[index];
        String titleText = '';
        String subtitleText = '';

        if (type == 'Wali Kelas') {
          titleText = item['name'] ?? '';
          subtitleText = 'Wali Kelas: ${item['wali_kelas']?['full_name'] ?? '-'}';
        } else if (type == 'Guru Wali') {
          titleText = item['student']?['full_name'] ?? '';
          subtitleText = 'Guru Wali: ${item['guru']?['full_name'] ?? '-'}';
        } else if (type == 'Penugasan') {
          titleText = item['guru']?['full_name'] ?? '';
          subtitleText = 'Jabatan: ${item['jabatan']?['name'] ?? '-'}';
        } else if (type == 'Mapel') {
          titleText = item['name'] ?? '';
          subtitleText = 'Kode: ${item['code'] ?? '-'}';
        } else if (type == 'Jadwal KBM') {
          if (item['subject'] != null) {
            titleText = '${item['subject']['name']} - ${item['class']?['name'] ?? ''}';
          } else {
            titleText = '${item['activity_name'] ?? 'Kegiatan'} - ${item['class']?['name'] ?? ''}';
          }
          
          String teacherName = item['teacher']?['full_name'] ?? 'Tanpa Guru';
          subtitleText = '${item['day_of_week'] ?? ''}, ${item['start_time']} - ${item['end_time']} ($teacherName)';
        }

        return Container(
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: AppTextStyles.titleSmall(context, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleText,
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Icon(PhosphorIcons.dotsThreeVertical(), color: AppColors.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        );
      },
    );
  }
}
