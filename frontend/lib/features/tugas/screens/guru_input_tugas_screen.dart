import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../providers/tugas_provider.dart';
import 'package:intl/intl.dart';

class GuruInputTugasScreen extends ConsumerStatefulWidget {
  const GuruInputTugasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GuruInputTugasScreen> createState() => _GuruInputTugasScreenState();
}

class _GuruInputTugasScreenState extends ConsumerState<GuruInputTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedMapel;
  String? _selectedJurnal;
  
  final _judulController = TextEditingController();
  final _instruksiController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  File? _selectedFile;
  String? _fileName;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(jurnalProvider.notifier).fetchTerbitOptions());
  }

  @override
  void dispose() {
    _judulController.dispose();
    _instruksiController.dispose();
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
          const SnackBar(content: Text('Ukuran file maksimal 20MB', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = result.first.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jurnalState = ref.watch(jurnalProvider);
    final isSubmitting = ref.watch(tugasProvider).isLoading;

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
              'Buat Tugas Baru',
              style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
            ),
            Text(
              'Terbitkan untuk siswa',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
      body: jurnalState.when(
        data: (data) {
          final subjects = data['subjects'] as List<dynamic>? ?? [];
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Pilih Mata Pelajaran', PhosphorIcons.bookBookmark(PhosphorIconsStyle.bold)),
                  Spacing.custom(context, 16),
                  _buildDropdownField(
                    context,
                    label: 'Mata Pelajaran',
                    value: _selectedMapel,
                    items: subjects.map((s) => {'id': s['id'], 'label': s['name']}).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedMapel = val;
                        _selectedJurnal = null; // reset jurnal
                      });
                    },
                    icon: PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular),
                  ),

                  if (_selectedMapel != null) ...[
                    Spacing.custom(context, 32),
                    _buildSectionTitle(context, 'Pilih Jurnal', PhosphorIcons.notebook(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final journalsAsync = ref.watch(journalsBySubjectProvider(_selectedMapel!));
                        return journalsAsync.when(
                          data: (journals) {
                            if (journals.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(16.w(context)),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.w(context)),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.warning),
                                    SizedBox(width: 12.w(context)),
                                    Expanded(
                                      child: Text(
                                        'Tidak ada jurnal yang ditemukan untuk mata pelajaran ini. Buat jurnal terlebih dahulu.',
                                        style: AppTextStyles.bodySmall(context, color: AppColors.warning),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return _buildDropdownField(
                              context,
                              label: 'Jurnal Terkait',
                              value: _selectedJurnal,
                              items: journals.map((j) {
                                final date = DateFormat('dd MMM yyyy').format(DateTime.parse(j['created_at']));
                                return {'id': j['id'], 'label': '${j['topic_material']} ($date)'};
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedJurnal = val;
                                });
                              },
                              icon: PhosphorIcons.notebook(PhosphorIconsStyle.regular),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Text('Gagal memuat jurnal: $e', style: const TextStyle(color: Colors.red)),
                        );
                      },
                    ),
                  ],

                  if (_selectedJurnal != null) ...[
                    Spacing.custom(context, 32),
                    _buildSectionTitle(context, 'Informasi Tugas', PhosphorIcons.info(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 16),
                    _buildTextField(
                      context,
                      label: 'Judul Tugas',
                      controller: _judulController,
                      hint: 'Contoh: Makalah Sejarah VOC',
                      icon: PhosphorIcons.textT(PhosphorIconsStyle.regular),
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                    Spacing.custom(context, 16),
                    _buildTextField(
                      context,
                      label: 'Instruksi Pengerjaan',
                      controller: _instruksiController,
                      hint: 'Jelaskan instruksi atau format tugas...',
                      maxLines: 5,
                      validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),

                    Spacing.custom(context, 32),
                    _buildSectionTitle(context, 'Pengaturan Tambahan', PhosphorIcons.slidersHorizontal(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.w(context)),
                                border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular), color: AppColors.primary, size: 20),
                                  SizedBox(width: 12.w(context)),
                                  Expanded(
                                    child: Text(
                                      _selectedDate == null ? 'Tanggal Tenggat' : DateFormat('dd MMM yyyy').format(_selectedDate!),
                                      style: AppTextStyles.bodyMedium(context, color: _selectedDate == null ? AppColors.onSurface.withValues(alpha: 0.5) : AppColors.onSurface),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w(context)),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.w(context)),
                                border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), color: AppColors.primary, size: 20),
                                  SizedBox(width: 12.w(context)),
                                  Expanded(
                                    child: Text(
                                      _selectedTime == null ? 'Jam Tenggat' : _selectedTime!.format(context),
                                      style: AppTextStyles.bodyMedium(context, color: _selectedTime == null ? AppColors.onSurface.withValues(alpha: 0.5) : AppColors.onSurface),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Lampiran (Opsional)', PhosphorIcons.paperclip(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 16),
                    InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(16.w(context)),
                      child: Container(
                        padding: EdgeInsets.all(24.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16.w(context)),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), style: BorderStyle.solid),
                        ),
                        child: _selectedFile == null ? Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 28),
                            ),
                            SizedBox(height: 12.h(context)),
                            Text('Tap untuk unggah file', style: AppTextStyles.labelLarge(context, color: AppColors.primary)),
                            SizedBox(height: 4.h(context)),
                            Text('Maks. 20MB (PDF, JPG, PNG, DOCX, dll)', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.5))),
                          ],
                        ) : Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12.w(context)),
                              ),
                              child: Icon(PhosphorIcons.file(PhosphorIconsStyle.fill), color: Colors.white, size: 24),
                            ),
                            SizedBox(width: 16.w(context)),
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
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                  _fileName = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_uploadProgress > 0 && isSubmitting) ...[
                      Spacing.custom(context, 16),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: AppColors.surface,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text('${(_uploadProgress * 100).toStringAsFixed(1)}% Mengunggah...', style: AppTextStyles.labelSmall(context, color: AppColors.primary)),
                    ],

                    Spacing.custom(context, 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedDate == null || _selectedTime == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tenggat waktu wajib diisi!'), backgroundColor: Colors.red));
                              return;
                            }
                            
                            final dueDateTime = DateTime(
                              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                              _selectedTime!.hour, _selectedTime!.minute,
                            );
                            
                            final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDateTime);
                            
                            final success = await ref.read(tugasProvider.notifier).createTugas(
                              journalId: _selectedJurnal!,
                              title: _judulController.text,
                              description: _instruksiController.text,
                              dueDate: formattedDate,
                              attachment: _selectedFile,
                              onProgress: (progress) {
                                setState(() {
                                  _uploadProgress = progress;
                                });
                              }
                            );
                            
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tugas berhasil diterbitkan!'), backgroundColor: Colors.green));
                              Navigator.pop(context);
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menerbitkan tugas.'), backgroundColor: Colors.red));
                              setState(() {
                                _uploadProgress = 0.0;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Terbitkan Tugas', style: AppTextStyles.titleSmall(context, color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gagal memuat opsi mapel'),
              ElevatedButton(
                onPressed: () => ref.read(jurnalProvider.notifier).fetchTerbitOptions(),
                child: const Text('Coba Lagi'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        SizedBox(width: 8.w(context)),
        Text(title, style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge(context, color: AppColors.onSurface)),
        SizedBox(height: 8.h(context)),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.onSurface.withValues(alpha: 0.5)) : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.all(16.w(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required List<Map<String, dynamic>> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge(context, color: AppColors.onSurface)),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(
                value: item['id'].toString(),
                child: Text(item['label'].toString(), style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
              )).toList(),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.onSurface.withValues(alpha: 0.5)) : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          dropdownColor: AppColors.surface,
          icon: Icon(PhosphorIcons.caretDown(), color: AppColors.onSurface.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}


