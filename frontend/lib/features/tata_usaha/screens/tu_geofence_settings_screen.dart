import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/anise_button.dart';
import '../../../../core/widgets/decorative_background.dart';

class TUGeofenceSettingsScreen extends ConsumerStatefulWidget {
  const TUGeofenceSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TUGeofenceSettingsScreen> createState() => _TUGeofenceSettingsScreenState();
}

class _TUGeofenceSettingsScreenState extends ConsumerState<TUGeofenceSettingsScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  String _selectedRadius = '100';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _radiusOptions = ['50', '100', '200', '500', '1000'];

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettings() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/master/school-settings/geofence');
      
      Map<String, dynamic> data = {};
      if (response.data is Map) {
        if (response.data['data'] is Map) {
          data = Map<String, dynamic>.from(response.data['data']);
        } else {
          data = Map<String, dynamic>.from(response.data);
        }
      }

      setState(() {
        _latController.text = data['geofence_lat']?.toString() ?? '-6.200000';
        _lngController.text = data['geofence_lng']?.toString() ?? '106.816666';
        final rad = data['geofence_radius']?.toString();
        if (rad != null && _radiusOptions.contains(rad)) {
          _selectedRadius = rad;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil data geofence: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    final latText = _latController.text.trim();
    final lngText = _lngController.text.trim();

    if (latText.isEmpty || lngText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Latitude dan Longitude harus diisi!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/master/school-settings/geofence', data: {
        'lat': double.parse(latText),
        'lng': double.parse(lngText),
        'radius': int.parse(_selectedRadius),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pengaturan Geofence berhasil disimpan!', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        title: Text(
          'Radius & Titik Presensi',
          style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: DecorativeBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w(context)),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16.w(context)),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.primary, size: 28.w(context)),
                            SizedBox(width: 12.w(context)),
                            Expanded(
                              child: Text(
                                'Pengaturan ini menentukan pusat koordinat GPS sekolah dan jarak toleransi maksimal saat guru atau siswa melakukan presensi.',
                                style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h(context)),
                      Text('Titik Pusat Sekolah (GPS)', style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
                      SizedBox(height: 12.h(context)),
                      TextField(
                        controller: _latController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(
                          labelText: 'Latitude',
                          hintText: 'Contoh: -6.200000',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                          prefixIcon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.bold), color: AppColors.primary),
                        ),
                      ),
                      SizedBox(height: 16.h(context)),
                      TextField(
                        controller: _lngController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        decoration: InputDecoration(
                          labelText: 'Longitude',
                          hintText: 'Contoh: 106.816666',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                          prefixIcon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.bold), color: AppColors.primary),
                        ),
                      ),
                      SizedBox(height: 24.h(context)),
                      Text('Radius Jangkauan Presensi (meter)', style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
                      SizedBox(height: 12.h(context)),
                      DropdownButtonFormField<String>(
                        value: _selectedRadius,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                          prefixIcon: Icon(PhosphorIcons.rss(PhosphorIconsStyle.bold), color: AppColors.primary),
                        ),
                        items: _radiusOptions.map((String radius) {
                          return DropdownMenuItem<String>(
                            value: radius,
                            child: Text('$radius Meter'),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) setState(() => _selectedRadius = newValue);
                        },
                      ),
                      SizedBox(height: 40.h(context)),
                      AniseButton(
                        text: 'Simpan Pengaturan Geofence',
                        onPressed: _isSaving ? null : _saveSettings,
                        isLoading: _isSaving,
                        icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}