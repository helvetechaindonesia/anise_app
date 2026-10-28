import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Akun & Keamanan',
    'Presensi & Geofence',
    'Akademik & Tugas',
    'Bimbingan BK',
    'Poin & Kedisiplinan',
    'Lapor & Komplain',
  ];

  final List<FaqItem> _faqList = const [
    // Akun & Keamanan
    FaqItem(
      category: 'Akun & Keamanan',
      question: 'Bagaimana cara mengubah kata sandi akun saya?',
      answer:
          'Anda dapat mengubah kata sandi dengan membuka menu Profil > Keamanan Akun > Ubah Kata Sandi. Masukkan kata sandi lama Anda diikuti dengan kata sandi baru (minimal 8 karakter dengan kombinasi huruf dan angka), lalu tekan Simpan Perubahan.',
    ),
    FaqItem(
      category: 'Akun & Keamanan',
      question: 'Apa yang harus dilakukan jika lupa kata sandi akun?',
      answer:
          'Pada halaman login, klik tautan "Lupa Sandi?". Anda akan diarahkan untuk memilih verifikasi via email terdaftar atau menghubungi Helpdesk IT Developer Helvetecha untuk reset kredensial akun sekolah Anda.',
    ),
    FaqItem(
      category: 'Akun & Keamanan',
      question: 'Mengapa saya perlu mendaftarkan biometrik wajah?',
      answer:
          'Perekaman biometrik wajah digunakan untuk memastikan keaslian presensi mandiri (anti-titip presensi) dan verifikasi identitas resmi siswa maupun tenaga pendidik di lingkungan sekolah.',
    ),
    FaqItem(
      category: 'Akun & Keamanan',
      question: 'Apakah akun saya dapat dibuka di lebih dari satu perangkat?',
      answer:
          'Untuk menjaga integritas data presensi dan sistem penilaian, satu akun hanya disarankan aktif pada satu perangkat utama. Jika terdeteksi login di perangkat baru, sesi sebelumnya akan diperbarui demi keamanan.',
    ),

    // Presensi & Geofence
    FaqItem(
      category: 'Presensi & Geofence',
      question: 'Mengapa muncul notifikasi "Di Luar Radius Sekolah" saat presensi?',
      answer:
          'Sistem presensi Anise dilengkapi teknologi Geofencing GPS berakurasi tinggi. Anda wajib berada di dalam area/radius resmi sekolah yang telah ditetapkan oleh pihak admin sekolah. Pastikan GPS HP Anda aktif dengan mode akurasi tinggi (High Accuracy) dan tidak menggunakan VPN atau fake GPS.',
    ),
    FaqItem(
      category: 'Presensi & Geofence',
      question: 'Bagaimana cara mengajukan izin atau sakit jika berhalangan hadir?',
      answer:
          'Buka menu Presensi > Ajukan Izin/Sakit. Pilih kategori (Sakit / Izin Dispensasi / Keperluan Keluarga), tentukan rentang tanggal, tuliskan alasan yang jelas, serta lampirkan foto surat dokter atau bukti resmi (format JPG/PNG/PDF). Pengajuan akan langsung masuk ke daftar verifikasi Guru Wali/BK.',
    ),
    FaqItem(
      category: 'Presensi & Geofence',
      question: 'Kapan batas waktu presensi masuk dan pulang sekolah?',
      answer:
          'Waktu presensi mengikuti jam operasional sekolah yang diatur di sistem backend. Keterlambatan melebihi batas toleransi (misal setelah pukul 07.00 WIB) akan otomatis tercatat sebagai "Terlambat" dan mempengaruhi metrik kedisiplinan.',
    ),

    // Akademik & Tugas
    FaqItem(
      category: 'Akademik & Tugas',
      question: 'Bagaimana cara mengumpulkan tugas dari bapak/ibu guru?',
      answer:
          'Buka menu Akademik > Tugas & Evaluasi. Pilih tugas yang bersangkutan, baca instruksi soal, lalu unggah berkas tugas Anda (dokumen atau foto). Pastikan menekan tombol "Kirim Tugas" hingga status tugas berubah menjadi "Terkirim".',
    ),
    FaqItem(
      category: 'Akademik & Tugas',
      question: 'Apakah saya bisa mengirim ulang tugas yang sudah dikumpulkan?',
      answer:
          'Pengiriman ulang (re-submit) hanya dapat dilakukan apabila tenggat waktu belum berakhir dan guru mata pelajaran mengaktifkan opsi izinkan revisi. Jika sudah dinilai, tugas bersifat terkunci.',
    ),
    FaqItem(
      category: 'Akademik & Tugas',
      question: 'Di mana saya bisa melihat nilai harian dan rapor kompetensi?',
      answer:
          'Nilai hasil tugas, ulangan harian, dan ringkasan nilai kompetensi dapat dipantau langsung melalui tab Evaluasi & Nilai pada modul Akademik atau di halaman rincian masing-masing mata pelajaran.',
    ),

    // Bimbingan BK
    FaqItem(
      category: 'Bimbingan BK',
      question: 'Apa fungsi menu Bimbingan Konseling (BK) di aplikasi?',
      answer:
          'Menu Bimbingan BK memfasilitasi sesi konseling terjadwal antara siswa dan Guru BK, baik bimbingan individu, bimbingan kelompok, maupun bimbingan karier/studi lanjut secara privat dan solutif.',
    ),
    FaqItem(
      category: 'Bimbingan BK',
      question: 'Apakah hasil sesi bimbingan konseling bersifat rahasia?',
      answer:
          'Ya. Catatan anekdot, asesmen psikologis, dan proses bimbingan bersifat rahasia dan mematuhi asas kerahasiaan kode etik bimbingan konseling profesional. Catatan ini hanya dapat diakses oleh Guru BK yang berwenang.',
    ),
    FaqItem(
      category: 'Bimbingan BK',
      question: 'Bagaimana siswa mengetahui jadwal sesi bimbingan BK?',
      answer:
          'Siswa akan menerima pemberitahuan agenda bimbingan yang tercantum di kartu jadwal bimbingan pada menu Bimbingan Konseling beserta lokasi ruangan dan nama guru konselor.',
    ),

    // Poin & Kedisiplinan
    FaqItem(
      category: 'Poin & Kedisiplinan',
      question: 'Bagaimana sistem Poin Kedisiplinan dan KPI bekerja?',
      answer:
          'Setiap siswa memiliki skor awal kedisiplinan (100 poin). Pelanggaran tata tertib (seperti terlambat, atribut tidak lengkap, atau ketidakhadiran tanpa keterangan) akan mengurangi poin berdasarkan pedoman tata tertib sekolah.',
    ),
    FaqItem(
      category: 'Poin & Kedisiplinan',
      question: 'Apakah poin pelanggaran bisa dipulihkan kembali?',
      answer:
          'Siswa dapat memulihkan poin kedisiplinan melalui pembiasaan positif, kegiatan konseling terbimbing dengan Guru BK, serta perolehan prestasi akademik maupun non-akademik sesuai kebijakan rehabilitasi poin sekolah.',
    ),

    // Lapor & Komplain
    FaqItem(
      category: 'Lapor & Komplain',
      question: 'Apa itu fitur Lapor & Komplain Sarpras/Kesiswaan?',
      answer:
          'Fitur ini memungkinkan seluruh civitas sekolah melaporkan kerusakan fasilitas/sarpras (misal: proyektor rusak, AC mati) atau kendala kesiswaan secara transparan dilengkapi foto bukti langsung kepada tim pengelola sarpras dan kesiswaan.',
    ),
    FaqItem(
      category: 'Lapor & Komplain',
      question: 'Bagaimana cara memantau tindak lanjut laporan sarpras saya?',
      answer:
          'Setiap laporan memiliki indikator status real-time: Menunggu Verifikasi, Sedang Diproses/Dikerjakan, atau Selesai Diperbaiki beserta catatan tindak lanjut dari petugas sarpras/kesiswaan.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _faqList.where((item) {
      final matchesCategory = _selectedCategory == 'Semua' || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildSearchAndFilters(context),
            Expanded(
              child: filteredList.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 12.h(context)),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildFaqCard(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 12.h(context)),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(PhosphorIcons.caretLeft(PhosphorIconsStyle.bold), color: AppColors.onBackground, size: 24.w(context)),
          ),
          SizedBox(width: 8.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FAQ (Pertanyaan Umum)', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                Text('Pusat jawaban kendala & panduan sistem Anise', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16.h(context), bottom: 12.h(context)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.w(context)),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan atau kata kunci...',
                  hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
                  prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold), color: AppColors.onSurface.withValues(alpha: 0.5)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(PhosphorIcons.xCircle(PhosphorIconsStyle.fill), color: AppColors.onSurface.withValues(alpha: 0.4)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 14.h(context)),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h(context)),
          SizedBox(
            height: 38.h(context),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w(context)),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  labelStyle: AppTextStyles.labelMedium(
                    context,
                    color: isSelected ? AppColors.onPrimary : AppColors.onBackground.withValues(alpha: 0.7),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.w(context)),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, FaqItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 6.h(context)),
          childrenPadding: EdgeInsets.only(left: 16.w(context), right: 16.w(context), bottom: 16.h(context)),
          leading: Container(
            padding: EdgeInsets.all(8.w(context)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.w(context)),
            ),
            child: Icon(PhosphorIcons.question(PhosphorIconsStyle.bold), color: AppColors.primary, size: 20.w(context)),
          ),
          title: Text(
            item.question,
            style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontSize: 14.w(context)),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4.h(context)),
            child: Text(
              item.category,
              style: AppTextStyles.labelSmall(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12.w(context)),
              ),
              child: Text(
                item.answer,
                style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.85)).copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone), size: 54.w(context), color: AppColors.onBackground.withValues(alpha: 0.3)),
            SizedBox(height: 16.h(context)),
            Text(
              'Tidak ada pertanyaan yang sesuai',
              style: AppTextStyles.titleMedium(context, color: AppColors.onBackground),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h(context)),
            Text(
              'Coba gunakan kata kunci pencarian lain atau pilih kategori Semua.',
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
