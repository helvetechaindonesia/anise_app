import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../utils/shared_prefs.dart';
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
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors here if necessary
        return handler.next(e);
      },
    ),
  );

  // Gunakan adapter yang berbeda tergantung platform (Web atau Mobile/Desktop)
  dio.httpClientAdapter = getAdapter();

  return dio;
});
