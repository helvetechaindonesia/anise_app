import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
                    number: '1',
                    title: 'Penerimaan Syarat & Ketentuan',
                    content:
                        'Dengan mengunduh, memasang, mendaftar, dan/atau menggunakan aplikasi Anise ("Aplikasi"), Anda menyatakan bahwa Anda telah membaca, memahami, dan menyetujui untuk terikat secara hukum oleh Syarat dan Ketentuan ini. Jika Anda tidak menyetujui ketentuan ini, mohon untuk tidak menggunakan Aplikasi.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '2',
                    title: 'Kualifikasi Pengguna & Akun Sekolah',
                    content:
                        'Aplikasi Anise dirancang khusus untuk lingkungan institusi pendidikan (sekolah). Pengguna Aplikasi mencakup Siswa, Tenaga Pendidik (Guru Mata Pelajaran, Wali Kelas, Guru BK, Tenaga Pembina), serta Tenaga Kependidikan/Staf Inventaris & Kesiswaan.\n\n'
                        '• Akun resmi diterbitkan atau diverifikasi oleh administrator sekolah yang berwenang.\n'
                        '• Pengguna wajib menjaga kerahasiaan username dan kata sandi masing-masing.\n'
                        '• Segala aktivitas dan pengiriman data yang dilakukan melalui akun Pengguna merupakan tanggung jawab penuh pemilik akun.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '3',
                    title: 'Integritas Data Presensi & Penggunaan GPS',
                    content:
                        'Aplikasi Anise mengintegrasikan pencatatan kehadiran menggunakan koordinat lokasi GPS (Geofence) dan pencocokan biometrik wajah.\n\n'
                        '• Pengguna dilarang keras melakukan manipulasi lokasi melalui aplikasi Fake GPS, Mock Location, emulator, atau metode manipulasi digital lainnya.\n'
                        '• Pengguna dilarang melakukan penitipan presensi atau menyalahgunakan foto pihak lain untuk verifikasi presensi wajah.\n'
                        '• Pelanggaran terhadap kejujuran presensi akan dikenai sanksi kedisiplinan dan pengurangan skor kedisiplinan sesuai tata tertib sekolah.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '4',
                    title: 'Etika Akademik & Bimbingan Konseling (BK)',
                    content:
                        '• Pengumpulan tugas, ujian, dan portofolio pembelajaran harus menjunjung tinggi kejujuran akademik dan orisinalitas karya.\n'
                        '• Fitur Bimbingan Konseling (BK) disediakan sebagai sarana pendampingan psikologis, akademik, dan pengembangan karakter siswa. Siswa dan Guru BK wajib menjaga integritas dan kerahasiaan komunikasi konseling sesuai kode etik profesi konseling.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '5',
                    title: 'Modul Lapor Sarpras & Komplain Kesiswaan',
                    content:
                        'Laporan fasilitas rusak atau pengaduan kesiswaan yang dikirimkan harus memuat informasi faktual dan dapat dipertanggungjawabkan.\n\n'
                        '• Pengguna dilarang mengunggah konten yang mengandung unsur fitnah, pornografi, ujaran kebencian, pelecehan, atau konten yang melanggar hukum Republik Indonesia.\n'
                        '• Pengelola sarpras dan kesiswaan berhak menolak atau memvalidasi keabsahan laporan yang diajukan.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '6',
                    title: 'Hak Kekayaan Intelektual (HAKI)',
                    content:
                        'Seluruh sistem, kode program, antarmuka grafis (UI), desain logo, merek dagang, basis data, dan dokumentasi terkait Aplikasi Anise merupakan hak kekayaan intelektual eksklusif pengembang (Helvetecha) dan mitra institusi sekolah. Pengguna dilarang keras membongkar kode sumber (reverse engineering), menduplikasi, atau mendistribusikan ulang aplikasi tanpa persetujuan tertulis resmi.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '7',
                    title: 'Ketersediaan Layanan & Batasan Tanggung Jawab',
                    content:
                        'Pengembang berupaya maksimal menjaga ketersediaan server dan sistem beroperasi 24/7. Namun demikian, pengembang tidak bertanggung jawab atas gangguan layanan yang disebabkan oleh keadaan kahar (force majeure), gangguan koneksi internet penyedia layanan seluler pengguna, atau pemeliharaan berkala infrastruktur server.',
                  ),
                  SizedBox(height: 16.h(context)),
                  _buildSectionCard(
                    context: context,
                    number: '8',
                    title: 'Perubahan Syarat & Ketentuan',
                    content:
                        'Pengembang berhak memperbarui Syarat & Ketentuan ini sewaktu-waktu guna mematuhi regulasi perundang-undangan dan kebijakan toko aplikasi (Google Play Store). Setiap revisi penting akan diinformasikan melalui pembaruan aplikasi.',
                  ),
                  SizedBox(height: 24.h(context)),
                  _buildFooterInfo(context),
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
                Text('Syarat & Ketentuan', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                Text('Terms of Service Aplikasi Anise Sekolah', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
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
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.scroll(PhosphorIconsStyle.fill), color: AppColors.primary, size: 36.w(context)),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ketentuan Penggunaan Resmi',
                  style: AppTextStyles.titleMedium(context, color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Terakhir diperbarui: Oktober 2026\nBerlaku untuk seluruh civitas institusi sekolah.',
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
    required String number,
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
                width: 28.w(context),
                height: 28.w(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8.w(context)),
                ),
                child: Text(
                  number,
                  style: AppTextStyles.labelMedium(context, color: AppColors.onSecondary).copyWith(fontWeight: FontWeight.bold),
                ),
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

  Widget _buildFooterInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      alignment: Alignment.center,
      child: Text(
        'Anise App © 2026 Helvetecha Group.\nSeluruh hak cipta dilindungi undang-undang.',
        style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.5)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
