import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../providers/counseling_provider.dart';

class BkIsiJurnalScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;

  const BkIsiJurnalScreen({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<BkIsiJurnalScreen> createState() => _BkIsiJurnalScreenState();
}

class _BkIsiJurnalScreenState extends ConsumerState<BkIsiJurnalScreen> {
  final _resultController = TextEditingController();
  final _notesEvaluasiController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final existingResult = widget.item['counseling_result']?.toString() ?? '';
    final existingEvaluasi = widget.item['notes_evaluasi']?.toString() ?? '';

    _resultController.text = existingResult;
    _notesEvaluasiController.text = existingEvaluasi;
  }

  @override
  void dispose() {
    _resultController.dispose();
    _notesEvaluasiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_resultController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil bimbingan / kesimpulan wajib diisi.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final counselingId = widget.item['id']?.toString() ?? '';
    final success = await ref.read(counselingNotifierProvider.notifier).fillJournal(
          counselingId: counselingId,
          result: _resultController.text.trim(),
          notesEvaluasi: _notesEvaluasiController.text.trim().isNotEmpty ? _notesEvaluasiController.text.trim() : null,
          rating: null,
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jurnal bimbingan dan penilaian berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final err = ref.read(counselingNotifierProvider.notifier).lastErrorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Gagal menyimpan jurnal bimbingan.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.item['student_name']?.toString() ?? 'Siswa';
    final className = widget.item['class_name']?.toString() ?? '';
    final topic = widget.item['topic']?.toString() ?? 'Bimbingan';
    final type = widget.item['type']?.toString() ?? 'INDIVIDU';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Isi Jurnal Bimbingan',
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Ringkasan Sesi
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.w(context)),
                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(20.w(context)),
                          ),
                          child: Text(
                            type,
                            style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (className.isNotEmpty) ...[
                          SizedBox(width: 8.w(context)),
                          Text(
                            className,
                            style: AppTextStyles.labelMedium(context, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      studentName,
                      style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      topic,
                      style: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h(context)),

              // Form 1: Hasil Bimbingan / Kesimpulan Sesi
              Text(
                'Hasil Bimbingan & Notulensi',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h(context)),
              TextField(
                controller: _resultController,
                maxLines: 4,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Tuliskan poin-poin permasalahan, pemahaman siswa, dan solusi/tindak lanjut...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 20.h(context)),

              // Form 2: Catatan Evaluasi Khusus Guru BK
              Text(
                'Catatan Evaluasi / Follow Up',
                style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h(context)),
              Text(
                'Catatan perkembangan siswa atau rencana tindak lanjut bimbingan berikutnya (opsional).',
                style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
              ),
              SizedBox(height: 8.h(context)),
              TextField(
                controller: _notesEvaluasiController,
                maxLines: 3,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Contoh: Siswa diminta berkonsultasi kembali 2 minggu lagi terkait target belajar...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.w(context)),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 32.h(context)),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 48.h(context),
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w(context)),
                    ),
                    elevation: 0,
                  ),
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 20.w(context),
                          height: 20.w(context),
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold), size: 20.w(context)),
                  label: Text(
                    _isSubmitting ? 'Menyimpan...' : 'Simpan Jurnal Bimbingan',
                    style: AppTextStyles.titleMedium(context, color: Colors.white).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h(context)),
            ],
          ),
        ),
      ),
    );
  }
}
