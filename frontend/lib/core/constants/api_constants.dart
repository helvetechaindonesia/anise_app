class ApiConstants {
  // Gunakan 'https://api.helvetecha.tech/api' untuk server production
  static const String baseUrl = 'https://api.helvetecha.tech/api';
  
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
}
