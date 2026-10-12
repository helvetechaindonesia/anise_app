import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

HttpClientAdapter getAdapter() {
  return IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );
}
