import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/colors.dart';

class ComplaintModel {
  final String id;
  final String? userId;
  final String category; // 'FASILITAS', 'BULLYING', 'ASPIRASI'
  final String title;
  final String description;
  final bool isAnonymous;
  final String? attachmentUrl;
  final String status; // 'PENDING', 'IN_PROGRESS', 'RESOLVED', 'REJECTED'
  final String? responseNote;
  final String? handledBy;
  final String? userName;
  final String? handlerName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    required this.id,
    this.userId,
    required this.category,
    required this.title,
    required this.description,
    this.isAnonymous = false,
    this.attachmentUrl,
    this.status = 'PENDING',
    this.responseNote,
    this.handledBy,
    this.userName,
    this.handlerName,
    this.createdAt,
    this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    // Parse user & handler
    String? uName;
    if (json['user'] is Map) {
      uName = json['user']['full_name'] as String?;
    }

    String? hName;
    if (json['handler'] is Map) {
      hName = json['handler']['full_name'] as String?;
    }

    DateTime? created;
    if (json['created_at'] != null) {
      created = DateTime.tryParse(json['created_at'].toString());
    }

    DateTime? updated;
    if (json['updated_at'] != null) {
      updated = DateTime.tryParse(json['updated_at'].toString());
    }

    final isAnon = json['is_anonymous'] == true ||
        json['is_anonymous'] == 1 ||
        json['is_anonymous'] == '1';

    return ComplaintModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      category: json['category']?.toString() ?? 'ASPIRASI',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isAnonymous: isAnon,
      attachmentUrl: json['attachment_url']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      responseNote: json['response_note']?.toString(),
      handledBy: json['handled_by']?.toString(),
      userName: isAnon ? 'Anonim' : uName,
      handlerName: hName,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'title': title,
      'description': description,
      'is_anonymous': isAnonymous,
      'attachment_url': attachmentUrl,
      'status': status,
      'response_note': responseNote,
      'handled_by': handledBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get categoryLabel {
    switch (category.toUpperCase()) {
      case 'FASILITAS':
        return 'Fasilitas Sekolah';
      case 'BULLYING':
        return 'Aduan Bullying';
      case 'ASPIRASI':
        return 'Aspirasi Siswa';
      default:
        return category;
    }
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Menunggu';
      case 'IN_PROGRESS':
        return 'Diproses';
      case 'RESOLVED':
        return 'Selesai';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.warning;
      case 'IN_PROGRESS':
        return AppColors.primary;
      case 'RESOLVED':
        return const Color(0xFF2E7D32); // Darker green for high contrast readability
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  Color get categoryColor {
    switch (category.toUpperCase()) {
      case 'BULLYING':
        return AppColors.error;
      case 'FASILITAS':
        return const Color(0xFFD97706); // Warm amber
      case 'ASPIRASI':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  String? get fullAttachmentUrl {
    if (attachmentUrl == null || attachmentUrl!.trim().isEmpty) {
      return null;
    }
    final url = attachmentUrl!.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final serverHost = ApiConstants.baseUrl.replaceAll('/api', '');
    final cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return '$serverHost/$cleanPath';
  }
}
