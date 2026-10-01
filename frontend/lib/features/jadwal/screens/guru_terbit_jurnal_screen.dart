import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/jurnal_provider.dart';

class GuruTerbitJurnalScreen extends ConsumerStatefulWidget {
  const GuruTerbitJurnalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GuruTerbitJurnalScreen> createState() => _GuruTerbitJurnalScreenState();
}

class _GuruTerbitJurnalScreenState extends ConsumerState<GuruTerbitJurnalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String? _selectedMapel;
  String? _selectedJadwal;
  bool _isAdaTugas = false;
  
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  
  File? _selectedFile;
  String? _fileName;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    List<PlatformFile> result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'pdf', 'docx', 'xlsx', 'ppt', 'pptx'],
    );

    if (result.isNotEmpty) {
      File file = File(result.first.path!);
      int sizeInBytes = file.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 20) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file maksimal adalah 20 MB'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = result.first.name;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final jurnalState = ref.watch(jurnalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Terbitkan Jurnal',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              'Rencana Pelaksanaan Pembelajaran',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
      body: jurnalState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.warningCircle(), size: 48, color: AppColors.error),
              SizedBox(height: 16),
              Text('Gagal memuat data: $error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(jurnalProvider.notifier).fetchTerbitOptions(),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
        data: (data) {
          final subjects = data['subjects'] as List<dynamic>;
          final schedules = data['schedules'] as List<dynamic>;

          final availableSchedules = _selectedMapel == null 
            ? schedules 
            : schedules.where((s) => s['subject_id'] == _selectedMapel).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Info Jadwal
                  _buildSectionTitle(context, 'Pilih Jadwal Master', PhosphorIcons.calendarPlus(PhosphorIconsStyle.bold)),
                  SizedBox(height: 16.h(context)),
                  _buildMapelDropdown(subjects),
                  SizedBox(height: 16.h(context)),
                  _buildJadwalDropdown(availableSchedules),

                  SizedBox(height: 32.h(context)),

                  // 2. Jurnal Utama
                  _buildSectionTitle(context, 'Materi Pembelajaran', PhosphorIcons.notePencil(PhosphorIconsStyle.bold)),
                  SizedBox(height: 16.h(context)),
                  _buildTextField(
                    context,
                    label: 'Judul Materi',
                    controller: _judulController,
                    hint: 'Masukkan judul materi yang akan dibahas',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildTextField(
                    context,
                    label: 'Deskripsi / Tujuan Pembelajaran',
                    controller: _deskripsiController,
                    hint: 'Ceritakan secara singkat apa yang akan dicapai...',
                    maxLines: 4,
                  ),

                  SizedBox(height: 32.h(context)),

                  // 3. Lampiran
                  _buildSectionTitle(context, 'Lampiran (Opsional)', PhosphorIcons.paperclip(PhosphorIconsStyle.bold)),
                  SizedBox(height: 16.h(context)),
                  _buildAttachmentButton(context),

                  SizedBox(height: 32.h(context)),

                  // 4. Pengaturan Tugas
                  _buildSectionTitle(context, 'Pengaturan Tugas', PhosphorIcons.checkSquareOffset(PhosphorIconsStyle.bold)),
                  SizedBox(height: 16.h(context)),
                  _buildTaskToggle(),

                  SizedBox(height: 48.h(context)),

                  // 5. Submit Button
                  _buildSubmitButton(),
                  SizedBox(height: 24.h(context)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapelDropdown(List<dynamic> subjects) {
    return _buildDropdownField(
      context,
      label: 'Mata Pelajaran',
      value: _selectedMapel,
      items: subjects.map((s) => {'id': s['id'], 'label': s['name']}).toList(),
      onChanged: (val) {
        setState(() {
          _selectedMapel = val;
          _selectedJadwal = null;
        });
      },
      icon: PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular),
      hint: 'Pilih Mata Pelajaran',
    );
  }

  Widget _buildJadwalDropdown(List<dynamic> schedules) {
    return _buildDropdownField(
      context,
      label: 'Jadwal KBM',
      value: _selectedJadwal,
      items: _selectedMapel == null ? [] : schedules.map((s) => {'id': s['id'], 'label': s['label']}).toList(),
      onChanged: _selectedMapel == null ? null : (val) {
        setState(() {
          _selectedJadwal = val;
        });
      },
      icon: PhosphorIcons.calendar(PhosphorIconsStyle.regular),
      hint: _selectedMapel == null ? 'Pilih Mata Pelajaran Terlebih Dahulu' : 'Pilih Jadwal yang Tersedia',
      isFullWidthText: true,
    );
  }

  Widget _buildTaskToggle() {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ada Penugasan?', style: AppTextStyles.titleSmall(context, color: AppColors.onSurface)),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Aktifkan jika sesi ini memiliki tugas khusus.',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isAdaTugas,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _isAdaTugas = val;
                  });
                },
              ),
            ],
          ),
          if (_isAdaTugas) ...[
            SizedBox(height: 16.h(context)),
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.w(context)),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.warning, size: 20.w(context)),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Text(
                      'Setelah jurnal ini diterbitkan, pastikan Anda membuat detail tugasnya di halaman Penugasan agar terhubung ke jurnal ini.',
                      style: AppTextStyles.labelMedium(context, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        if (_isLoading) ...[
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'Mengunggah... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
            style: AppTextStyles.labelMedium(context, color: AppColors.primary),
          ),
          SizedBox(height: 16.h(context)),
        ],
        SizedBox(
          width: double.infinity,
          height: 54.h(context),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.w(context)),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : () async {
              if (_selectedMapel == null || _selectedJadwal == null || _judulController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harap lengkapi Mapel, Jadwal, dan Judul Materi.'), backgroundColor: AppColors.error),
                );
                return;
              }

              setState(() { 
                _isLoading = true; 
                _uploadProgress = 0.0;
              });

              final success = await ref.read(jurnalProvider.notifier).terbitJurnal(
                scheduleId: _selectedJadwal!,
                subjectId: _selectedMapel!,
                topicMaterial: _judulController.text,
                description: _deskripsiController.text,
                hasTask: _isAdaTugas,
                attachment: _selectedFile,
                onProgress: (progress) {
                  setState(() {
                    _uploadProgress = progress;
                  });
                }
              );

              setState(() { _isLoading = false; });

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jurnal Berhasil Diterbitkan!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
                Navigator.pop(context);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menerbitkan jurnal.'), backgroundColor: AppColors.error),
                );
              }
            },
            child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
                : Text('Terbitkan Jurnal Sekarang', style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.w(context)),
        SizedBox(width: 8.w(context)),
        Text(title, style: AppTextStyles.titleMedium(context, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, required TextEditingController controller, String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(BuildContext context, {required String label, String? value, required List<Map<String, dynamic>> items, Function(String?)? onChanged, required IconData icon, String? hint, bool isFullWidthText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 4.h(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.w(context)),
            border: Border.all(color: AppColors.outline),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              itemHeight: null,
              isDense: false,
              value: value,
              hint: hint != null ? Text(hint, style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4))) : null,
              icon: Icon(PhosphorIcons.caretDown(), color: AppColors.onSurface.withValues(alpha: 0.5)),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id'].toString(),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h(context)),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(icon, color: AppColors.primary, size: 20.w(context)),
                        SizedBox(width: 12.w(context)),
                        Expanded(
                          child: Text(
                            item['label'].toString(),
                            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                            overflow: isFullWidthText ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentButton(BuildContext context) {
    if (_selectedFile != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h(context), horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.primaryContainer),
        ),
        child: Row(
          children: [
            Icon(PhosphorIcons.file(PhosphorIconsStyle.bold), color: AppColors.primary, size: 28.w(context)),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fileName ?? 'File Terpilih', style: AppTextStyles.titleSmall(context, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2.h(context)),
                  Text('${(_selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                ],
              ),
            ),
            IconButton(
              icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: AppColors.error),
              onPressed: _removeFile,
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16.w(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16.w(context)),
          border: Border.all(color: AppColors.primaryContainer, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 32.w(context)),
            SizedBox(height: 8.h(context)),
            Text('Upload Foto atau File PDF', style: AppTextStyles.titleSmall(context, color: AppColors.primary)),
            SizedBox(height: 4.h(context)),
            Text('Maks. 20MB (png, jpg, pdf, docx, dll)', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}
