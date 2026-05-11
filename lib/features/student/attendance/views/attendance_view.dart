import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/attendance_viewmodel.dart';
import '../../../../core/utils/base_state.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceView extends ConsumerStatefulWidget {
  const AttendanceView({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends ConsumerState<AttendanceView> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Yoklama')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildStatusCard(attendanceState, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BaseState state, ThemeData theme) {
    if (state.status == ViewState.initial) {
      return _StatusCard(
        key: const ValueKey('initial'),
        icon: Icons.radar,
        color: Colors.blueAccent,
        title: 'Aranıyor...',
        subtitle: 'Hocanın yoklamayı başlatması bekleniyor.',
        isPulsing: true,
      );
    } else if (state.status == ViewState.loading) {
      return _StatusCard(
        key: const ValueKey('loading'),
        icon: Icons.sync,
        color: Colors.orange,
        title: 'Bağlanıyor...',
        subtitle: 'Check-in işlemi yapılıyor, lütfen bekleyin.',
        isPulsing: true,
      );
    } else if (state.status == ViewState.success) {
      return _StatusCard(
        key: const ValueKey('success'),
        icon: Icons.check_circle_outline,
        color: theme.colorScheme.secondary,
        title: 'Derstesiniz!',
        subtitle: 'Yoklamaya katıldınız. Uygulamayı kapatmayın, oturum arka planda korunuyor.\n\nOturum: ${state.data}',
        isPulsing: false,
      );
    } else {
      return _StatusCard(
        key: const ValueKey('error'),
        icon: Icons.error_outline,
        color: Colors.redAccent,
        title: 'Bağlantı Koptu!',
        subtitle: state.errorMessage ?? 'Bir hata oluştu.',
        isPulsing: false,
      );
    }
  }
}

class _StatusCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isPulsing;

  const _StatusCard({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isPulsing,
  }) : super(key: key);

  @override
  State<_StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<_StatusCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.isPulsing
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_controller.value * 0.1),
                        child: child,
                      );
                    },
                    child: Icon(widget.icon, size: 100, color: widget.color),
                  )
                : Icon(widget.icon, size: 100, color: widget.color),
            const SizedBox(height: 32),
            Text(
              widget.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: widget.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
