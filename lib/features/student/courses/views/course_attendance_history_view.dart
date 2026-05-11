import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/student_courses_viewmodel.dart';
import '../../../../core/utils/base_state.dart';

class CourseAttendanceHistoryView extends ConsumerStatefulWidget {
  final String courseId;
  final String courseName;

  const CourseAttendanceHistoryView({
    Key? key,
    required this.courseId,
    required this.courseName,
  }) : super(key: key);

  @override
  ConsumerState<CourseAttendanceHistoryView> createState() => _CourseAttendanceHistoryViewState();
}

class _CourseAttendanceHistoryViewState extends ConsumerState<CourseAttendanceHistoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(courseAttendanceViewModelProvider.notifier).loadHistory(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(courseAttendanceViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.courseName)),
      body: _buildBody(context, ref, historyState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, BaseState historyState) {
    if (historyState.status == ViewState.initial || historyState.status == ViewState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyState.status == ViewState.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(historyState.errorMessage ?? 'Bir hata oluştu', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(courseAttendanceViewModelProvider.notifier).loadHistory(widget.courseId),
              child: const Text('Tekrar Dene'),
            )
          ],
        ),
      );
    }

    final records = historyState.data ?? [];

    if (records.isEmpty) {
      return const Center(child: Text('Bu ders için henüz yoklama kaydı bulunmamaktadır.', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(courseAttendanceViewModelProvider.notifier).loadHistory(widget.courseId),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final isAttended = record.status == 'KATILDI';
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAttended ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAttended ? Icons.check_circle : Icons.cancel,
                      color: isAttended ? Colors.green : Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAttended ? 'Katıldı' : 'Yok Yazıldı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isAttended ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Tarih: ${record.startedAt}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        if (isAttended)
                          Text('Derste Kalınan Süre: ${record.totalSeconds} saniye', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
