import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/complaint_model.dart';

class ComplaintFilter {
  final List<String>? categories;
  final String? status;
  final String? search;

  const ComplaintFilter({this.categories, this.status, this.search});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintFilter &&
          runtimeType == other.runtimeType &&
          categories?.join(',') == other.categories?.join(',') &&
          status == other.status &&
          search == other.search;

  @override
  int get hashCode => Object.hash(categories?.join(','), status, search);
}

final complaintsProvider =
    FutureProvider.autoDispose.family<List<ComplaintModel>, ComplaintFilter>(
        (ref, filter) async {
  final dio = ref.watch(dioProvider);
  final queryParams = <String, dynamic>{};

  if (filter.categories != null && filter.categories!.isNotEmpty) {
    queryParams['categories'] = filter.categories!.join(',');
  }
  if (filter.status != null && filter.status!.isNotEmpty) {
    queryParams['status'] = filter.status;
  }
  if (filter.search != null && filter.search!.trim().isNotEmpty) {
    queryParams['search'] = filter.search!.trim();
  }

  final response = await dio.get('/complaints', queryParameters: queryParams);
  if (response.data['status'] == 'success') {
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  throw Exception(response.data['message'] ?? 'Gagal memuat data laporan');
});

final studentReportsProvider =
    FutureProvider.autoDispose<List<ComplaintModel>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/complaints');
  if (response.data['status'] == 'success') {
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((item) => ComplaintModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  throw Exception(response.data['message'] ?? 'Gagal memuat data laporan');
});

final complaintServiceProvider = Provider((ref) => ComplaintService(ref));

class ComplaintService {
  final Ref _ref;
  ComplaintService(this._ref);

  Future<ComplaintModel> submitComplaint({
    required String category,
    required String title,
    required String description,
    bool isAnonymous = false,
    File? imageFile,
  }) async {
    final dio = _ref.read(dioProvider);
    final formData = FormData.fromMap({
      'category': category,
      'title': title,
      'description': description,
      'is_anonymous': isAnonymous ? 1 : 0,
    });

    if (imageFile != null) {
      formData.files.add(MapEntry(
        'attachment',
        await MultipartFile.fromFile(imageFile.path, filename: 'bukti_laporan.jpg'),
      ));
    }

    final response = await dio.post('/complaints', data: formData);
    if (response.data['status'] == 'success') {
      _ref.invalidate(studentReportsProvider);
      return ComplaintModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['message'] ?? 'Gagal mengirim laporan');
  }

  Future<void> updateStatus({
    required String complaintId,
    required String status,
    String? responseNote,
  }) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.put(
      '/complaints/$complaintId/status',
      data: {
        'status': status,
        if (responseNote != null) 'response_note': responseNote,
      },
    );
    if (response.data['status'] == 'success') {
      _ref.invalidate(studentReportsProvider);
    } else {
      throw Exception(response.data['message'] ?? 'Gagal memperbarui status laporan');
    }
  }
}
