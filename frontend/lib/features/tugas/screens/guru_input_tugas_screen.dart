import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../jadwal/providers/jurnal_provider.dart';
import '../providers/tugas_provider.dart';
import 'package:intl/intl.dart';

class GuruInputTugasScreen extends ConsumerStatefulWidget {
  final String? initialSubjectId;
  final String? initialJournalId;

  const GuruInputTugasScreen({
    Key? key,
    this.initialSubjectId,
    this.initialJournalId,
  }) : super(key: key);

  @override
  ConsumerState<GuruInputTugasScreen> createState() => _GuruInputTugasScreenState();
}

class _GuruInputTugasScreenState extends ConsumerState<GuruInputTugasScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedMapel;
  String? _selectedJurnal;
  
  final _judulController = TextEditingController();
  final _instruksiController = TextEditingController();
  
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
  File? _selectedFile;
  String? _fileName;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedMapel = widget.initialSubjectId;
    _selectedJurnal = widget.initialJournalId;
    
    // Default deadline: besok pukul 23:59 WIB
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    _selectedTime = const TimeOfDay(hour: 23, minute: 59);

    Future.microtask(() => ref.read(jurnalProvider.notifier).fetchTerbitOptions());
  }

  @override
  void dispose() {
    _judulController.dispose();
    _instruksiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'pdf', 'docx', 'xlsx', 'ppt', 'pptx', 'zip'],
    );

    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      File file = File(result.files.first.path!);
      int sizeInBytes = file.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 20) {
        if (!mounted) return;
        AniseFeedbackDialog.showWarning(
          context,
          title: 'Ukuran Berkas Terlalu Besar',
          message: 'Ukuran file lampiran maksimal adalah 20MB. Silakan pilih berkas yang lebih kecil.',
        );
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = result.files.first.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jurnalState = ref.watch(jurnalProvider);
    final isSubmitting = ref.watch(tugasProvider).isLoading;
    final isLinkedFromJournal = widget.initialJournalId != null && widget.initialJournalId!.isNotEmpty;

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
              isLinkedFromJournal ? 'Terhubung dengan Jurnal Mengajar' : 'Terbitkan tugas untuk kelas siswa',
              style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: jurnalState.when(
        data: (data) {
          final subjects = data['subjects'] as List<dynamic>? ?? [];
          
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 20.h(context)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jika terhubung dari Jurnal
                  if (isLinkedFromJournal) ...[
                    Container(
                      padding: EdgeInsets.all(14.w(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14.w(context)),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.link(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                          SizedBox(width: 10.w(context)),
                          Expanded(
                            child: Text(
                              'Tugas ini otomatis terhubung ke jurnal pembelajaran yang baru saja Anda pilih.',
                              style: AppTextStyles.bodySmall(context, color: AppColors.onPrimaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacing.custom(context, 16),
                  ],

                  if (!isLinkedFromJournal) ...[
                    _buildSectionTitle(context, 'Pilih Mata Pelajaran', PhosphorIcons.bookBookmark(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 12),
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
                      Spacing.custom(context, 24),
                      _buildSectionTitle(context, 'Pilih Jurnal Terkait', PhosphorIcons.notebook(PhosphorIconsStyle.bold)),
                      Spacing.custom(context, 12),
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
                                          'Belum ada jurnal yang diterbitkan untuk mapel ini. Silakan terbitkan jurnal mengajar terlebih dahulu.',
                                          style: AppTextStyles.bodySmall(context, color: AppColors.warning),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return _buildDropdownField(
                                context,
                                label: 'Jurnal Mengajar',
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
                            error: (e, s) => Text('Gagal memuat jurnal: $e', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                          );
                        },
                      ),
                    ],
                  ],

                  if (_selectedJurnal != null || isLinkedFromJournal) ...[
                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Detail Tugas', PhosphorIcons.notePencil(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 12),
                    _buildTextField(
                      context,
                      label: 'Judul Tugas',
                      controller: _judulController,
                      hint: 'Contoh: Analisis Dinamika Struktur Organisasi',
                      icon: PhosphorIcons.textT(PhosphorIconsStyle.regular),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Judul tugas wajib diisi' : null,
                    ),
                    Spacing.custom(context, 16),
                    _buildTextField(
                      context,
                      label: 'Petunjuk & Instruksi Pengerjaan',
                      controller: _instruksiController,
                      hint: 'Jelaskan tata cara pengerjaan, format berkas, atau kriteria penilaian...',
                      maxLines: 4,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Instruksi tugas wajib diisi' : null,
                    ),

                    Spacing.custom(context, 24),
                    _buildSectionTitle(context, 'Tenggat Waktu Pengumpulan', PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12.w(context)),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 14.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.w(context)),
                                border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.regular), color: AppColors.primary, size: 20.w(context)),
                                  SizedBox(width: 10.w(context)),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd MMM yyyy').format(_selectedDate),
                                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w(context)),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            borderRadius: BorderRadius.circular(12.w(context)),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 14.h(context)),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12.w(context)),
                                border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.clock(PhosphorIconsStyle.regular), color: AppColors.primary, size: 20.w(context)),
                                  SizedBox(width: 10.w(context)),
                                  Expanded(
                                    child: Text(
                                      _selectedTime.format(context),
                                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
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
                    _buildSectionTitle(context, 'Lampiran Tugas Guru (Opsional)', PhosphorIcons.paperclip(PhosphorIconsStyle.bold)),
                    Spacing.custom(context, 12),
                    InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(16.w(context)),
                      child: Container(
                        padding: EdgeInsets.all(20.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16.w(context)),
                          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                        ),
                        child: _selectedFile == null ? Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 26.w(context)),
                            ),
                            SizedBox(height: 10.h(context)),
                            Text('Ketuk untuk unggah soal / modul tugas', style: AppTextStyles.labelLarge(context, color: AppColors.primary)),
                            SizedBox(height: 4.h(context)),
                            Text('PDF, Dokumen, atau Gambar (Maks. 20MB)', style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
                          ],
                        ) : Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w(context)),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10.w(context)),
                              ),
                              child: Icon(PhosphorIcons.file(PhosphorIconsStyle.fill), color: AppColors.primary, size: 22.w(context)),
                            ),
                            SizedBox(width: 12.w(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_fileName ?? 'Berkas Terlampir', style: AppTextStyles.titleSmall(context, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  SizedBox(height: 2.h(context)),
                                  Text('${(_selectedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB', style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant)),
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
                        backgroundColor: AppColors.backgroundLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text('${(_uploadProgress * 100).toStringAsFixed(0)}% Mengunggah...', style: AppTextStyles.labelSmall(context, color: AppColors.primary)),
                    ],

                    Spacing.custom(context, 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h(context),
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            final effectiveJournalId = _selectedJurnal ?? widget.initialJournalId;
                            if (effectiveJournalId == null || effectiveJournalId.isEmpty) {
                              AniseFeedbackDialog.showWarning(
                                context,
                                title: 'Jurnal Belum Dipilih',
                                message: 'Harap pilih jurnal mengajar yang sesuai terlebih dahulu!',
                              );
                              return;
                            }

                            final dueDateTime = DateTime(
                              _selectedDate.year, _selectedDate.month, _selectedDate.day,
                              _selectedTime.hour, _selectedTime.minute,
                            );

                            if (dueDateTime.isBefore(DateTime.now())) {
                              AniseFeedbackDialog.showWarning(
                                context,
                                title: 'Tenggat Waktu Tidak Valid',
                                message: 'Tenggat waktu pengumpulan tidak boleh diatur di masa lalu.',
                              );
                              return;
                            }
                            
                            final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dueDateTime);
                            
                            final success = await ref.read(tugasProvider.notifier).createTugas(
                              journalId: effectiveJournalId,
                              title: _judulController.text.trim(),
                              description: _instruksiController.text.trim(),
                              dueDate: formattedDate,
                              attachment: _selectedFile,
                              onProgress: (progress) {
                                setState(() {
                                  _uploadProgress = progress;
                                });
                              }
                            );
                            
                            if (success && mounted) {
                              ref.invalidate(getTasksProvider);
                              AniseFeedbackDialog.showSuccess(
                                context,
                                title: 'Tugas Diterbitkan',
                                message: 'Tugas berhasil diterbitkan dan langsung dikirimkan ke seluruh siswa di kelas.',
                                onConfirm: () {
                                  Navigator.pop(context);
                                },
                              );
                            } else if (mounted) {
                              AniseFeedbackDialog.showError(
                                context,
                                title: 'Gagal Menerbitkan',
                                message: 'Terjadi kendala saat menerbitkan tugas. Periksa koneksi internet Anda.',
                              );
                              setState(() {
                                _uploadProgress = 0.0;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w(context))),
                          elevation: 0,
                        ),
                        child: isSubmitting
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Terbitkan Tugas Sekarang', style: AppTextStyles.titleSmall(context, color: Colors.white)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gagal memuat data formulir tugas'),
              SizedBox(height: 8.h(context)),
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
        Icon(icon, color: AppColors.primary, size: 20.w(context)),
        SizedBox(width: 8.w(context)),
        Text(title, style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    TextEditingController? controller,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 6.h(context)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
            prefixIcon: icon != null ? Icon(icon, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)) : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.all(14.w(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
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
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 6.h(context)),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) => DropdownMenuItem(
                value: item['id'].toString(),
                child: Text(item['label'].toString(), style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
              )).toList(),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)) : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 14.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          dropdownColor: AppColors.surface,
          icon: Icon(PhosphorIcons.caretDown(PhosphorIconsStyle.bold), color: AppColors.onSurfaceVariant, size: 16.w(context)),
        ),
      ],
    );
  }
}
