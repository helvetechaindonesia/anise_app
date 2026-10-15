import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/shared_prefs.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEndpoint, data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] == 'success') {
        final data = response.data['data'];
        final token = data['access_token'];
        
        await SharedPrefs.setToken(token);
        if (data['user']?['id'] != null) {
          await SharedPrefs.setUserId(data['user']['id'].toString());
        }
        
        return UserModel.fromJson(data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error');
    }
  }

  Future<UserModel> me() async {
    try {
      final response = await _dio.get(ApiConstants.meEndpoint);

      if (response.data['status'] == 'success') {
        final user = UserModel.fromJson(response.data['data']);
        await SharedPrefs.setUserId(user.id);
        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get user info');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get user info');
      }
      throw Exception('Network error');
    }
  }

  /// Memeriksa status sesi pengguna secara real-time dan mengambil pembaruan profil
  Future<Map<String, dynamic>?> checkSessionStatus() async {
    try {
      final response = await _dio.get(ApiConstants.sessionStatusEndpoint);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return Map<String, dynamic>.from(e.response!.data as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logoutEndpoint);
    } catch (e) {
      // Ignored: we clear token anyway
    } finally {
      await SharedPrefs.clearToken();
    }
  }
}
