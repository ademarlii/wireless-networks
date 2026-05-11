class CourseModel {
  final String id;
  final String name;
  final String code;

  CourseModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class AttendanceHistoryModel {
  final String sessionId;
  final String startedAt;
  final String? endedAt;
  final int totalSeconds;
  final String status;

  AttendanceHistoryModel({
    required this.sessionId,
    required this.startedAt,
    this.endedAt,
    required this.totalSeconds,
    required this.status,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryModel(
      sessionId: json['session_id'] ?? '',
      startedAt: json['started_at'] ?? '',
      endedAt: json['ended_at'],
      totalSeconds: json['total_seconds'] ?? 0,
      status: json['status'] ?? 'KATILMADI',
    );
  }
}
