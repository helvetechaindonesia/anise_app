import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/network/dio_client.dart';

class LaporanTelatSiswaScreen extends ConsumerStatefulWidget {
  const LaporanTelatSiswaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LaporanTelatSiswaScreen> createState() => _LaporanTelatSiswaScreenState();
}

class _LaporanTelatSiswaScreenState extends ConsumerState<LaporanTelatSiswaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();
  List<dynamic> _searchResults = [];
  dynamic _selectedSiswa;
  bool _isSearching = false;
  bool _isSubmitting = false;

  void _searchSiswa(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/auth/users/siswa/search', queryParameters: {'q': query});
      setState(() {
        _searchResults = response.data;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _submitLaporan() async {
    if (_selectedSiswa == null || _alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih siswa dan isi alasan terlebih dahulu!'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/users/laporan-telat', data: {
        'siswa_id': _selectedSiswa['id'],
        'alasan': _alasanController.text.trim(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${response.data['message']}'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (e is DioException && e.response?.data is Map) {
          errorMsg = e.response?.data['message'] ?? e.message;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $errorMsg'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text('Lapor Siswa Telat', style: AppTextStyles.titleMedium(context)),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cari Nama Siswa', style: AppTextStyles.titleSmall(context)),
            SizedBox(height: 12.h(context)),
            TextField(
              controller: _searchController,
              onChanged: _searchSiswa,
              decoration: InputDecoration(
                hintText: 'Ketik nama atau NISN...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold)),
                suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            
            if (_searchResults.isNotEmpty && _selectedSiswa == null) ...[
              SizedBox(height: 8.h(context)),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                constraints: BoxConstraints(maxHeight: 250.h(context)),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final siswa = _searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.primaryContainer, child: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), color: AppColors.primary)),
                      title: Text(siswa['full_name'] ?? '', style: AppTextStyles.bodyMedium(context)),
                      subtitle: Text(siswa['username'] ?? '', style: AppTextStyles.labelSmall(context)),
                      onTap: () {
                        setState(() {
                          _selectedSiswa = siswa;
                          _searchController.text = siswa['full_name'];
                          _searchResults = [];
                        });
                      },
                    );
                  },
                ),
              ),
            ],

            if (_selectedSiswa != null) ...[
              SizedBox(height: 16.h(context)),
              Container(
                padding: EdgeInsets.all(16.w(context)),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.primary),
                    SizedBox(width: 12.w(context)),
                    Expanded(child: Text('Terpilih: ${_selectedSiswa['full_name']}', style: AppTextStyles.titleSmall(context, color: AppColors.primary))),
                    IconButton(
                      icon: Icon(PhosphorIcons.x(PhosphorIconsStyle.bold), color: AppColors.primary),
                      onPressed: () => setState(() {
                        _selectedSiswa = null;
                        _searchController.clear();
                      }),
                    )
                  ],
                ),
              ),
            ],

            SizedBox(height: 24.h(context)),
            Text('Alasan Keterlambatan', style: AppTextStyles.titleSmall(context)),
            SizedBox(height: 12.h(context)),
            TextField(
              controller: _alasanController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Contoh: Terlambat 15 menit, tertahan di gerbang karena tidak memakai atribut lengkap...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),

            SizedBox(height: 32.h(context)),
            SizedBox(
              width: double.infinity,
              height: 56.h(context),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Kirim Laporan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}