import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _tokenKey = 'auth_token';
  static const String _loginTimeKey = 'login_timestamp';
  static const int _sessionValidityDays = 7;

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;

    final loginTime = prefs.getInt(_loginTimeKey);
    if (loginTime != null) {
      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final difference = DateTime.now().difference(loginDate);
      // Jika sesi melebihi 7 hari, bersihkan sesi
      if (difference.inDays >= _sessionValidityDays) {
        await clearToken();
        return null;
      }
    }
    return token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_loginTimeKey);
  }

  static const String _rememberMeKey = 'remember_me';
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';

  static Future<void> saveCredentials(String username, String password, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
    if (remember) {
      await prefs.setString(_usernameKey, username);
      await prefs.setString(_passwordKey, password);
    } else {
      await prefs.remove(_usernameKey);
      await prefs.remove(_passwordKey);
    }
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'rememberMe': prefs.getBool(_rememberMeKey) ?? false,
      'username': prefs.getString(_usernameKey) ?? '',
      'password': prefs.getString(_passwordKey) ?? '',
    };
  }
}
