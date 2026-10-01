import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/dio_client.dart';

class TUGeofenceSettingsScreen extends ConsumerStatefulWidget {
  const TUGeofenceSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TUGeofenceSettingsScreen> createState() => _TUGeofenceSettingsScreenState();
}

class _TUGeofenceSettingsScreenState extends ConsumerState<TUGeofenceSettingsScreen> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  String _selectedRadius = '50';
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _radiusOptions = ['50', '100', '200', '500', '1000'];

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/master/school-settings/geofence');
      final data = response.data as Map<String, dynamic>;
      
      setState(() {
        _latController.text = data['geofence_lat'] ?? '';
        _lngController.text = data['geofence_lng'] ?? '';
        if (data['geofence_radius'] != null && _radiusOptions.contains(data['geofence_radius'])) {
          _selectedRadius = data['geofence_radius'];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_latController.text.isEmpty || _lngController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude dan Longitude harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/master/school-settings/geofence', data: {
        'lat': double.parse(_latController.text),
        'lng': double.parse(_lngController.text),
        'radius': int.parse(_selectedRadius),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan Geofence berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
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
        title: Text('Pengaturan Geofence', style: AppTextStyles.titleMedium(context)),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Titik Pusat Sekolah', style: AppTextStyles.titleSmall(context)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(PhosphorIcons.mapPin(PhosphorIconsStyle.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Radius Jangkauan Presensi (meter)', style: AppTextStyles.titleSmall(context)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedRadius,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(PhosphorIcons.rss(PhosphorIconsStyle.bold)),
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
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Simpan Pengaturan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}