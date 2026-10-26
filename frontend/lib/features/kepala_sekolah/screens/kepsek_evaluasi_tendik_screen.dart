import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../../core/widgets/anise_empty_state.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/predikat_kinerja_card.dart';

class KepsekEvaluasiTendikScreen extends ConsumerStatefulWidget {
  const KepsekEvaluasiTendikScreen({super.key});

  @override
  ConsumerState<KepsekEvaluasiTendikScreen> createState() => _KepsekEvaluasiTendikScreenState();
}

class _KepsekEvaluasiTendikScreenState extends ConsumerState<KepsekEvaluasiTendikScreen> {
  bool _isLoading = true;
  List<dynamic> _academicYears = [];
  Map<String, dynamic>? _selectedAcademicYear;
  List<dynamic> _tendikList = [];
  String _selectedRoleFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEvaluations();
  }

  Future<void> _fetchEvaluations([String? academicYearId]) async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final queryParam = academicYearId != null ? '?academic_year_id=$academicYearId' : '';
      final response = await dio.get('/kpi/evaluations$queryParam');

      if (response.data['status'] == 'success') {
        final data = response.data['data'] as Map<String, dynamic>;
        setState(() {
          _academicYears = data['academic_years'] as List<dynamic>? ?? [];
          _selectedAcademicYear = data['current_academic_year'] as Map<String, dynamic>?;
          _tendikList = data['tendik_list'] as List<dynamic>? ?? [];
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data evaluasi.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAcademicYearPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 20.h(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.w(context))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w(context),
                  height: 4.h(context),
                  margin: EdgeInsets.only(bottom: 16.h(context)),
                  decoration: BoxDecoration(
                    color: AppColors.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
                  SizedBox(width: 8.w(context)),
                  Text(
                    'Pilih Semester / Tahun Ajaran',
                    style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              SizedBox(height: 16.h(context)),
              ..._academicYears.map((ay) {
                final bool isSelected = _selectedAcademicYear?['id']?.toString() == ay['id']?.toString();
                final semesterLabel = ay['semester'] == 'GENAP' ? 'Semester Genap' : 'Semester Ganjil';

                return InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _fetchEvaluations(ay['id']?.toString());
                  },
                  borderRadius: BorderRadius.circular(14.w(context)),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.h(context)),
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.35) : AppColors.surfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14.w(context)),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.15),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ay['name'] ?? 'Tahun Ajaran',
                              style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h(context)),
                            Text(
                              semesterLabel,
                              style: AppTextStyles.labelSmall(context, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.primary, size: 20.w(context)),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 10.h(context)),
            ],
          ),
        );
      },
    );
  }

  void _showEvaluationModal(Map<String, dynamic> tendik) {
    final eval = tendik['evaluation'] as Map<String, dynamic>?;

    String praktikKinerja = eval?['praktik_kinerja'] ?? 'SESUAI_EKSPEKTASI';
    String perilakuKerja = eval?['perilaku_kerja'] ?? 'SESUAI_EKSPEKTASI';
    String predikatKinerja = eval?['predikat_kinerja'] ?? 'BAIK';
    final notesController = TextEditingController(text: eval?['notes'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24.w(context),
                right: 24.w(context),
                top: 24.h(context),
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24.h(context),
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
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40.w(context),
                        height: 4.h(context),
                        margin: EdgeInsets.only(bottom: 16.h(context)),
                        decoration: BoxDecoration(
                          color: AppColors.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Tendik Header Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24.w(context),
                          backgroundColor: AppColors.surfaceVariant,
                          backgroundImage: tendik['avatar'] != null && tendik['avatar'].toString().isNotEmpty
                              ? NetworkImage(
                                  tendik['avatar'].toString().startsWith('http')
                                      ? tendik['avatar'].toString()
                                      : '${ApiConstants.baseUrl.replaceAll('/api', '')}${tendik['avatar']}',
                                )
                              : null,
                          child: tendik['avatar'] == null || tendik['avatar'].toString().isEmpty
                              ? Text(
                                  (tendik['full_name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                                )
                              : null,
                        ),
                        SizedBox(width: 14.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tendik['full_name'] ?? 'Nama Tendik',
                                style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2.h(context)),
                              Text(
                                '${tendik['role_type']?.toString().replaceAll('_', ' ')} • NIP: ${tendik['nip'] ?? '-'}',
                                style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h(context)),
                    Divider(color: AppColors.outline.withValues(alpha: 0.15)),
                    SizedBox(height: 16.h(context)),

                    // Form Dropdown 1: Praktik Kinerja
                    Text(
                      'Praktik Kinerja',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Berdasarkan dokumen Tindak Lanjut dan Refleksi Tindak Lanjut.',
                      style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 8.h(context)),
                    _buildDropdown(
                      value: praktikKinerja,
                      items: const [
                        DropdownMenuItem(value: 'DI_ATAS_EKSPEKTASI', child: Text('Di Atas Ekspektasi')),
                        DropdownMenuItem(value: 'SESUAI_EKSPEKTASI', child: Text('Sesuai Ekspektasi')),
                        DropdownMenuItem(value: 'DI_BAWAH_EKSPEKTASI', child: Text('Di Bawah Ekspektasi')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => praktikKinerja = val);
                      },
                    ),

                    SizedBox(height: 18.h(context)),

                    // Form Dropdown 2: Perilaku Kerja
                    Text(
                      'Perilaku Kerja',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'Berdasarkan penilaian terhadap 7 aspek Perilaku Kerja.',
                      style: AppTextStyles.bodySmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                    SizedBox(height: 8.h(context)),
                    _buildDropdown(
                      value: perilakuKerja,
                      items: const [
                        DropdownMenuItem(value: 'DI_ATAS_EKSPEKTASI', child: Text('Di Atas Ekspektasi')),
                        DropdownMenuItem(value: 'SESUAI_EKSPEKTASI', child: Text('Sesuai Ekspektasi')),
                        DropdownMenuItem(value: 'DI_BAWAH_EKSPEKTASI', child: Text('Di Bawah Ekspektasi')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => perilakuKerja = val);
                      },
                    ),

                    SizedBox(height: 18.h(context)),

                    // Form Dropdown 3: Predikat Kinerja*
                    Text(
                      'Predikat Kinerja*',
                      style: AppTextStyles.labelMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 8.h(context)),
                    _buildDropdown(
                      value: predikatKinerja,
                      items: const [
                        DropdownMenuItem(value: 'SANGAT_BAIK', child: Text('Sangat Baik')),
                        DropdownMenuItem(value: 'BAIK', child: Text('Baik')),
                        DropdownMenuItem(value: 'CUKUP', child: Text('Cukup')),
                        DropdownMenuItem(value: 'KURANG', child: Text('Kurang')),
                        DropdownMenuItem(value: 'SANGAT_KURANG', child: Text('Sangat Kurang')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => predikatKinerja = val);
                      },
                    ),

                    SizedBox(height: 18.h(context)),

                    // Catatan Tambahan Kepsek
                    Text(
                      'Catatan Pembinaan Kepala Sekolah (Opsional)',
                      style: AppTextStyles.labelMedium(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8.h(context)),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan catatan apresiasi atau arahan perbaikan...',
                        hintStyle: AppTextStyles.bodySmall(context, color: AppColors.outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
                        contentPadding: EdgeInsets.all(12.w(context)),
                      ),
                    ),

                    SizedBox(height: 24.h(context)),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(modalCtx);
                          await _submitEvaluation(
                            teacherId: tendik['user_id'].toString(),
                            praktikKinerja: praktikKinerja,
                            perilakuKerja: perilakuKerja,
                            predikatKinerja: predikatKinerja,
                            notes: notesController.text.trim(),
                          );
                        },
                        icon: Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.onPrimary),
                        label: Text(
                          'Simpan Evaluasi Tendik',
                          style: AppTextStyles.labelLarge(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.w(context))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _submitEvaluation({
    required String teacherId,
    required String praktikKinerja,
    required String perilakuKerja,
    required String predikatKinerja,
    required String notes,
  }) async {
    if (_selectedAcademicYear == null) return;

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/kpi/evaluations', data: {
        'teacher_id': teacherId,
        'academic_year_id': _selectedAcademicYear!['id'],
        'praktik_kinerja': praktikKinerja,
        'perilaku_kerja': perilakuKerja,
        'predikat_kinerja': predikatKinerja,
        'notes': notes,
      });

      if (response.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evaluasi kinerja berhasil disimpan!'), backgroundColor: Colors.green),
          );
        }
        await _fetchEvaluations(_selectedAcademicYear!['id']?.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan evaluasi.'), backgroundColor: AppColors.error),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter list tendik berdasarkan role dan search query
    final filteredTendik = _tendikList.where((t) {
      final matchesRole = _selectedRoleFilter == 'ALL' || t['role_type'] == _selectedRoleFilter;
      final name = (t['full_name'] ?? '').toString().toLowerCase();
      final nip = (t['nip'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty || name.contains(q) || nip.contains(q);
      return matchesRole && matchesQuery;
    }).toList();

    final evaluatedCount = _tendikList.where((t) => t['is_evaluated'] == true).length;
    final totalTendik = _tendikList.length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          const SliverSubHeader(
            title: 'Evaluasi Tendik',
            subtitle: 'Penilaian Kinerja Semester',
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14.h(context)),

                  // Header Baris Sub-Judul & Filter Tahun Ajaran (Pill Button Style)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENILAIAN KUALITATIF',
                            style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h(context)),
                          Text(
                            'Tenaga Pendidik',
                            style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      // Filter Tahun Akademik / Semester (Bentuk Tombol Pill "Pilih Tanggal")
                      if (_academicYears.isNotEmpty)
                        GestureDetector(
                          onTap: () => _showAcademicYearPicker(),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 6.h(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(16.w(context)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIcons.calendarBlank(PhosphorIconsStyle.bold),
                                  color: AppColors.onPrimaryContainer,
                                  size: 13.w(context),
                                ),
                                SizedBox(width: 4.w(context)),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 120.w(context)),
                                  child: Text(
                                    _selectedAcademicYear != null
                                        ? '${_selectedAcademicYear!['name']} (${_selectedAcademicYear!['semester'] == 'GENAP' ? 'Genap' : 'Ganjil'})'
                                        : 'Pilih Semester',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelSmall(
                                      context,
                                      color: AppColors.onPrimaryContainer,
                                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                                  ),
                                ),
                                SizedBox(width: 2.w(context)),
                                Icon(
                                  PhosphorIcons.caretDown(PhosphorIconsStyle.bold),
                                  color: AppColors.onPrimaryContainer,
                                  size: 11.w(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 16.h(context)),

                  // Progress Card Ringkasan Evaluasi
                  Container(
                    padding: EdgeInsets.all(18.w(context)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18.w(context)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress Evaluasi Semester',
                              style: AppTextStyles.labelMedium(context, color: AppColors.onPrimary.withValues(alpha: 0.8)),
                            ),
                            SizedBox(height: 4.h(context)),
                            Text(
                              '$evaluatedCount dari $totalTendik Tendik Dinilai',
                              style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
                          decoration: BoxDecoration(
                            color: AppColors.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.w(context)),
                          ),
                          child: Text(
                            totalTendik > 0 ? '${((evaluatedCount / totalTendik) * 100).toInt()}%' : '0%',
                            style: AppTextStyles.titleLarge(context, color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h(context)),

                  // Search Bar & Role Chips
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama guru atau staf TU...',
                      hintStyle: AppTextStyles.bodySmall(context, color: AppColors.outline),
                      prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.w(context)),
                        borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h(context)),
                    ),
                  ),

                  SizedBox(height: 12.h(context)),

                  // Filter Role Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'Semua Tendik'),
                        SizedBox(width: 8.w(context)),
                        _buildFilterChip('GURU', 'Guru Mapel'),
                        SizedBox(width: 8.w(context)),
                        _buildFilterChip('GURU_BK', 'Guru BK'),
                        SizedBox(width: 8.w(context)),
                        _buildFilterChip('TATA_USAHA', 'Staf TU'),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h(context)),
                ],
              ),
            ),
          ),

          // Daftar Kartu Tendik
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (filteredTendik.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: AniseEmptyState(
                title: 'Tendik Tidak Ditemukan',
                subtitle: 'Tidak ada data tenaga pendidik sesuai filter yang dipilih.',
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tendik = filteredTendik[index];
                    return _buildTendikCard(tendik);
                  },
                  childCount: filteredTendik.length,
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: 40.h(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String roleKey, String label) {
    final bool isSelected = _selectedRoleFilter == roleKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedRoleFilter = roleKey),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 8.h(context)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20.w(context)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            context,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
          ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildTendikCard(Map<String, dynamic> tendik) {
    final isEvaluated = tendik['is_evaluated'] == true;
    final eval = tendik['evaluation'] as Map<String, dynamic>?;

    final periodLabel = _selectedAcademicYear?['semester'] == 'GENAP' ? 'Januari - Juni' : 'Juli - Desember';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(18.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.w(context)),
        border: Border.all(
          color: isEvaluated ? AppColors.secondary.withValues(alpha: 0.3) : AppColors.outline.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22.w(context),
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage: tendik['avatar'] != null && tendik['avatar'].toString().isNotEmpty
                    ? NetworkImage(
                        tendik['avatar'].toString().startsWith('http')
                            ? tendik['avatar'].toString()
                            : '${ApiConstants.baseUrl.replaceAll('/api', '')}${tendik['avatar']}',
                      )
                    : null,
                child: tendik['avatar'] == null || tendik['avatar'].toString().isEmpty
                    ? Text(
                        (tendik['full_name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                        style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
                      )
                    : null,
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tendik['full_name'] ?? 'Nama Tendik',
                      style: AppTextStyles.titleSmall(context, color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      '${tendik['role_type']?.toString().replaceAll('_', ' ')} • NIP: ${tendik['nip'] ?? '-'}',
                      style: AppTextStyles.labelSmall(context, color: AppColors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w(context), vertical: 4.h(context)),
                decoration: BoxDecoration(
                  color: isEvaluated ? AppColors.secondary.withValues(alpha: 0.12) : AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.w(context)),
                ),
                child: Text(
                  isEvaluated ? 'Sudah Dinilai' : 'Belum Dinilai',
                  style: AppTextStyles.labelSmall(
                    context,
                    color: isEvaluated ? AppColors.secondary : AppColors.warning,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          if (isEvaluated && eval != null) ...[
            SizedBox(height: 14.h(context)),
            Divider(color: AppColors.outline.withValues(alpha: 0.12)),
            SizedBox(height: 10.h(context)),
            PredikatKinerjaCard(
              praktikKinerja: eval['praktik_kinerja'] ?? 'SESUAI_EKSPEKTASI',
              perilakuKerja: eval['perilaku_kerja'] ?? 'SESUAI_EKSPEKTASI',
              predikatKinerja: eval['predikat_kinerja'] ?? 'BAIK',
              periodLabel: periodLabel,
              notes: eval['notes'],
            ),
          ],

          SizedBox(height: 14.h(context)),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEvaluationModal(tendik),
              icon: Icon(
                isEvaluated ? PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold) : PhosphorIcons.plusCircle(PhosphorIconsStyle.bold),
                size: 16.w(context),
                color: isEvaluated ? AppColors.primary : AppColors.onPrimary,
              ),
              label: Text(
                isEvaluated ? 'Ubah Penilaian Kinerja' : 'Beri Penilaian Kinerja',
                style: AppTextStyles.labelMedium(
                  context,
                  color: isEvaluated ? AppColors.primary : AppColors.onPrimary,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: isEvaluated ? Colors.transparent : AppColors.primary,
                side: BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
                padding: EdgeInsets.symmetric(vertical: 12.h(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
