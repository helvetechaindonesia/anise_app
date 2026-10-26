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
  final String? religion;

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
    this.religion,
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

    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      parentName: json['siswa_profile']?['parent_name'],
      uniqueId: json['siswa_profile']?['nisn']?.toString() ?? 
                json['guru_profile']?['nip_nuptk']?.toString() ?? 
                json['guru_profile']?['nip']?.toString() ?? 
                json['unique_id']?.toString() ?? 
                json['username']?.toString(),
      role: parsedRole,
      isWaliKelas: hasWaliKelas,
      isWaliAsuh: hasWaliAsuh,
      tugasTambahan: assignments,
      nis: json['siswa_profile']?['nis']?.toString(),
      nip: json['guru_profile']?['nip_nuptk']?.toString() ?? json['guru_profile']?['nip']?.toString(),
      className: json['siswa_profile']?['class']?['name']?.toString() ?? 'XII M2', // Provide fallback just in case
      religion: json['religion']?.toString(),
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
    String? religion,
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
      religion: religion ?? this.religion,
    );
  }
}

