class ApiConstants {
  // Gunakan 'https://api.helvetecha.tech/api' untuk server production
  static const String baseUrl = 'https://api.helvetecha.tech/api';
  
  /// Base host URL tanpa path endpoint /api (Contoh: https://api.helvetecha.tech)
  static String get baseHost {
    if (baseUrl.endsWith('/api')) {
      return baseUrl.substring(0, baseUrl.length - 4);
    }
    if (baseUrl.endsWith('/api/')) {
      return baseUrl.substring(0, baseUrl.length - 5);
    }
    return baseUrl;
  }

  /// Helper universal untuk memformat path storage / avatar agar selalu valid
  static String formatStorageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return p;
    }
    final cleanPath = p.startsWith('/') ? p : '/$p';
    return '$baseHost$cleanPath';
  }
  
  // Endpoint list
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';
  static const String sessionStatusEndpoint = '/auth/session-status';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String developerContactEndpoint = '/dev/contact';
  
  // Kontak Developer / Helpdesk (Direct WhatsApp)
  static const String developerName = 'Helvetecha Group';
  static const String developerEmail = 'Helvetechaindonesia@gmail.com';
  static const String developerWhatsApp = '6281931315944';
  static const String developerSupportUrl = 'https://wa.me/6281931315944?text=Halo%20Tim%20Developer%20Helvetecha%2C%20saya%20butuh%20bantuan%20terkait%20aplikasi%20Anise.';
  
  // Tanggal Rilis Resmi Anise App (Batas paling awal riwayat/fitur tanggal di seluruh aplikasi)
  static final DateTime appReleaseDate = DateTime(2026, 11, 2);
}
