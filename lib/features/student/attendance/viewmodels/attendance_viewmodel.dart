import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/attendance_repository.dart';
import '../../../../core/utils/base_state.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/websocket_service.dart';
import '../../../../core/ble/ble_service.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());
final webSocketServiceProvider = Provider((ref) => WebSocketService());
final bleServiceProvider = Provider((ref) => BleService());

final attendanceViewModelProvider = NotifierProvider<AttendanceViewModel, BaseState<String>>(() {
  return AttendanceViewModel();
});

class AttendanceViewModel extends Notifier<BaseState<String>> {
  late AttendanceRepository _repository;
  late WebSocketService _wsService;
  late BleService _bleService;
  
  Timer? _heartbeatTimer;
  String? _currentSessionId;

  @override
  BaseState<String> build() {
    _repository = ref.read(attendanceRepositoryProvider);
    _wsService = ref.read(webSocketServiceProvider);
    _bleService = ref.read(bleServiceProvider);
    
    ref.onDispose(() {
      _heartbeatTimer?.cancel();
      _currentSessionId = null;
      _wsService.disconnect();
      _bleService.stopScanning();
    });

    _initListeners();
    return BaseState<String>(status: ViewState.initial);
  }

  void _initListeners() {
    // 1. WebSocket Dinleyicisi
    _wsService.onSessionStarted = (data) {
      final sessionId = data['sessionId'];
      if (sessionId != null && _currentSessionId == null) {
        startCheckin(sessionId);
      }
    };
    _wsService.connect();

    // 2. BLE Tarama Dinleyicisi
    _bleService.onBeaconFound = (sessionId) {
      if (_currentSessionId == null) {
        startCheckin(sessionId);
      }
    };
    
    _bleService.onSignalLost = () {
      reportSignalLost();
    };

    _bleService.startScanning();
  }

  Future<void> startCheckin(String sessionId) async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.checkin(sessionId);
    
    if (result is ApiSuccess<bool>) {
      _currentSessionId = sessionId;
      state = state.copyWith(status: ViewState.success, data: sessionId); // Check-in başarılı
      _startHeartbeatLoop(sessionId);
    } else if (result is ApiError<bool>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }

  void _startHeartbeatLoop(String sessionId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final result = await _repository.sendHeartbeat(sessionId);
      if (result is ApiError<bool>) {
        // print('Heartbeat Error: ${result.message}');
      }
    });
  }

  Future<void> reportSignalLost() async {
    if (_currentSessionId != null) {
       await _repository.signalLost(_currentSessionId!);
       _heartbeatTimer?.cancel();
       state = state.copyWith(status: ViewState.error, errorMessage: 'Sinyal koptu. (Grace Period)');
    }
  }
}
