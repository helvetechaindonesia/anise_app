import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_card.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../providers/leave_provider.dart';

class AjukanIjinScreen extends ConsumerStatefulWidget {
  const AjukanIjinScreen({super.key});

  @override
  ConsumerState<AjukanIjinScreen> createState() => _AjukanIjinScreenState();
}

class _AjukanIjinScreenState extends ConsumerState<AjukanIjinScreen> {
  String _selectedCategory = 'IZIN'; // 'IZIN', 'SAKIT', 'DISPENSASI'
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _exitTime;

  String? _filePath;
  String? _fileName;

  File? _faceImageFile;
  Position? _currentPosition;
  bool _isGettingLocation = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = now;
    _endDate = now;
    _exitTime = TimeOfDay.now();
    _fetchLocation();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isGettingLocation = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isGettingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isGettingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) {
        setState(() {
          _currentPosition = pos;
          _isGettingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _takeFacePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );
      if (photo != null && mounted) {
        setState(() {
          _faceImageFile = File(photo.path);
        });
        if (_currentPosition == null) {
          _fetchLocation();
        }
      }
    } catch (e) {
      if (mounted) {
        AniseFeedbackDialog.showError(
          context,
          title: 'Kamera Gagal',
          message: 'Gagal membuka kamera: $e',
        );
      }
    }
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _filePath = result.files.first.path;
        _fileName = result.files.first.name;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 3)),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectExitTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _exitTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _exitTime = picked);
    }
  }

  void _submit() async {
    if (_reasonController.text.trim().isEmpty) {
      AniseFeedbackDialog.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Silakan isi alasan pengajuan perizinan terlebih dahulu.',
      );
      return;
    }
    if (_startDate == null || _endDate == null) {
      AniseFeedbackDialog.showError(
        context,
        title: 'Form Belum Lengkap',
        message: 'Rentang tanggal perizinan wajib dipilih.',
      );
      return;
    }

    final now = DateTime.now();
    // Cek batas jam 16.01 WIB untuk hari ini
    final isToday = _startDate!.year == now.year && _startDate!.month == now.month && _startDate!.day == now.day;
    if (isToday && (now.hour > 16 || (now.hour == 16 && now.minute > 1))) {
      AniseFeedbackDialog.showError(
        context,
        title: 'Batas Waktu Lewat',
        message: 'Batas pengajuan perizinan untuk hari ini maksimal pukul 16.01 WIB.',
      );
      return;
    }

    final startDateStr = "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}";
    final endDateStr = "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}";
    final exitTimeStr = _selectedCategory == 'DISPENSASI' && _exitTime != null
        ? "${_exitTime!.hour.toString().padLeft(2, '0')}:${_exitTime!.minute.toString().padLeft(2, '0')}:00"
        : null;

    final res = await ref.read(leaveNotifierProvider.notifier).submitLeave(
      type: _selectedCategory,
      reason: _reasonController.text.trim(),
      startDate: startDateStr,
      endDate: endDateStr,
      exitTime: exitTimeStr,
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      attachmentPath: _filePath,
      faceImagePath: _faceImageFile?.path,
    );

    if (res['success'] == true && mounted) {
      AniseFeedbackDialog.showSuccess(
        context,
        title: 'Pengajuan Terkirim',
        message: res['message'] ?? 'Pengajuan perizinan berhasil dikirim.',
      );
      Navigator.pop(context);
    } else if (mounted) {
      AniseFeedbackDialog.showError(
        context,
        title: 'Gagal Mengajukan',
        message: res['message'] ?? 'Terjadi kendala saat mengirim perizinan.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(leaveNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const AniseAppBar(
        title: 'Ajukan Ijin',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 16.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector Kategori: Izin, Sakit, Dispensasi
            Text(
              'PILIH KATEGORI PERIZINAN',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h(context)),
            Row(
              children: [
                _buildCategoryPill('IZIN', 'Izin', PhosphorIcons.envelopeSimple(PhosphorIconsStyle.bold)),
                SizedBox(width: 8.w(context)),
                _buildCategoryPill('SAKIT', 'Sakit', PhosphorIcons.firstAid(PhosphorIconsStyle.bold)),
                SizedBox(width: 8.w(context)),
                _buildCategoryPill('DISPENSASI', 'Dispensasi', PhosphorIcons.clockAfternoon(PhosphorIconsStyle.bold)),
              ],
            ),
            SizedBox(height: 20.h(context)),

            // 2. Rentang Tanggal
            Text(
              'RENTANG TANGGAL',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h(context)),
            Row(
              children: [
                Expanded(
                  child: _buildDateBox(
                    label: 'Tanggal Mulai',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: _buildDateBox(
                    label: 'Tanggal Selesai',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h(context)),

            // 3. Khusus Dispensasi: Jam Keluar
            if (_selectedCategory == 'DISPENSASI') ...[
              Text(
                'JAM KELUAR DISPENSASI',
                style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10.h(context)),
              GestureDetector(
                onTap: () => _selectExitTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.w(context)),
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.clock(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                      SizedBox(width: 10.w(context)),
                      Text(
                        _exitTime != null
                            ? "${_exitTime!.hour.toString().padLeft(2, '0')}:${_exitTime!.minute.toString().padLeft(2, '0')} WIB"
                            : 'Pilih Jam Keluar',
                        style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h(context)),
            ],

            // 4. Alasan / Keterangan
            Text(
              'ALASAN / KETERANGAN',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h(context)),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Contoh: Izin keperluan keluarga mendesak / Sakit demam tinggi...',
                hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.4)),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.all(14.w(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 20.h(context)),

            // 5. Verifikasi Wajah (Face Cam) & Lokasi Realtime
            Text(
              'VALIDASI BIOMETRIK & LOKASI REALTIME',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h(context)),
            AniseCard(
              borderRadius: 14.w(context),
              padding: EdgeInsets.all(14.w(context)),
              color: AppColors.surface,
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _takeFacePhoto,
                        child: Container(
                          width: 64.w(context),
                          height: 64.w(context),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12.w(context)),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            image: _faceImageFile != null
                                ? DecorationImage(image: FileImage(_faceImageFile!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _faceImageFile == null
                              ? Icon(PhosphorIcons.camera(PhosphorIconsStyle.bold), color: AppColors.primary, size: 28.w(context))
                              : null,
                        ),
                      ),
                      SizedBox(width: 14.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _faceImageFile != null ? 'Foto Wajah Terlampir' : 'Ambil Foto Wajah (Face Cam)',
                              style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 4.h(context)),
                            Text(
                              _currentPosition != null
                                  ? "GPS: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}"
                                  : (_isGettingLocation ? 'Mendeteksi lokasi realtime...' : 'GPS belum terdeteksi'),
                              style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.aperture(PhosphorIconsStyle.bold), color: AppColors.primary),
                        onPressed: _takeFacePhoto,
                        tooltip: 'Buka Kamera Depan',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h(context)),

            // 6. Lampiran Dokumen / Surat Keterangan
            Text(
              'LAMPIRAN SURAT / BUKTI PENDUKUNG',
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h(context)),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.w(context)),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.paperclip(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                    SizedBox(width: 10.w(context)),
                    Expanded(
                      child: Text(
                        _fileName ?? 'Pilih Berkas (PDF, JPG, PNG maks 10MB)',
                        style: AppTextStyles.bodyMedium(context, color: _fileName != null ? AppColors.onBackground : AppColors.onBackground.withValues(alpha: 0.4)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_fileName != null)
                      IconButton(
                        icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.error),
                        onPressed: () => setState(() {
                          _filePath = null;
                          _fileName = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h(context)),

            // 7. Tombol Submit Terstandarisasi
            AniseButton(
              text: 'Kirim Pengajuan Ijin',
              icon: PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.bold),
              isLoading: isSubmitting,
              onPressed: _submit,
            ),
            SizedBox(height: 24.h(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String code, String label, PhosphorIconData icon) {
    final isSelected = _selectedCategory == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = code),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h(context)),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12.w(context)),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.onPrimary : AppColors.onBackground, size: 20.w(context)),
              SizedBox(height: 4.h(context)),
              Text(
                label,
                style: AppTextStyles.labelSmall(
                  context,
                  color: isSelected ? AppColors.onPrimary : AppColors.onBackground,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox({required String label, required DateTime? date, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 12.h(context)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.w(context)),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
            SizedBox(height: 4.h(context)),
            Row(
              children: [
                Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), size: 16.w(context), color: AppColors.primary),
                SizedBox(width: 8.w(context)),
                Text(
                  date != null ? "${date.day}/${date.month}/${date.year}" : 'Pilih',
                  style: AppTextStyles.titleSmall(context, color: AppColors.onBackground),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
