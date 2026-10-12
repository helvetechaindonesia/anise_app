import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

HttpClientAdapter getAdapter() {
  return BrowserHttpClientAdapter();
}
