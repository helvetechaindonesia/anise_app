class ScheduleModel {
  final String id;
  final String subjectName;
  final String className;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  ScheduleModel({
    required this.id,
    required this.subjectName,
    required this.className,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      subjectName: json['subject']?['name'] ?? 'Unknown Subject',
      className: json['school_class']?['name'] ?? 'Unknown Class',
      dayOfWeek: json['day_of_week'] ?? 1,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}
