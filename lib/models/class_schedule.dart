class ClassSchedule {
  final String id;
  final String subject;
  final String teacher;
  final DateTime startTime;
  final DateTime endTime;
  final String day;

  ClassSchedule({
    required this.id,
    required this.subject,
    required this.teacher,
    required this.startTime,
    required this.endTime,
    required this.day,
  });

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      id: json['id'] as String,
      subject: json['subject'] as String,
      teacher: json['teacher'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      day: json['day'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'teacher': teacher,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'day': day,
    };
  }
}
