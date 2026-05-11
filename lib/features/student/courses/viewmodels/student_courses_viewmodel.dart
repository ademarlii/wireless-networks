import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/student_courses_repository.dart';
import '../models/course_models.dart';
import '../../../../core/utils/base_state.dart';
import '../../../../core/network/api_result.dart';

final studentCoursesRepositoryProvider = Provider((ref) => StudentCoursesRepository());

final studentCoursesViewModelProvider = NotifierProvider<StudentCoursesViewModel, BaseState<List<CourseModel>>>(() {
  return StudentCoursesViewModel();
});

class StudentCoursesViewModel extends Notifier<BaseState<List<CourseModel>>> {
  late StudentCoursesRepository _repository;

  @override
  BaseState<List<CourseModel>> build() {
    _repository = ref.read(studentCoursesRepositoryProvider);
    // Future.microtask is used to allow the build to finish returning the initial state
    Future.microtask(() => loadCourses());
    return BaseState(status: ViewState.loading);
  }

  Future<void> loadCourses() async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.getMyCourses();
    
    if (result is ApiSuccess<List<CourseModel>>) {
      state = state.copyWith(status: ViewState.success, data: result.data);
    } else if (result is ApiError<List<CourseModel>>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }
}

// Attendance History ViewModel (Course specific)
final courseAttendanceViewModelProvider = NotifierProvider<CourseAttendanceViewModel, BaseState<List<AttendanceHistoryModel>>>(() {
  return CourseAttendanceViewModel();
});

class CourseAttendanceViewModel extends Notifier<BaseState<List<AttendanceHistoryModel>>> {
  late StudentCoursesRepository _repository;

  @override
  BaseState<List<AttendanceHistoryModel>> build() {
    _repository = ref.read(studentCoursesRepositoryProvider);
    return BaseState(status: ViewState.initial);
  }

  Future<void> loadHistory(String courseId) async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.getCourseAttendance(courseId);
    
    if (result is ApiSuccess<List<AttendanceHistoryModel>>) {
      state = state.copyWith(status: ViewState.success, data: result.data);
    } else if (result is ApiError<List<AttendanceHistoryModel>>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }
}
