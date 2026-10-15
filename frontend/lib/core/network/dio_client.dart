import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../utils/shared_prefs.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'adapter/dio_adapter_stub.dart'
    if (dart.library.html) 'adapter/dio_adapter_web.dart'
    if (dart.library.io) 'adapter/dio_adapter_io.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 300),
    receiveTimeout: const Duration(seconds: 300),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SharedPrefs.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final userId = await SharedPrefs.getUserId();
        if (userId != null && userId.isNotEmpty) {
          options.headers['X-User-Id'] = userId;
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response != null &&
            e.requestOptions.path != ApiConstants.loginEndpoint &&
            e.requestOptions.path != ApiConstants.sessionStatusEndpoint) {
          final data = e.response?.data;
          if (data is Map) {
            final code = data['code']?.toString();
            final message = data['message']?.toString();
            if (code == 'ACCOUNT_FROZEN' || code == 'CREDENTIALS_CHANGED' || code == 'ACCOUNT_DELETED') {
              handleSessionTermination(code: code!, message: message);
            }
          }
        }
        return handler.next(e);
      },
    ),
  );

  // Gunakan adapter yang berbeda tergantung platform (Web atau Mobile/Desktop)
  dio.httpClientAdapter = getAdapter();

  return dio;
});
