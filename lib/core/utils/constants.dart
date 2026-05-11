class AppConstants {
  static const String baseUrl = 'http://178.104.33.193:3002';
  static const String wsUrl = 'ws://178.104.33.193:3002';

  // API Endpoints - Auth
  static const String registerStudent = '/auth/register/student';
  static const String verifyEmail = '/auth/verify';
  static const String resendCode = '/auth/resend-code';
  static const String login = '/auth/login';
  static const String getProfile = '/auth/me';

  // API Endpoints - Student Attendance
  static const String checkin = '/api/entry/checkin';
  static const String heartbeat = '/api/entry/heartbeat';
  static const String signalLost = '/api/entry/signal-lost';

  // API Endpoints - Student Courses
  static const String studentCourses = '/api/student/courses';
  static String studentCourseAttendance(String courseId) => '/api/student/courses/$courseId/attendance';
}
