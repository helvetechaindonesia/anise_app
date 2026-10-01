class ApiConstants {
  // Gunakan 127.0.0.1 untuk web/chrome lokal
  // Ubah ke 'http://10.0.2.2:8001/api' jika menggunakan emulator Android
  static const String baseUrl = 'http://192.168.1.7:8001/api';
  
  // Endpoint list
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';
}
