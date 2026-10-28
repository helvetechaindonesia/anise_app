enum UserRole {
  kepalaSekolah, 
  tataUsaha,
  bk,
  pengajar,
  siswa,
}

class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String? email;
  final String? phone;
  final String? address;
  final String? parentName;
  final String? uniqueId;
  final UserRole role;
  final bool isWaliKelas; 
  final bool isWaliAsuh;
  final List<String> tugasTambahan;
  final String? nis;
  final String? nip;
  final String? className;
  final String? gender;
  final String? religion;
  final String? avatar;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.email,
    this.phone,
    this.address,
    this.parentName,
    this.uniqueId,
    required this.role,
    this.isWaliKelas = false,
    this.isWaliAsuh = false,
    this.tugasTambahan = const [],
    this.nis,
    this.nip,
    this.className,
    this.gender,
    this.religion,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.siswa;
    switch (json['role_type']) {
      case 'KEPALA_SEKOLAH':
        parsedRole = UserRole.kepalaSekolah;
        break;
      case 'TATA_USAHA':
        parsedRole = UserRole.tataUsaha;
        break;
      case 'GURU_BK':
        parsedRole = UserRole.bk;
        break;
      case 'GURU':
        parsedRole = UserRole.pengajar;
        break;
      case 'SISWA':
        parsedRole = UserRole.siswa;
        break;
    }

    bool hasWaliKelas = json['is_wali_kelas'] == true || 
        (json['wali_kelas'] != null && (json['wali_kelas'] as List).isNotEmpty);
    bool hasWaliAsuh = json['guru_wali_students'] != null && (json['guru_wali_students'] as List).isNotEmpty;
    
    List<String> assignments = [];
    if (json['structural_assignments'] != null) {
      for (var assignment in json['structural_assignments']) {
        if (assignment['role_title'] != null) {
          assignments.add(assignment['role_title']);
        }
      }
    }

    final siswaProf = json['siswa_profile'] as Map<String, dynamic>?;
    final guruProf = json['guru_profile'] as Map<String, dynamic>?;
    final studentClass = json['student_class'] as Map<String, dynamic>?;

    String? parsedClassName;
    if (studentClass != null) {
      final grade = studentClass['grade_level']?.toString() ?? '';
      final name = studentClass['name']?.toString() ?? '';
      parsedClassName = '$grade $name'.trim();
    }
    if (parsedClassName == null || parsedClassName.isEmpty) {
      parsedClassName = json['class_name']?.toString();
    }
    if (parsedClassName == null || parsedClassName.isEmpty) {
      final c = siswaProf?['class'] as Map<String, dynamic>?;
      if (c != null) {
        final grade = c['grade_level']?.toString() ?? '';
        final name = c['name']?.toString() ?? '';
        parsedClassName = '$grade $name'.trim();
      }
    }

    final parsedNisn = siswaProf?['nisn']?.toString() ?? json['nisn']?.toString();
    final parsedNis = siswaProf?['nis']?.toString() ?? json['nis']?.toString();

    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      parentName: siswaProf?['parent_name']?.toString() ?? json['parent_name']?.toString(),
      uniqueId: parsedNisn ?? 
                guruProf?['nip_nuptk']?.toString() ?? 
                guruProf?['nip']?.toString() ?? 
                json['unique_id']?.toString() ?? 
                json['username']?.toString(),
      role: parsedRole,
      isWaliKelas: hasWaliKelas,
      isWaliAsuh: hasWaliAsuh,
      tugasTambahan: assignments,
      nis: parsedNis,
      nip: guruProf?['nip_nuptk']?.toString() ?? guruProf?['nip']?.toString() ?? json['nip']?.toString(),
      className: (parsedClassName != null && parsedClassName.isNotEmpty) ? parsedClassName : null,
      gender: json['gender']?.toString(),
      religion: json['religion']?.toString(),
      avatar: json['avatar']?.toString() ?? json['profile_picture']?.toString(),
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? parentName,
    String? uniqueId,
    UserRole? role,
    bool? isWaliKelas,
    bool? isWaliAsuh,
    List<String>? tugasTambahan,
    String? nis,
    String? nip,
    String? className,
    String? gender,
    String? religion,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      parentName: parentName ?? this.parentName,
      uniqueId: uniqueId ?? this.uniqueId,
      role: role ?? this.role,
      isWaliKelas: isWaliKelas ?? this.isWaliKelas,
      isWaliAsuh: isWaliAsuh ?? this.isWaliAsuh,
      tugasTambahan: tugasTambahan ?? this.tugasTambahan,
      nis: nis ?? this.nis,
      nip: nip ?? this.nip,
      className: className ?? this.className,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      avatar: avatar ?? this.avatar,
    );
  }
}

