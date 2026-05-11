import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/constants.dart';
import '../models/course_models.dart';

class StudentCoursesRepository {
  final ApiClient _apiClient = ApiClient();

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'Bilinmeyen bir hata oluştu.';
    } catch (_) {
      return 'Sunucu ile iletişim kurulamadı.';
    }
  }

  Future<ApiResult<List<CourseModel>>> getMyCourses() async {
    try {
      final response = await _apiClient.get(AppConstants.studentCourses);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coursesList = data['courses'] as List;
        final courses = coursesList.map((e) => CourseModel.fromJson(e)).toList();
        return ApiSuccess(courses);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return const ApiError('Dersler alınamadı. İnternet bağlantınızı kontrol edin.');
    }
  }

  Future<ApiResult<List<AttendanceHistoryModel>>> getCourseAttendance(String courseId) async {
    try {
      final response = await _apiClient.get(AppConstants.studentCourseAttendance(courseId));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final attendanceList = data['attendance'] as List;
        final history = attendanceList.map((e) => AttendanceHistoryModel.fromJson(e)).toList();
        return ApiSuccess(history);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return const ApiError('Yoklama geçmişi alınamadı.');
    }
  }
}
