import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/student_courses_viewmodel.dart';
import '../../../../core/utils/base_state.dart';
import 'course_attendance_history_view.dart';

class StudentCoursesView extends ConsumerWidget {
  const StudentCoursesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesState = ref.watch(studentCoursesViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Derslerim')),
      body: _buildBody(context, ref, coursesState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, BaseState coursesState) {
    if (coursesState.status == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (coursesState.status == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(coursesState.errorMessage ?? 'Bir hata oluştu', style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(studentCoursesViewModelProvider.notifier).loadCourses(),
              child: const Text('Tekrar Dene'),
            )
          ],
        ),
      );
    }

    final courses = coursesState.data ?? [];

    if (courses.isEmpty) {
      return const Center(
        child: Text('Henüz kayıtlı bir dersiniz yok.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(studentCoursesViewModelProvider.notifier).loadCourses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseAttendanceHistoryView(courseId: course.id, courseName: course.name),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.class_, color: Theme.of(context).primaryColor, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(course.code, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
