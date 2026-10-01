import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _tokenKey = 'auth_token';

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
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
