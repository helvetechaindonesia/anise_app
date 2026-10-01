class HabitModel {
  final String id;
  final String name; // We'll keep the property as name in dart but map it from title
  final String category;

  HabitModel({
    required this.id,
    required this.name,
    required this.category,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] ?? '',
      name: json['title'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

class StudentHabitLogModel {
  final String id;
  final String studentName;
  final String habitName;
  final String status;
  final String? notes;
  final String? photoPath;

  StudentHabitLogModel({
    required this.id,
    required this.studentName,
    required this.habitName,
    required this.status,
    this.notes,
    this.photoPath,
  });

  factory StudentHabitLogModel.fromJson(Map<String, dynamic> json) {
    return StudentHabitLogModel(
      id: json['id'] ?? '',
      studentName: json['student']?['full_name'] ?? 'Unknown Student',
      habitName: json['habit']?['name'] ?? 'Unknown Habit',
      status: json['status'] ?? 'PENDING',
      notes: json['notes'],
      photoPath: json['photo_path'],
    );
  }
}
