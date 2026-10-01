import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../providers/disiplin_provider.dart';

class BkInputDisiplinScreen extends ConsumerStatefulWidget {
  const BkInputDisiplinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BkInputDisiplinScreen> createState() => _BkInputDisiplinScreenState();
}

class _BkInputDisiplinScreenState extends ConsumerState<BkInputDisiplinScreen> {
  int? _selectedStudentId;
  String? _kategoriPelanggaran;
  final TextEditingController _notesController = TextEditingController();
  
  final List<String> _kategoriList = ['Terlambat', 'Atribut Tidak Lengkap', 'Bolos', 'Lainnya'];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedStudentId == null) {
      _showSnackbar('Pilih siswa terlebih dahulu', AppColors.error);
      return;
    }
    if (_kategoriPelanggaran == null) {
      _showSnackbar('Pilih kategori pelanggaran', AppColors.error);
      return;
    }

    final success = await ref.read(disiplinNotifierProvider.notifier).submitReport(
      siswaId: _selectedStudentId!,
      category: _kategoriPelanggaran!,
      notes: _notesController.text,
    );

    if (success) {
      _showSnackbar('Laporan kedisiplinan berhasil dikirim', AppColors.success);
      if (mounted) Navigator.pop(context);
    } else {
      _showSnackbar('Gagal mengirim laporan', AppColors.error);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyMedium(context)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allSiswaProvider);
    final isLoading = ref.watch(disiplinNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lapor Kedisiplinan',
          style: AppTextStyles.titleMedium(context, color: AppColors.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w(context), vertical: 24.h(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return const Text('Tidak ada data siswa.');
                }
                return _buildStudentAutocompleteField('Pilih Siswa', students);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Gagal memuat siswa: $err'),
            ),
            Spacing.custom(context, 20),
            _buildDropdownField('Kategori Pelanggaran', _kategoriList, _kategoriPelanggaran, (val) => setState(() => _kategoriPelanggaran = val)),
            Spacing.custom(context, 20),
            _buildTextField('Catatan / Keterangan', controller: _notesController, maxLines: 4, hint: 'Contoh: Terlambat masuk setelah jam istirahat tanpa alasan...'),
            Spacing.custom(context, 40),
            SizedBox(
              width: double.infinity,
              height: 56.h(context),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w(context)),
                  ),
                ),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Kirim Laporan',
                        style: AppTextStyles.titleMedium(context, color: AppColors.onPrimary),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAutocompleteField(String label, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
        ),
        Spacing.custom(context, 8),
        Autocomplete<Map<String, dynamic>>(
          displayStringForOption: (option) => option['full_name'],
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return items.cast<Map<String, dynamic>>().where((student) {
              final String name = student['full_name'].toString().toLowerCase();
              final String query = textEditingValue.text.toLowerCase();
              return name.contains(query);
            });
          },
          onSelected: (Map<String, dynamic> selection) {
            setState(() {
              _selectedStudentId = selection['id'];
            });
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Ketik nama siswa...',
                hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w(context)),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                suffixIcon: _selectedStudentId != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.error),
                        onPressed: () {
                          controller.clear();
                          setState(() {
                            _selectedStudentId = null;
                          });
                        },
                      )
                    : Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), color: AppColors.onBackground.withValues(alpha: 0.5)),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12.w(context)),
                color: AppColors.surface,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 48.w(context), // padding 24 kiri kanan
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option['full_name'], style: AppTextStyles.bodyMedium(context)),
                        subtitle: Text(option['username'] ?? '', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
        ),
        Spacing.custom(context, 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.w(context)),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text('Pilih $label', style: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5))),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: AppTextStyles.bodyMedium(context)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, {required TextEditingController controller, int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.w600),
        ),
        Spacing.custom(context, 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label',
            hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.w(context)),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
