import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/base_state.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/student/attendance/views/attendance_view.dart';
import 'features/student/courses/views/student_courses_view.dart';
import 'core/utils/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return MaterialApp(
      title: 'Kablosuz Yoklama Sistemi',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _getHomeWidget(authState),
    );
  }

  Widget _getHomeWidget(BaseState authState) {
    if (authState.status == ViewState.loading && authState.data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (authState.data != null) {
      return _HomeDispatcher();
    }

    return const LoginView();
  }
}

class _HomeDispatcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authViewModelProvider).data;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Merhaba,\n${user?.name ?? ""}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${user?.department ?? "Bölüm Bilgisi Yok"}',
                style: TextStyle(fontSize: 16, color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: _DashboardCard(
                      title: 'Canlı Yoklama',
                      icon: Icons.sensors,
                      color: theme.primaryColor,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceView())),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DashboardCard(
                      title: 'Derslerim',
                      icon: Icons.collections_bookmark,
                      color: theme.colorScheme.secondary,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentCoursesView())),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
