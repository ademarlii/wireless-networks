import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Function(String sessionId)? onBeaconFound;
  Function()? onSignalLost;
  
  bool _isScanning = false;
  Timer? _signalLostTimer;

  Future<void> startScanning() async {
    if (_isScanning) return;
    
    // Tarama başlatılıyor
    await FlutterBluePlus.startScan(timeout: const Duration(days: 1)); // Sürekli tarama
    _isScanning = true;

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      bool teacherBeaconFoundInThisBatch = false;

      for (ScanResult r in results) {
        // Hoca beacon'ını Service UUID'den tanıyoruz. 
        // Dokümantasyonda sessionId'nin ilk 32 karakteri (veya benzeri) kullanılıyor.
        final serviceUuids = r.advertisementData.serviceUuids;
        if (serviceUuids.isNotEmpty) {
          // Örnek: İlk UUID'yi sessionId olarak parse et.
          String parsedSessionId = serviceUuids.first.toString().replaceAll('-', '');
          
          if (onBeaconFound != null) {
            onBeaconFound!(parsedSessionId);
            teacherBeaconFoundInThisBatch = true;
          }
        }
      }

      // Sinyal kaybı mantığı (Basitçe son 10 saniyede beacon hiç görülmediyse kopmuş sayarız)
      if (teacherBeaconFoundInThisBatch) {
        _resetSignalLostTimer();
      }
    });
  }

  void _resetSignalLostTimer() {
    _signalLostTimer?.cancel();
    _signalLostTimer = Timer(const Duration(seconds: 15), () {
      if (onSignalLost != null) onSignalLost!();
    });
  }

  void stopScanning() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _signalLostTimer?.cancel();
    _isScanning = false;
  }
}
