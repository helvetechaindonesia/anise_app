import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../../../main.dart';
import '../../../core/widgets/anise_feedback_dialog.dart';
import '../../../core/utils/shared_prefs.dart';

enum AuthStatus { initial, unauthenticated, authenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Menangani pemutusan sesi secara tegas & menampilkan dialog yang tidak bisa ditutup
void handleSessionTermination({
  required String code,
  String? message,
}) {
  final context = rootNavigatorKey.currentContext;
  if (context == null) return;

  if (code == 'ACCOUNT_FROZEN') {
    AniseFeedbackDialog.showSessionExpired(
      context,
      title: 'Akun Dibekukan',
      message: message ?? 'Akun Anda sedang dibekukan (freeze) oleh Administrator. Silakan hubungi Tata Usaha.',
      buttonText: 'Log Out',
      onAction: () async {
        await SharedPrefs.clearToken();
        rootNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  } else if (code == 'CREDENTIALS_CHANGED') {
    AniseFeedbackDialog.showSessionExpired(
      context,
      title: 'Sesi Berakhir',
      message: message ?? 'Email atau kredensial akun Anda telah diubah oleh Administrator. Silakan masuk kembali menggunakan data terbaru.',
      buttonText: 'Login',
      onAction: () async {
        await SharedPrefs.clearToken();
        rootNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  } else if (code == 'ACCOUNT_DELETED') {
    AniseFeedbackDialog.showSessionExpired(
      context,
      title: 'Akun Dihapus',
      message: message ?? 'Akun Anda telah dinonaktifkan atau dihapus dari sistem oleh Administrator.',
      buttonText: 'Log Out',
      onAction: () async {
        await SharedPrefs.clearToken();
        rootNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  } else {
    AniseFeedbackDialog.showSessionExpired(
      context,
      title: 'Sesi Berakhir',
      message: message ?? 'Sesi Anda telah kedaluwarsa. Silakan masuk kembali.',
      buttonText: 'Login',
      onAction: () async {
        await SharedPrefs.clearToken();
        rootNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  Timer? _heartbeatTimer;

  AuthNotifier(this._authService) : super(AuthState(status: AuthStatus.initial)) {
    checkAuth();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // Jalankan pengecekan denyut sesi setiap 3 detik
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 3), (_) => _syncSessionStatus());
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _syncSessionStatus() async {
    if (state.status != AuthStatus.authenticated) {
      _stopHeartbeat();
      return;
    }

    final res = await _authService.checkSessionStatus();
    if (res == null) return;

    final code = res['code']?.toString();
    final message = res['message']?.toString();

    // 1. Sesi dihentikan karena Freeze, Kredensial Berubah, atau Akun Dihapus
    if (code == 'ACCOUNT_FROZEN' || code == 'CREDENTIALS_CHANGED' || code == 'ACCOUNT_DELETED') {
      _stopHeartbeat();
      state = AuthState(status: AuthStatus.unauthenticated);
      handleSessionTermination(code: code!, message: message);
      return;
    }

    // 2. Sesi Aktif: Sinkronisasi data profil secara realtime (Nama, WhatsApp/Phone, Alamat)
    if (code == 'SESSION_ACTIVE' && res['data']?['user'] != null) {
      final userData = res['data']['user'] as Map<String, dynamic>;
      final currentUser = state.user;
        final updatedName = userData['full_name']?.toString() ?? currentUser.fullName;
        final updatedEmail = userData['email']?.toString() ?? currentUser.email;
        final updatedPhone = userData['phone']?.toString();
        final updatedAddress = userData['address']?.toString();
        final updatedAvatar = userData['avatar']?.toString() ?? userData['profile_picture']?.toString() ?? currentUser.avatar;
        final updatedClassName = userData['class_name']?.toString() ?? currentUser.className;
        final updatedNis = userData['nis']?.toString() ?? currentUser.nis;
        final updatedNip = userData['nip']?.toString() ?? currentUser.nip;
        final updatedUniqueId = userData['nisn']?.toString() ?? userData['unique_id']?.toString() ?? currentUser.uniqueId;

        if (currentUser.fullName != updatedName ||
            currentUser.email != updatedEmail ||
            currentUser.phone != updatedPhone ||
            currentUser.address != updatedAddress ||
            currentUser.avatar != updatedAvatar ||
            currentUser.className != updatedClassName ||
            currentUser.nis != updatedNis ||
            currentUser.nip != updatedNip ||
            currentUser.uniqueId != updatedUniqueId) {
          state = state.copyWith(
            user: currentUser.copyWith(
              fullName: updatedName,
              email: updatedEmail,
              phone: updatedPhone,
              address: updatedAddress,
              avatar: updatedAvatar,
              className: updatedClassName,
              nis: updatedNis,
              nip: updatedNip,
              uniqueId: updatedUniqueId,
            ),
          );
        }
      }
    }
  }

  Future<void> checkAuth() async {
    try {
      final token = await SharedPrefs.getToken();
      if (token == null || token.isEmpty) {
        state = AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      
      final user = await _authService.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      _startHeartbeat();
    } catch (e) {
      _stopHeartbeat();
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);
      
      final user = await _authService.login(email, password);
      
      state = state.copyWith(status: AuthStatus.authenticated, user: user, errorMessage: null);
      _startHeartbeat();
      return true;
    } catch (e) {
      _stopHeartbeat();
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: cleanMessage);
      return false;
    }
  }

  Future<void> logout() async {
    _stopHeartbeat();
    try {
      await _authService.logout();
    } finally {
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }
}
