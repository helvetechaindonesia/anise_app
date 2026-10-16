import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../providers/jurnal_provider.dart';

class GuruTerbitJurnalScreen extends ConsumerStatefulWidget {
  final String? initialScheduleId;
  final String? initialSubjectId;
  final String? initialTeachingDate;

  const GuruTerbitJurnalScreen({
    Key? key,
    this.initialScheduleId,
    this.initialSubjectId,
    this.initialTeachingDate,
  }) : super(key: key);

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
  bool _hasInitializedSelection = false;

  @override
  void initState() {
    super.initState();
    _selectedMapel = widget.initialSubjectId;
    if (widget.initialScheduleId != null && widget.initialTeachingDate != null) {
      _selectedJadwal = "${widget.initialScheduleId}|${widget.initialTeachingDate}";
    }

    // Panggil fetchTerbitOptions segera setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jurnalProvider.notifier).fetchTerbitOptions();
    });
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'svg', 'pdf', 'docx', 'xlsx', 'ppt', 'pptx'],
      );

      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        final File file = File(result.files.first.path!);
        final int sizeInBytes = file.lengthSync();
        final double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb > 20) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ukuran file maksimal adalah 20 MB'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        setState(() {
          _selectedFile = file;
          _fileName = result.files.first.name;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
    });
  }

  void _handleAutoSelectSchedule(List<dynamic> schedules) {
    if (_hasInitializedSelection) return;

    if (widget.initialScheduleId != null) {
      final match = schedules.firstWhere(
        (s) {
          final sId = s['schedule_id']?.toString() ?? s['id']?.toString() ?? '';
          if (widget.initialTeachingDate != null) {
            return sId == widget.initialScheduleId && s['teaching_date']?.toString() == widget.initialTeachingDate;
          }
          return sId == widget.initialScheduleId;
        },
        orElse: () => null,
      );

      if (match != null) {
        _selectedJadwal = match['id']?.toString();
        if (_selectedMapel == null && match['subject_id'] != null) {
          _selectedMapel = match['subject_id']?.toString();
        }
      }
    }

    _hasInitializedSelection = true;
  }

  @override
  Widget build(BuildContext context) {
    final jurnalState = ref.watch(jurnalProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Terbitkan Jurnal',
        subtitle: 'Rencana Pelaksanaan Pembelajaran (Micro-RPP)',
      ),
      body: SafeArea(
        child: jurnalState.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Memuat Opsi Jadwal & Mata Pelajaran...',
                  style: TextStyle(color: AppColors.onBackground, fontSize: 13),
                ),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w(context)),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), size: 48.w(context), color: AppColors.error),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'Gagal Memuat Opsi Terbit Jurnal',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 24.h(context)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 12.h(context)),
                    ),
                    onPressed: () => ref.read(jurnalProvider.notifier).fetchTerbitOptions(),
                    icon: Icon(PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onPrimary),
                    label: Text('Coba Lagi', style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary)),
                  ),
                ],
              ),
            ),
          ),
          data: (data) {
            final subjects = (data['subjects'] as List<dynamic>?) ?? [];
            final schedules = (data['schedules'] as List<dynamic>?) ?? [];

            // Auto prefill initial values jika tersedia
            _handleAutoSelectSchedule(schedules);

            if (subjects.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
                  child: AniseEmptyState(
                    title: 'Belum Ada Jadwal Mengajar',
                    subtitle: 'Akun Anda belum memiliki penugasan mata pelajaran atau jadwal KBM aktif dari Bagian Kurikulum.',
                  ),
                ),
              );
            }

            final availableSchedules = _selectedMapel == null
                ? schedules
                : schedules.where((s) => s['subject_id']?.toString() == _selectedMapel).toList();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 20.h(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Info SOP H-24
                    Container(
                      padding: EdgeInsets.all(14.w(context)),
                      margin: EdgeInsets.only(bottom: 24.h(context)),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14.w(context)),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.primary, size: 20.w(context)),
                          SizedBox(width: 10.w(context)),
                          Expanded(
                            child: Text(
                              'Terbitkan jurnal mengajar minimal H-24 jam sebelum jadwal KBM dimulai agar siswa dapat mempelajari materi terlebih dahulu.',
                              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground).copyWith(height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 1. Pilih Jadwal Master & Mapel
                    _buildSectionTitle(context, 'Pilih Jadwal Master', PhosphorIcons.calendarPlus(PhosphorIconsStyle.bold)),
                    SizedBox(height: 14.h(context)),
                    _buildMapelDropdown(subjects),
                    SizedBox(height: 16.h(context)),
                    _buildJadwalDropdown(availableSchedules),

                    SizedBox(height: 28.h(context)),

                    // 2. Jurnal Utama
                    _buildSectionTitle(context, 'Materi Pembelajaran', PhosphorIcons.notePencil(PhosphorIconsStyle.bold)),
                    SizedBox(height: 14.h(context)),
                    _buildTextField(
                      context,
                      label: 'Judul Topik / Materi Pembelajaran',
                      controller: _judulController,
                      hint: 'Contoh: Dinamika Partikel & Hukum Newton',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul topik materi wajib diisi.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h(context)),
                    _buildTextField(
                      context,
                      label: 'Deskripsi / Tujuan Pembelajaran (Micro-RPP)',
                      controller: _deskripsiController,
                      hint: 'Jelaskan tujuan dan poin-poin yang akan dicapai dalam sesi ini...',
                      maxLines: 4,
                    ),

                    SizedBox(height: 28.h(context)),

                    // 3. Lampiran Dokumen
                    _buildSectionTitle(context, 'Lampiran Dokumen (Opsional)', PhosphorIcons.paperclip(PhosphorIconsStyle.bold)),
                    SizedBox(height: 14.h(context)),
                    _buildAttachmentButton(context),

                    SizedBox(height: 28.h(context)),

                    // 4. Pengaturan Tugas
                    _buildSectionTitle(context, 'Pengaturan Tugas Siswa', PhosphorIcons.checkSquareOffset(PhosphorIconsStyle.bold)),
                    SizedBox(height: 14.h(context)),
                    _buildTaskToggle(),

                    SizedBox(height: 40.h(context)),

                    // 5. Submit Button
                    _buildSubmitButton(),
                    SizedBox(height: 32.h(context)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapelDropdown(List<dynamic> subjects) {
    // Deduping subjects by ID
    final Map<String, String> subjectMap = {};
    for (final s in subjects) {
      final id = s['id']?.toString();
      final name = s['name']?.toString() ?? 'Mata Pelajaran';
      if (id != null && !subjectMap.containsKey(id)) {
        subjectMap[id] = name;
      }
    }

    final hasMatch = _selectedMapel != null && subjectMap.containsKey(_selectedMapel);
    final effectiveValue = hasMatch ? _selectedMapel : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mata Pelajaran', style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(PhosphorIcons.bookBookmark(PhosphorIconsStyle.regular), color: AppColors.primary, size: 20.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          hint: Text('Pilih Mata Pelajaran', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4))),
          items: subjectMap.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          validator: (val) => val == null ? 'Silakan pilih mata pelajaran' : null,
          onChanged: (val) {
            setState(() {
              _selectedMapel = val;
              _selectedJadwal = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildJadwalDropdown(List<dynamic> schedules) {
    // Deduping schedules by ID
    final Map<String, dynamic> scheduleMap = {};
    for (final s in schedules) {
      final id = s['id']?.toString();
      if (id != null && !scheduleMap.containsKey(id)) {
        scheduleMap[id] = s;
      }
    }

    final hasMatch = _selectedJadwal != null && scheduleMap.containsKey(_selectedJadwal);
    final effectiveValue = hasMatch ? _selectedJadwal : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jadwal KBM & Kelas', style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular), color: AppColors.primary, size: 20.w(context)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          hint: Text(
            _selectedMapel == null ? 'Pilih Mata Pelajaran Terlebih Dahulu' : 'Pilih Jadwal yang Tersedia',
            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
          ),
          selectedItemBuilder: (context) {
            return scheduleMap.entries.map((entry) {
              final label = entry.value['label']?.toString() ?? '';
              final firstLine = label.split('\n').first;
              return Text(
                firstLine,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              );
            }).toList();
          },
          items: _selectedMapel == null
              ? []
              : scheduleMap.entries.map((entry) {
                  final s = entry.value;
                  final label = s['label']?.toString() ?? '';
                  final lines = label.split('\n');
                  final dateLine = lines.isNotEmpty ? lines[0] : '';
                  final classLine = lines.length > 1 ? lines[1] : '';

                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dateLine,
                            style: AppTextStyles.labelLarge(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (classLine.isNotEmpty) ...[
                            SizedBox(height: 2.h(context)),
                            Text(
                              classLine,
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
          validator: (val) => val == null ? 'Silakan pilih jadwal KBM' : null,
          onChanged: _selectedMapel == null
              ? null
              : (val) {
                  setState(() {
                    _selectedJadwal = val;
                  });
                },
        ),
      ],
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
                    Text('Ada Penugasan Siswa?', style: AppTextStyles.titleSmall(context, color: AppColors.onSurface)),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Aktifkan jika sesi pembelajaran ini disertai tugas mandiri atau kelompok.',
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
            SizedBox(height: 14.h(context)),
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
                  SizedBox(width: 10.w(context)),
                  Expanded(
                    child: Text(
                      'Siswa akan menerima badge penugasan pada kartu jurnal ini.',
                      style: AppTextStyles.labelSmall(context, color: AppColors.warning).copyWith(fontWeight: FontWeight.w600),
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
            value: _uploadProgress > 0 ? _uploadProgress : null,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            _uploadProgress > 0 ? 'Mengunggah materi... ${(_uploadProgress * 100).toStringAsFixed(0)}%' : 'Menerbitkan jurnal...',
            style: AppTextStyles.labelMedium(context, color: AppColors.primary),
          ),
          SizedBox(height: 16.h(context)),
        ],
        SizedBox(
          width: double.infinity,
          height: 52.h(context),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.w(context)),
              ),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              if (_selectedMapel == null || _selectedJadwal == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap pilih Mata Pelajaran dan Jadwal KBM terlebih dahulu.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
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
                topicMaterial: _judulController.text.trim(),
                description: _deskripsiController.text.trim(),
                hasTask: _isAdaTugas,
                attachment: _selectedFile,
                onProgress: (progress) {
                  if (mounted) {
                    setState(() {
                      _uploadProgress = progress;
                    });
                  }
                },
              );

              if (mounted) {
                setState(() { _isLoading = false; });
              }

              if (success && mounted) {
                // Refresh provider agar feed guru & siswa langsung memuat jurnal baru
                ref.invalidate(allJournalsProvider);
                ref.invalidate(kelasJadwalProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.onPrimary),
                        const SizedBox(width: 10),
                        const Text('Jurnal Mengajar Berhasil Diterbitkan!'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
                Navigator.pop(context, true);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gagal menerbitkan jurnal. Silakan periksa koneksi Anda.'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: _isLoading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onPrimary),
                      SizedBox(width: 8.w(context)),
                      Text('Terbitkan Jurnal Sekarang', style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary)),
                    ],
                  ),
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

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(context, color: AppColors.onBackground)),
        SizedBox(height: 8.h(context)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.outline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context)), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentButton(BuildContext context) {
    if (_selectedFile != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h(context), horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.w(context)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
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
      borderRadius: BorderRadius.circular(14.w(context)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h(context)),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.w(context)),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(PhosphorIcons.uploadSimple(PhosphorIconsStyle.bold), color: AppColors.primary, size: 28.w(context)),
            SizedBox(height: 8.h(context)),
            Text('Upload Modul / Materi PDF atau Gambar', style: AppTextStyles.titleSmall(context, color: AppColors.primary)),
            SizedBox(height: 4.h(context)),
            Text('Maks. 20MB (PDF, DOCX, PPTX, JPG, PNG)', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}
