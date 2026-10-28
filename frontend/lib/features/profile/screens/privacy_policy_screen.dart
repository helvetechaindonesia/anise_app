import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20.w(context)),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildHeaderBanner(context),
                  SizedBox(height: 20.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                    title: '1. Komitmen Privasi Kami',
                    content:
                        'Pengembang aplikasi Anise ("Helvetecha") berkomitmen teguh melindungi privasi dan keamanan data pribadi seluruh pengguna, baik siswa, guru, maupun staf kependidikan. Kebijakan Privasi ini menerangkan bagaimana kami mengumpulkan, menggunakan, menyimpan, memproses, dan melindungi informasi pribadi Anda sesuai dengan standar Google Play Developer Policy dan peraturan perlindungan data pribadi di Republik Indonesia.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.identificationCard(PhosphorIconsStyle.fill),
                    title: '2. Data Pribadi yang Kami Kumpulkan',
                    content:
                        'Untuk mendukung fungsi administrasi sekolah terintegrasi, Anise mengumpulkan jenis informasi berikut:\n\n'
                        '• Data Identitas: Nama lengkap, Nomor Induk Siswa/Pegawai (NIS/NIP), peran (role: Siswa, Guru, Guru BK, dll), alamat email, nomor telepon/WhatsApp, dan kelas/kelompok bimbingan.\n'
                        '• Kredensial Autentikasi: Username dan kata sandi yang dienkripsi secara aman dengan algoritma hash tingkat tinggi (Argon2 / Bcrypt).\n'
                        '• Data Akademik & Kedisiplinan: Riwayat presensi, jadwal kelas, catatan bimbingan konseling, penilaian tugas, dan skor poin kedisiplinan.\n'
                        '• Data Laporan Komplain: Informasi sarana/prasarana yang dilaporkan, deskripsi keluhan, dan status tindak lanjut.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.lockSimple(PhosphorIconsStyle.fill),
                    title: '3. Penggunaan Izin Perangkat Sensitif (Sensitif Permissions)',
                    content:
                        'Aplikasi Anise meminta perizinan spesifik pada perangkat pengguna semata-mata untuk menjalankan fitur operasional inti aplikasi:\n\n'
                        'a. Izin Lokasi Presisi (ACCESS_FINE_LOCATION & ACCESS_COARSE_LOCATION)\n'
                        'Digunakan khusus untuk memvalidasi posisi GPS pengguna terhadap batas radius (Geofencing) sekolah saat proses presensi masuk, presensi pulang, atau izin dinas luar. Aplikasi TIDAK melacak posisi lokasi pengguna di latar belakang (background) di luar sesi presensi aktif.\n\n'
                        'b. Izin Kamera (CAMERA)\n'
                        'Digunakan saat pendaftaran dan verifikasi biometrik wajah presensi, pemotretan bukti surat izin sakit/dispensasi, pemotretan kerusakan fasilitas sarpras, dan pembaruan foto profil.\n\n'
                        'c. Izin Penyimpanan / Galeri Berkas (READ_MEDIA_IMAGES / STORAGE)\n'
                        'Digunakan untuk mengunggah dokumen tugas siswa, lampiran surat keterangan dokter/izin, serta mengunduh berkas materi atau bukti foto laporan tindak lanjut sarpras.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.cpu(PhosphorIconsStyle.fill),
                    title: '4. Pemrosesan Data Biometrik Wajah',
                    content:
                        'Data foto biometrik wajah yang didaftarkan diproses secara aman untuk menghasilkan representasi matematika / embedding vektor guna verifikasi presensi mandiri. Kami TIDAK menjual, membagikan, atau menggunakan data biometrik wajah untuk tujuan periklanan atau pihak ketiga yang tidak berhubungan dengan sekolah.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.shareNetwork(PhosphorIconsStyle.fill),
                    title: '5. Berbagi Data dengan Pihak Ketiga',
                    content:
                        'Kami TIDAK menjual atau memperdagangkan data pribadi pengguna kepada pihak ketiga manapun. Data hanya dapat diakses oleh otoritas sekolah yang berwenang (Kepala Sekolah, Wali Kelas, Guru BK, dan Admin IT Sekolah) untuk kepentingan administrasi pendidikan dan monitoring kedisiplinan siswa.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.shieldStar(PhosphorIconsStyle.fill),
                    title: '6. Keamanan & Retensi Penyimpanan Data',
                    content:
                        'Semua komunikasi data antara aplikasi seluler dan server backend diamankan menggunakan protokol Transport Layer Security (TLS/HTTPS). Basis data dilindungi oleh firewall berlapis, enkripsi data saat istirahat (at-rest), dan akses hak istimewa ketat. Data retensi dipertahankan selama masa pendidikan siswa terdaftar aktif di institusi sekolah bersangkutan.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    icon: PhosphorIcons.userMinus(PhosphorIconsStyle.fill),
                    title: '7. Hak Pengguna & Penghapusan Data',
                    content:
                        'Pengguna memiliki hak untuk meninjau data profil, memperbarui data yang tidak akurat, serta mengajukan permohonan penghapusan akun dan data pribadi kapan saja melalui menu "Kebijakan Penghapusan Data" di aplikasi atau menghubungi Helpdesk IT Developer.',
                  ),
                  SizedBox(height: 24.h(context)),
                  _buildContactNotice(context),
                  SizedBox(height: 32.h(context)),
                ],
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
                Text('Kebijakan Privasi', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                Text('Standar Perlindungan Data Pengguna (Play Store Compliant)', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.menuPastelBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.menuPastelBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.lockLaminated(PhosphorIconsStyle.fill), color: AppColors.menuPastelBlue, size: 36.w(context)),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perlindungan Privasi Anise',
                  style: AppTextStyles.titleMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Memenuhi persyaratan Google Play Privacy Policy & Peraturan Perlindungan Data Pribadi (UU PDP).',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontSize: 15.w(context)),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          Text(
            content,
            style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.85)).copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildContactNotice(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14.w(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kontak Penanggung Jawab Privasi (DPO):',
            style: AppTextStyles.labelMedium(context, color: AppColors.onBackground).copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'Helvetecha Privacy & Security Team\nEmail: privacy@helvetecha.com\nWhatsApp Support: +62 819-3131-5944',
            style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)).copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
