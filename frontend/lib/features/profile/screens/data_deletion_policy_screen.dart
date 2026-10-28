import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';

class DataDeletionPolicyScreen extends StatefulWidget {
  const DataDeletionPolicyScreen({super.key});

  @override
  State<DataDeletionPolicyScreen> createState() => _DataDeletionPolicyScreenState();
}

class _DataDeletionPolicyScreenState extends State<DataDeletionPolicyScreen> {
  final _nisNipController = TextEditingController();
  final _emailController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nisNipController.dispose();
    _emailController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitDeletionRequestViaWhatsApp() async {
    final nisNip = _nisNipController.text.trim();
    final email = _emailController.text.trim();
    final reason = _reasonController.text.trim();

    if (nisNip.isEmpty || email.isEmpty) {
      AniseFeedbackDialog.showWarning(
        context,
        title: 'Form Belum Lengkap',
        message: 'Mohon isi NIS/NIP dan email akun terdaftar Anda untuk memverifikasi permohonan penghapusan.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    const phone = ApiConstants.developerWhatsApp;
    final message = "Halo Tim Helpdesk & Data Privacy Helvetecha,\n\n"
        "Saya mengajukan PERMOHONAN PENGHAPUSAN AKUN & DATA PRIBADI pada aplikasi Anise dengan rincian berikut:\n\n"
        "• NIS/NIP/Username: $nisNip\n"
        "• Email Terdaftar: $email\n"
        "• Alasan / Keterangan: ${reason.isEmpty ? '-' : reason}\n\n"
        "Mohon bantuannya untuk memproses verifikasi dan penghapusan data akun saya sesuai Google Play Data Deletion Policy. Terima kasih!";

    final encodedMessage = Uri.encodeComponent(message);
    final nativeUri = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMessage');
    final universalUri = Uri.parse('https://wa.me/$phone?text=$encodedMessage');
    final webUri = Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage');

    try {
      bool launched = false;
      if (await canLaunchUrl(nativeUri)) {
        launched = await launchUrl(nativeUri);
      }
      if (!launched && await canLaunchUrl(universalUri)) {
        launched = await launchUrl(universalUri, mode: LaunchMode.externalApplication);
      }
      if (!launched && await canLaunchUrl(webUri)) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        AniseFeedbackDialog.showSuccess(
          context,
          title: 'Permohonan Terkirim',
          message: 'Permohonan penghapusan akun Anda telah diteruskan ke Tim Data Privacy via WhatsApp resmi developer. Tim kami akan memverifikasi permohonan dalam 1-3 hari kerja.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        AniseFeedbackDialog.showError(
          context,
          title: 'Gagal Membuka WhatsApp',
          message: 'Tidak dapat membuka aplikasi WhatsApp. Silakan hubungi langsung ke nomor +62 819-3131-5944.',
        );
      }
    }
  }

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
                  _buildPolicyOverviewCard(context),
                  SizedBox(height: 20.h(context)),
                  _buildFormCard(context),
                  SizedBox(height: 24.h(context)),
                  _buildFaqInfoCard(context),
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
                Text('Kebijakan Penghapusan Data', style: AppTextStyles.titleMedium(context, color: AppColors.onBackground)),
                Text('Google Play Account Deletion Requirement', style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.6))),
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
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.w(context)),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: AppColors.error, size: 36.w(context)),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hak Penghapusan Data Akun',
                  style: AppTextStyles.titleMedium(context, color: AppColors.error).copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'Sesuai ketentuan Google Play, pengguna memiliki hak meminta penghapusan akun beserta seluruh data pribadi terkait.',
                  style: AppTextStyles.labelSmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyOverviewCard(BuildContext context) {
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
          Text(
            'Ketentuan & Prosedur Penghapusan:',
            style: AppTextStyles.titleMedium(context, color: AppColors.onSurface).copyWith(fontSize: 15.w(context)),
          ),
          SizedBox(height: 12.h(context)),
          _buildBulletItem(
            context,
            'Data yang Dihapus Permanen:',
            'Kredensial login, embedding biometrik wajah, nomor telepon, riwayat chat/bimbingan konseling pribadi, dan sesi login aktif.',
          ),
          SizedBox(height: 8.h(context)),
          _buildBulletItem(
            context,
            'Data yang Dikecualikan untuk Arsip Hukum Sekolah:',
            'Buku induk nilai rapor, riwayat presensi resmi kedinasan, dan ijazah/sertifikat yang secara perundang-undangan pendidikan wajib diarsipkan oleh institusi sekolah.',
          ),
          SizedBox(height: 8.h(context)),
          _buildBulletItem(
            context,
            'Waktu Pemrosesan:',
            'Permohonan akan diverifikasi oleh Admin IT Sekolah dan Developer dalam waktu maksimal 3 hari kerja sejak pengajuan diterima.',
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(BuildContext context, String boldText, String normalText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4.h(context), right: 8.w(context)),
          child: Icon(PhosphorIcons.circle(PhosphorIconsStyle.fill), size: 6.w(context), color: AppColors.primary),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.85)).copyWith(height: 1.45),
              children: [
                TextSpan(text: '$boldText ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: normalText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w(context)),
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
              Icon(PhosphorIcons.userMinus(PhosphorIconsStyle.bold), color: AppColors.error, size: 22.w(context)),
              SizedBox(width: 10.w(context)),
              Text('Formulir Pengajuan Hapus Data', style: AppTextStyles.titleMedium(context, color: AppColors.onSurface)),
            ],
          ),
          SizedBox(height: 16.h(context)),
          Text('NIS / NIP / Username Akun *', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface)),
          SizedBox(height: 6.h(context)),
          TextField(
            controller: _nisNipController,
            decoration: InputDecoration(
              hintText: 'Contoh: 20261001 atau guru_bk01',
              hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 12.h(context)),
            ),
          ),
          SizedBox(height: 14.h(context)),
          Text('Email Terdaftar di Akun *', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface)),
          SizedBox(height: 6.h(context)),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Contoh: nama@sekolah.sch.id',
              hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 12.h(context)),
            ),
          ),
          SizedBox(height: 14.h(context)),
          Text('Alasan Permohonan (Opsional)', style: AppTextStyles.labelMedium(context, color: AppColors.onSurface)),
          SizedBox(height: 6.h(context)),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan alasan pengunduran diri / penghapusan data...',
              hintStyle: AppTextStyles.bodyMedium(context, color: AppColors.onSurface.withValues(alpha: 0.4)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w(context))),
              contentPadding: EdgeInsets.all(14.w(context)),
            ),
          ),
          SizedBox(height: 20.h(context)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitDeletionRequestViaWhatsApp,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 18.w(context),
                      height: 18.w(context),
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.bold), color: Colors.white, size: 20.w(context)),
              label: Text(
                _isSubmitting ? 'Memproses...' : 'Kirim Permohonan Hapus Data',
                style: AppTextStyles.labelLarge(context, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w(context))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.w(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.info(PhosphorIconsStyle.fill), color: AppColors.primary, size: 20.w(context)),
          SizedBox(width: 10.w(context)),
          Expanded(
            child: Text(
              'Selain melalui formulir ini, Anda juga dapat menghubungi tim Data Protection Officer secara langsung melalui email privacy@helvetecha.com dengan melampirkan bukti kepemilikan akun resmi.',
              style: AppTextStyles.bodySmall(context, color: AppColors.onBackground.withValues(alpha: 0.7)).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
