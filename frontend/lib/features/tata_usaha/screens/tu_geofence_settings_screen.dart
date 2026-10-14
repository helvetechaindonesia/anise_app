import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_button.dart';
import '../../../core/widgets/anise_state_feedback.dart';
import '../../../core/widgets/decorative_background.dart';
import '../../../core/widgets/item_list_tile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TUGeofenceSettingsScreen extends ConsumerStatefulWidget {
  const TUGeofenceSettingsScreen({super.key});

  @override
  ConsumerState<TUGeofenceSettingsScreen> createState() => _TUGeofenceSettingsScreenState();
}

class _TUGeofenceSettingsScreenState extends ConsumerState<TUGeofenceSettingsScreen> {
  bool _isLoading = true;
  List<dynamic> _locations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/master/school-locations');

      List<dynamic> fetched = [];
      if (response.data is Map && response.data['data'] is List) {
        fetched = response.data['data'];
      } else if (response.data is List) {
        fetched = response.data;
      }

      // Jika kosong, fallback coba ambil dari /master/school-settings/geofence
      if (fetched.isEmpty) {
        try {
          final oldRes = await dio.get('/master/school-settings/geofence');
          if (oldRes.data is Map) {
            if (oldRes.data['locations'] is List && (oldRes.data['locations'] as List).isNotEmpty) {
              fetched = oldRes.data['locations'];
            } else if (oldRes.data['geofence_lat'] != null) {
              fetched = [
                {
                  'id': 'default-1',
                  'name': oldRes.data['name'] ?? 'Titik Utama Sekolah',
                  'latitude': double.tryParse(oldRes.data['geofence_lat'].toString()) ?? -6.200000,
                  'longitude': double.tryParse(oldRes.data['geofence_lng'].toString()) ?? 106.816666,
                  'radius_meters': int.tryParse(oldRes.data['geofence_radius'].toString()) ?? 100,
                  'is_active': true,
                }
              ];
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _locations = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat titik lokasi: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  Future<void> _confirmDeleteLocation(Map<String, dynamic> loc) async {
    final String locId = loc['id'].toString();
    final String locName = loc['name'] ?? 'Titik Lokasi';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w(context))),
        title: Text('Hapus Titik Lokasi?', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$locName"? Presensi tidak akan dapat dilakukan pada titik koordinat ini lagi.',
          style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Batal', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.w(context))),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final dio = ref.read(dioProvider);
                await dio.delete('/master/school-locations/$locId');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Titik lokasi "$locName" berhasil dihapus', style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
                _fetchLocations();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus lokasi: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text('Hapus', style: AppTextStyles.labelMedium(context, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLocationFormDialog({Map<String, dynamic>? location}) {
    final bool isEdit = location != null;
    final nameController = TextEditingController(text: isEdit ? location['name']?.toString() : '');
    final latController = TextEditingController(text: isEdit ? location['latitude']?.toString() : '-6.200000');
    final lngController = TextEditingController(text: isEdit ? location['longitude']?.toString() : '106.816666');
    String selectedRadius = isEdit ? (location['radius_meters']?.toString() ?? '100') : '100';
    bool isActive = isEdit ? (location['is_active'] == true || location['is_active'] == 1) : true;
    bool isSaving = false;

    final List<String> radiusOptions = ['50', '100', '200', '500', '1000'];
    if (!radiusOptions.contains(selectedRadius)) {
      radiusOptions.add(selectedRadius);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24.w(context),
              right: 24.w(context),
              top: 20.h(context),
              bottom: MediaQuery.of(context).viewInsets.bottom + 24.h(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w(context),
                      height: 5.h(context),
                      decoration: BoxDecoration(
                        color: AppColors.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h(context)),
                  Row(
                    children: [
                      Icon(
                        isEdit ? PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold) : PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
                        color: AppColors.primary,
                        size: 24.w(context),
                      ),
                      SizedBox(width: 10.w(context)),
                      Text(
                        isEdit ? 'Sunting Titik Lokasi' : 'Tambah Titik Lokasi Baru',
                        style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h(context)),

                  // 1. Nama Lokasi (Wajib)
                  Text('Nama Titik Lokasi:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 6.h(context)),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Kampus 1, Gedung Praktik, Lapangan...',
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      prefixIcon: Icon(PhosphorIcons.buildings(PhosphorIconsStyle.bold), color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                    ),
                  ),
                  SizedBox(height: 14.h(context)),

                  // 2. Latitude & Longitude
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Latitude (Lintang):', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                            SizedBox(height: 6.h(context)),
                            TextField(
                              controller: latController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                hintText: '-6.200000',
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Longitude (Bujur):', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                            SizedBox(height: 6.h(context)),
                            TextField(
                              controller: lngController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                              decoration: InputDecoration(
                                hintText: '106.816666',
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h(context)),

                  // 3. Radius Jangkauan Presensi
                  Text('Radius Jangkauan Presensi:', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface.withValues(alpha: 0.7))),
                  SizedBox(height: 6.h(context)),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRadius,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.backgroundLight,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                      prefixIcon: Icon(PhosphorIcons.rss(PhosphorIconsStyle.bold), color: AppColors.primary),
                    ),
                    items: radiusOptions.map((rad) {
                      return DropdownMenuItem<String>(
                        value: rad,
                        child: Text('$rad Meter'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedRadius = val);
                    },
                  ),
                  SizedBox(height: 14.h(context)),

                  // 4. Status Aktif
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Aktifkan Titik Lokasi Ini', style: AppTextStyles.titleSmall(context, color: AppColors.onBackground)),
                    subtitle: Text('Jika aktif, guru dan siswa dapat melakukan presensi di titik ini.', style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6))),
                    value: isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => setModalState(() => isActive = val),
                  ),
                  SizedBox(height: 24.h(context)),

                  // Tombol Simpan
                  AniseButton(
                    text: isEdit ? 'Simpan Perubahan' : 'Tambahkan Titik Lokasi',
                    isLoading: isSaving,
                    icon: PhosphorIcons.floppyDisk(PhosphorIconsStyle.bold),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final latText = latController.text.trim();
                            final lngText = lngController.text.trim();

                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nama titik lokasi wajib diisi!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              return;
                            }

                            if (latText.isEmpty || lngText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Latitude dan Longitude harus diisi!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              return;
                            }

                            final double? lat = double.tryParse(latText);
                            final double? lng = double.tryParse(lngText);
                            if (lat == null || lng == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Format koordinat tidak valid!', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);

                            try {
                              final dio = ref.read(dioProvider);
                              final payload = {
                                'name': name,
                                'latitude': lat,
                                'longitude': lng,
                                'radius_meters': int.tryParse(selectedRadius) ?? 100,
                                'is_active': isActive,
                              };

                              if (isEdit) {
                                final locId = location['id'].toString();
                                await dio.put('/master/school-locations/$locId', data: payload);
                              } else {
                                await dio.post('/master/school-locations', data: payload);
                              }

                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                              }

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit ? 'Titik lokasi berhasil diperbarui!' : 'Titik lokasi baru berhasil ditambahkan!',
                                    style: AppTextStyles.bodyMedium(context, color: AppColors.onPrimary),
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _fetchLocations();
                            } catch (e) {
                              setModalState(() => isSaving = false);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan: $e', style: AppTextStyles.bodyMedium(context, color: Colors.white)),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
          'Titik Lokasi Presensi',
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
              : RefreshIndicator(
                  onRefresh: _fetchLocations,
                  color: AppColors.primary,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 16.h(context)),
                    children: [
                      // Banner Informasi Multi Lokasi
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
                                'Sekolah dapat mendaftarkan lebih dari 1 titik lokasi presensi (misal: Kampus 1, Gedung Praktik, Lapangan). Guru dan siswa dapat presensi di salah satu titik aktif.',
                                style: AppTextStyles.bodySmall(context, color: AppColors.onBackground),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h(context)),

                      // Header Counter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daftar Titik Lokasi',
                            style: AppTextStyles.titleSmall(context, color: AppColors.onBackground).copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.w(context)),
                            ),
                            child: Text(
                              '${_locations.length} Lokasi Terdaftar',
                              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h(context)),

                      if (_locations.isEmpty)
                        AniseStateFeedback(
                          title: 'Belum Ada Titik Lokasi',
                          subtitle: 'Tambahkan titik lokasi GPS sekolah pertama Anda untuk mengaktifkan validasi radius presensi.',
                          icon: PhosphorIcons.mapPin(PhosphorIconsStyle.bold),
                          actionButtonText: 'Tambah Titik Lokasi',
                          onActionPressed: () => _showLocationFormDialog(),
                        )
                      else
                        ...List.generate(_locations.length, (index) {
                          final loc = _locations[index];
                          final locMap = Map<String, dynamic>.from(loc);
                          final String name = locMap['name']?.toString() ?? 'Titik Sekolah';
                          final String lat = locMap['latitude']?.toString() ?? '-';
                          final String lng = locMap['longitude']?.toString() ?? '-';
                          final String rad = locMap['radius_meters']?.toString() ?? '100';
                          final bool isActive = locMap['is_active'] == true || locMap['is_active'] == 1;
                          final bool isLast = index == _locations.length - 1;

                          return Slidable(
                            key: ValueKey(locMap['id'] ?? index),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.45,
                              children: [
                                SlidableAction(
                                  onPressed: (_) => _showLocationFormDialog(location: locMap),
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
                                  label: 'Edit',
                                  borderRadius: BorderRadius.horizontal(left: Radius.circular(12.w(context))),
                                ),
                                SlidableAction(
                                  onPressed: (_) => _confirmDeleteLocation(locMap),
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
                                  label: 'Hapus',
                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(12.w(context))),
                                ),
                              ],
                            ),
                            child: ItemListTile(
                              category: 'Radius Jangkauan: $rad Meter',
                              title: name,
                              metadataIcon: PhosphorIcons.crosshair(),
                              metadataText: 'GPS: $lat, $lng',
                              statusIcon: isActive
                                  ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                                  : PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                              statusText: isActive ? 'Status: Aktif' : 'Status: Nonaktif',
                              statusColor: isActive ? AppColors.success : AppColors.outline,
                              showDivider: !isLast,
                              onTap: () => _showLocationFormDialog(location: locMap),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(
                                  PhosphorIcons.list(PhosphorIconsStyle.bold), // Hamburger Menu Icon
                                  color: AppColors.onSurface.withValues(alpha: 0.6),
                                  size: 22.w(context),
                                ),
                                color: AppColors.surface,
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showLocationFormDialog(location: locMap);
                                  } else if (value == 'delete') {
                                    _confirmDeleteLocation(locMap);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.primary),
                                        SizedBox(width: 10.w(context)),
                                        Text('Edit', style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold), size: 18.w(context), color: AppColors.error),
                                        SizedBox(width: 10.w(context)),
                                        Text('Hapus', style: AppTextStyles.bodyMedium(context, color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      SizedBox(height: 70.h(context)),
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.bold), color: AppColors.onPrimary),
        label: Text('Tambah Titik Lokasi', style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700)),
        onPressed: () => _showLocationFormDialog(),
      ),
    );
  }
}