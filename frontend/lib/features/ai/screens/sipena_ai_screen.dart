import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/anise_app_bar.dart';
import '../../auth/providers/auth_provider.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class SipenaAiScreen extends ConsumerStatefulWidget {
  const SipenaAiScreen({super.key});

  @override
  ConsumerState<SipenaAiScreen> createState() => _SipenaAiScreenState();
}

class _SipenaAiScreenState extends ConsumerState<SipenaAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    'Halo Sipena! Apa saja fitur aplikasi ini?',
    'Bagaimana cara mengajukan izin ketidakhadiran?',
    'Apa saja 7 Kebiasaan Anak Indonesia Hebat (G7-KAIH)?',
    'Bantu buatkan draf ringkasan materi pelajaran',
  ];

  @override
  void initState() {
    super.initState();
    // Default greeting from Sipena AI
    _messages.add(
      ChatMessage(
        text: 'Halo! Saya **Sipena AI**, asisten cerdas Anise App. Ada yang bisa saya bantu terkait jadwal, presensi, kebiasaan G7-KAIH, atau materi sekolah hari ini? 😊',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? textToSend]) {
    final query = (textToSend ?? _messageController.text).trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: query,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulated LLM response
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      final reply = _generateAiResponse(query);

      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();
    });
  }

  String _generateAiResponse(String prompt) {
    final lower = prompt.toLowerCase();
    final user = ref.read(authProvider).user;
    final userName = user?.fullName ?? 'Sobat Anise';

    if (lower.contains('halo') || lower.contains('hai') || lower.contains('pagi') || lower.contains('siang')) {
      return 'Halo $userName! Semangat menjalani aktivitas sekolah hari ini. Ada hal yang ingin kamu tanyakan atau butuh panduan?';
    }

    if (lower.contains('izin') || lower.contains('ijin')) {
      return 'Untuk mengajukan perizinan:\n1. Buka menu **Ajukan Ijin** di Layanan Cepat.\n2. Tentukan jenis perizinan (Sakit/Izin/Dinas).\n3. Lampirkan foto surat dokter/keterangan.\n4. Tunggu verifikasi dari Wali Kelas atau Kepala Sekolah.';
    }

    if (lower.contains('g7') || lower.contains('kaih') || lower.contains('kebiasaan')) {
      return 'Gerakan 7 Kebiasaan Anak Indonesia Hebat (G7-KAIH) meliputi:\n1. Bangun Pagi\n2. Beribadah\n3. Berolahraga\n4. Makan Sehat & Bergizi\n5. Gemar Membaca\n6. Bermasyarakat & Gotong Royong\n7. Istirahat Tepat Waktu.\n\nKamu bisa mengisi dan memantau ketaatan pembiasaan ini setiap hari di modul **G7-KAIH**.';
    }

    if (lower.contains('jadwal') || lower.contains('kbm')) {
      return 'Jadwal pelajaran dapat kamu lihat secara real-time melalui tab **Jadwal** di navigasi bawah atau melalui ikon Jadwal di beranda.';
    }

    if (lower.contains('efile') || lower.contains('e-file') || lower.contains('berkas')) {
      return 'Modul **E-File** menampung seluruh berkas digital dan dokumen yang pernah kamu unggah di sistem Anise App agar aman dan mudah diunduh kembali kapan saja.';
    }

    return 'Terima kasih pertanyaannya! Sebagai asisten Sipena AI, saya siap membantu menjawab seputar kegiatan belajar mengajar, kedisiplinan, tugas, maupun administrasi sekolah kamu. Jangan ragu bertanya topik lainnya ya!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AniseAppBar(
        title: 'Sipena AI',
        actions: [
          IconButton(
            tooltip: 'Hapus Riwayat Chat',
            icon: Icon(
              PhosphorIcons.trash(PhosphorIconsStyle.bold),
              color: AppColors.onBackground,
              size: 20.w(context),
            ),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    text: 'Riwayat percakapan telah dibersihkan. Ada yang ingin kamu diskusikan lagi?',
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 16.h(context)),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Typing Indicator
            if (_isTyping)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 4.h(context)),
                child: Row(
                  children: [
                    Container(
                      width: 28.w(context),
                      height: 28.w(context),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.robot(PhosphorIconsStyle.fill),
                        size: 16.w(context),
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    Text(
                      'Sipena AI sedang mengetik...',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp(context),
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Prompts Chips
            if (_messages.length <= 2)
              Container(
                height: 42.h(context),
                margin: EdgeInsets.only(bottom: 8.h(context)),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                  itemCount: _quickPrompts.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w(context)),
                  itemBuilder: (context, index) {
                    final prompt = _quickPrompts[index];
                    return ActionChip(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w(context))),
                      label: Text(
                        prompt,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp(context),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () => _sendMessage(prompt),
                    );
                  },
                ),
              ),

            // Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h(context)),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32.w(context),
              height: 32.w(context),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Icon(
                PhosphorIcons.robot(PhosphorIconsStyle.fill),
                size: 18.w(context),
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8.w(context)),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w(context), vertical: 10.h(context)),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.w(context)),
                  topRight: Radius.circular(16.w(context)),
                  bottomLeft: Radius.circular(isUser ? 16.w(context) : 4.w(context)),
                  bottomRight: Radius.circular(isUser ? 4.w(context) : 16.w(context)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SelectableText(
                msg.text,
                style: GoogleFonts.outfit(
                  fontSize: 14.sp(context),
                  height: 1.4,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w(context)),
            Container(
              width: 32.w(context),
              height: 32.w(context),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.w(context)),
              ),
              child: Icon(
                PhosphorIcons.user(PhosphorIconsStyle.bold),
                size: 18.w(context),
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 10.h(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w(context)),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(24.w(context)),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.outfit(fontSize: 14.sp(context), color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Tanyakan sesuatu pada Sipena AI...',
                  hintStyle: GoogleFonts.outfit(fontSize: 13.sp(context), color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h(context)),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8.w(context)),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 44.w(context),
              height: 44.w(context),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22.w(context)),
              ),
              child: Icon(
                PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20.w(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
