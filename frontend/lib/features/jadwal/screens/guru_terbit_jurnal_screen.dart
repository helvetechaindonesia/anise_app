import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_card.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../providers/jurnal_provider.dart';
import '../widgets/terbit_jurnal_dropdowns.dart';
import '../widgets/terbit_jurnal_attachment_box.dart';
import '../widgets/terbit_jurnal_sop_banner.dart';

class GuruTerbitJurnalScreen extends ConsumerStatefulWidget {
  final String? initialScheduleId;
  final String? initialSubjectId;
  final String? initialTeachingDate;

  const GuruTerbitJurnalScreen({
    super.key,
    this.initialScheduleId,
    this.initialSubjectId,
    this.initialTeachingDate,
  });

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
          AniseFeedbackDialog.showError(
            context,
            title: 'Ukuran File Terlalu Besar',
            message: 'Ukuran file lampiran modul maksimal adalah 20 MB. Silakan kompres atau pilih berkas lain.',
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
      AniseFeedbackDialog.showError(
        context,
        title: 'Gagal Memilih File',
        message: 'Terjadi kendala saat mengakses dokumen: $e',
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
      ),
      body: SafeArea(
        child: jurnalState.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h(context)),
                Text(
                  'Memuat Opsi Jadwal & Mata Pelajaran...',
                  style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
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
                    child: Icon(
                      PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                      size: 48.w(context),
                      color: AppColors.error,
                    ),
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
                    icon: Icon(
                      PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
                      size: 18.w(context),
                      color: AppColors.onPrimary,
                    ),
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
                  child: const AniseEmptyState(
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
              padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Info SOP H-24
                    const TerbitJurnalSopBanner(),
                    SizedBox(height: 20.h(context)),

                    // Card 1: Informasi Jadwal & Mata Pelajaran
                    AniseCard(
                      padding: EdgeInsets.all(18.w(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(
                            context,
                            icon: PhosphorIcons.calendar(PhosphorIconsStyle.bold),
                            title: 'Jadwal & Mata Pelajaran',
                            subtitle: 'Pilih mata pelajaran dan sesi jadwal mengajar Anda.',
                          ),
                          SizedBox(height: 16.h(context)),
                          TerbitJurnalMapelDropdown(
                            selectedMapel: _selectedMapel,
                            subjects: subjects,
                            onChanged: (val) {
                              setState(() {
                                _selectedMapel = val;
                                _selectedJadwal = null;
                              });
                            },
                          ),
                          SizedBox(height: 16.h(context)),
                          TerbitJurnalJadwalDropdown(
                            selectedJadwal: _selectedJadwal,
                            schedules: availableSchedules,
                            selectedMapel: _selectedMapel,
                            onChanged: (val) {
                              setState(() {
                                _selectedJadwal = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h(context)),

                    // Card 2: Rencana Pembelajaran (Micro-RPP)
                    AniseCard(
                      padding: EdgeInsets.all(18.w(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(
                            context,
                            icon: PhosphorIcons.notePencil(PhosphorIconsStyle.bold),
                            title: 'Rencana Pembelajaran',
                            subtitle: 'Uraikan materi pokok dan target capaian KBM.',
                          ),
                          SizedBox(height: 16.h(context)),
                          _buildTextField(
                            context,
                            label: 'Judul Topik / Materi Pembelajaran',
                            controller: _judulController,
                            hint: 'Contoh: Dinamika Partikel & Hukum Newton',
                            prefixIcon: PhosphorIcons.textT(PhosphorIconsStyle.regular),
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
                            label: 'Deskripsi / Capaian Pembelajaran (Micro-RPP)',
                            controller: _deskripsiController,
                            hint: 'Jelaskan tujuan pembelajaran, poin-poin yang akan dicapai, atau arahan untuk siswa...',
                            prefixIcon: PhosphorIcons.article(PhosphorIconsStyle.regular),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h(context)),

                    // Card 3: Lampiran Materi / Modul (Opsional)
                    AniseCard(
                      padding: EdgeInsets.all(18.w(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(
                            context,
                            icon: PhosphorIcons.paperclip(PhosphorIconsStyle.bold),
                            title: 'Lampiran Materi / Modul',
                            subtitle: 'Opsional. Unggah modul PDF, bahan bacaan, atau lembar tugas.',
                          ),
                          SizedBox(height: 16.h(context)),
                          TerbitJurnalAttachmentBox(
                            selectedFile: _selectedFile,
                            fileName: _fileName,
                            onPickFile: _pickFile,
                            onRemoveFile: _removeFile,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h(context)),

                    // Card 4: Penugasan Siswa
                    AniseCard(
                      padding: EdgeInsets.all(18.w(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardHeader(
                            context,
                            icon: PhosphorIcons.checkSquareOffset(PhosphorIconsStyle.bold),
                            title: 'Penugasan Siswa',
                            subtitle: 'Atur ketersediaan penugasan mandiri / kelompok pada sesi KBM ini.',
                          ),
                          SizedBox(height: 16.h(context)),
                          _buildTaskToggle(),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h(context)),

                    // Card 5: Submit Button
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


  Widget _buildCardHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w(context)),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.w(context)),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20.w(context)),
        ),
        SizedBox(width: 12.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h(context)),
              Text(
                subtitle,
                style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
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
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(left: 14.w(context), right: 10.w(context), top: maxLines > 1 ? 14.h(context) : 0),
                    child: Icon(prefixIcon, color: AppColors.primary, size: 20.w(context)),
                  )
                : null,
            prefixIconConstraints: BoxConstraints(minWidth: 46.w(context)),
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.w(context)),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildTaskToggle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada Penugasan Siswa?',
                    style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h(context)),
                  Text(
                    'Aktifkan jika sesi pembelajaran ini disertai tugas mandiri atau lembar kerja terstruktur.',
                    style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w(context)),
            Switch(
              value: _isAdaTugas,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.38),
              inactiveThumbColor: AppColors.outline,
              inactiveTrackColor: AppColors.outline.withValues(alpha: 0.15),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.warning, size: 20.w(context)),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Text(
                    'Siswa di kelas terkait akan menerima notifikasi penugasan dan dapat mengunggah lembar kerja / jawaban sesuai tenggat waktu.',
                    style: AppTextStyles.labelSmall(context, color: AppColors.warning).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        if (_isLoading) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6.w(context)),
            child: LinearProgressIndicator(
              value: _uploadProgress > 0 ? _uploadProgress : null,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6.h(context),
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            _uploadProgress > 0
                ? 'Mengunggah materi pembelajaran... ${(_uploadProgress * 100).toStringAsFixed(0)}%'
                : 'Menerbitkan jurnal mengajar...',
            style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
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
            onPressed: _isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (_selectedMapel == null || _selectedJadwal == null) {
                      AniseFeedbackDialog.showError(
                        context,
                        title: 'Jadwal Belum Dipilih',
                        message: 'Harap pilih Mata Pelajaran dan Jadwal KBM terlebih dahulu sebelum menerbitkan jurnal.',
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
                      setState(() {
                        _isLoading = false;
                      });
                    }

                    if (success && mounted) {
                      // Refresh provider agar feed guru & siswa langsung memuat jurnal baru
                      ref.invalidate(allJournalsProvider);
                      ref.invalidate(kelasJadwalProvider);

                      await AniseFeedbackDialog.showSuccess(
                        context,
                        title: 'Jurnal Berhasil Diterbitkan',
                        message: 'Rencana Pelaksanaan Pembelajaran (Micro-RPP) berhasil disimpan dan dapat diakses oleh siswa di kelas terkait.',
                        buttonText: 'Selesai',
                        onConfirm: () {
                          Navigator.pop(context, true);
                        },
                      );
                    } else if (mounted) {
                      AniseFeedbackDialog.showError(
                        context,
                        title: 'Gagal Menerbitkan Jurnal',
                        message: 'Terjadi kendala saat menerbitkan jurnal mengajar. Silakan periksa koneksi internet Anda dan coba lagi.',
                      );
                    }
                  },
            child: _isLoading
                ? SizedBox.square(
                    dimension: 22.w(context),
                    child: const CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.onPrimary),
                      SizedBox(width: 8.w(context)),
                      Text(
                        'Terbitkan Jurnal Sekarang',
                        style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
