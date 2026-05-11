# Mobil Geliştirici Rehberi

Bu doküman Kişi 2 (Flutter öğrenci app) ve Kişi 3 (Flutter hoca app) için hazırlanmıştır.

---

## Genel Mimari

```
Hoca App (Kişi 3)          Öğrenci App (Kişi 2)
     │                            │
     │ 1. POST /sessions/start    │
     │──────────────────▶ API     │
     │◀── sessionId + token ──────│
     │                            │
     │ 2. BLE beacon yayınla      │ 3. BLE tara → sessionId + token al
     │   (token içinde)           │    veya WebSocket'ten token al
     │                            │
     │                            │ 4. POST /entry/checkin
     │                            │──────────────────▶ API
     │                            │
     │                            │ 5. Her 10sn: POST /entry/heartbeat
     │                            │──────────────────▶ API
     │                            │
     │ WS: ENTRY_UPDATE alır      │ Sinyal kesilince: POST /entry/signal-lost
     │ (anlık liste güncellenir)  │
     │                            │
     │ 6. POST /sessions/end      │
     │──────────────────▶ API     │
```

---

## KİŞİ 3 — HOCA UYGULAMASI

### Paketler
```yaml
dependencies:
  flutter_blue_plus: ^1.32.0   # BLE beacon yayını
  http: ^1.2.0                 # API istekleri
  web_socket_channel: ^2.4.0   # WebSocket canlı liste
  shared_preferences: ^2.2.0   # Token saklama
  flutter_secure_storage: ^9.0.0
```

---

### 1. Kayıt & Giriş Akışı

```dart
// Kayıt
final res = await http.post(
  Uri.parse('$baseUrl/auth/register/teacher'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'name': 'Prof. Ayşe',
    'email': 'ayse@gmail.com',     // geçici olarak her mail kabul
    'password': '123456',
    'department': 'Bilgisayar',
  }),
);

// Doğrulama kodu gir
final res = await http.post(
  Uri.parse('$baseUrl/auth/verify'),
  body: jsonEncode({'email': 'ayse@gmail.com', 'code': '483921'}),
);
final token = jsonDecode(res.body)['token'];
// token'ı flutter_secure_storage'a kaydet

// Giriş
final res = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  body: jsonEncode({'email': 'ayse@gmail.com', 'password': '123456'}),
);
final token = jsonDecode(res.body)['token'];
```

---

### 2. Ders Oluşturma

```dart
Future<Map> createCourse(String token) async {
  final res = await http.post(
    Uri.parse('$baseUrl/api/courses'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': 'Bilgisayar Ağları',
      'code': 'BLM301',
      'description': 'Ağ protokolleri dersi',
    }),
  );
  return jsonDecode(res.body)['course'];
}
```

---

### 3. Derse Öğrenci Ekleme

```dart
Future<void> addStudent(String token, String courseId, String studentEmail) async {
  await http.post(
    Uri.parse('$baseUrl/api/courses/$courseId/students'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'email': studentEmail}),
  );
}
```

---

### 4. Yoklama Başlatma

```dart
Future<Map> startSession(String token, String courseId) async {
  final res = await http.post(
    Uri.parse('$baseUrl/api/sessions/start'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'courseId': courseId,
      'minDuration': 30,   // dakika
      'gracePeriod': 5,    // dakika
    }),
  );
  final data = jsonDecode(res.body);
  // data['sessionId'] ve data['token'] döner
  return data;
}
```

---

### 5. BLE Beacon Yayını

```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Future<void> startBeacon(String sessionId, String sessionToken) async {
  // BLE advertise — sessionToken beacon payload'ına gömülür
  // flutter_blue_plus ile advertise desteği sınırlı,
  // alternatif: beacon_broadcast paketi kullanılabilir

  // Payload: sessionId'nin ilk 16 karakteri UUID olarak
  final uuid = sessionId.replaceAll('-', '').substring(0, 32);

  await FlutterBluePlus.startScan(); // tarama değil, yayın ayrı paket
  // beacon_broadcast:
  // BeaconBroadcast()
  //   .setUUID(uuid)
  //   .setMajorId(1)
  //   .setMinorId(1)
  //   .start();
}
```

> 💡 Alternatif: BLE zor ise sadece WebSocket token push yeterli. Öğrenci WebSocket üzerinden sessionId + token alır.

---

### 6. WebSocket — Canlı Katılım Listesi

```dart
import 'package:web_socket_channel/web_socket_channel.dart';

void connectWebSocket(String token, String sessionId) {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://178.104.33.193:3002/ws?token=$token&sessionId=$sessionId'),
  );

  channel.stream.listen((message) {
    final data = jsonDecode(message);

    if (data['type'] == 'ENTRY_UPDATE') {
      final studentId = data['studentId'];
      final totalSeconds = data['totalSeconds'];
      final status = data['status']; // KATILDI / DEVAM_EDIYOR
      // UI'yi güncelle
      setState(() { /* listeyi yenile */ });
    }
  });
}
```

---

### 7. Yoklamayı Bitirme

```dart
Future<void> endSession(String token, String sessionId) async {
  await http.post(
    Uri.parse('$baseUrl/api/sessions/$sessionId/end'),
    headers: {'Authorization': 'Bearer $token'},
  );
}
```

---

## KİŞİ 2 — ÖĞRENCİ UYGULAMASI

### Paketler
```yaml
dependencies:
  flutter_blue_plus: ^1.32.0    # BLE tarama
  geolocator: ^11.0.0           # GPS
  network_info_plus: ^4.1.0     # WiFi BSSID
  http: ^1.2.0
  web_socket_channel: ^2.4.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  permission_handler: ^11.0.0   # İzinler
```

---

### 1. Kayıt & Giriş

```dart
// Kayıt — email @ogr.inonu.edu.tr olmali
final res = await http.post(
  Uri.parse('$baseUrl/auth/register/student'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'name': 'Ali Veli',
    'email': 'ali@ogr.inonu.edu.tr',  // zorunlu
    'password': '123456',
    'studentNo': '20210001',
    'department': 'Bilgisayar',
  }),
);

// Doğrulama → token al → secure storage'a kaydet
```

---

### 2. İzinleri Al (Android & iOS)

```dart
// AndroidManifest.xml
// <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
// <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
// <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

// iOS Info.plist
// NSBluetoothAlwaysUsageDescription
// NSLocationWhenInUseUsageDescription

await Permission.bluetooth.request();
await Permission.bluetoothScan.request();
await Permission.location.request();
```

---

### 3. BLE Tarama — Hocanın Beacon'ını Bul

```dart
String? detectedSessionId;
String? detectedToken;

void startBLEScan() {
  FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));

  FlutterBluePlus.scanResults.listen((results) {
    for (ScanResult r in results) {
      // Hocanın beacon'ı belirli bir service UUID ile yayın yapar
      // Service data içinden sessionId parse edilir
      final serviceUuids = r.advertisementData.serviceUuids;
      if (serviceUuids.isNotEmpty) {
        detectedSessionId = parseSessionId(serviceUuids.first.toString());
        onBeaconFound(detectedSessionId!);
      }
    }
  });
}
```

> 💡 BLE çalışmazsa WebSocket ile aynı şeyi yap — sunucu token'ı öğrenciye WS üzerinden push eder.

---

### 4. WebSocket — BLE'siz Fallback

```dart
void connectStudentWebSocket(String token) {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://178.104.33.193:3002/ws?token=$token'),
  );

  channel.stream.listen((message) {
    final data = jsonDecode(message);

    if (data['type'] == 'SESSION_TOKEN') {
      // Hoca yoklama başlattı, token geldi
      final sessionId = data['sessionId'];
      final sessionToken = data['token'];
      checkin(token, sessionId); // hemen checkin yap
    }
  });
}
```

---

### 5. Check-in + Heartbeat Döngüsü

```dart
Timer? _heartbeatTimer;

Future<void> checkin(String token, String sessionId) async {
  // 1. Giriş kaydı aç
  final res = await http.post(
    Uri.parse('$baseUrl/api/entry/checkin'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'sessionId': sessionId}),
  );

  if (res.statusCode == 201) {
    // 2. Her 10 saniyede heartbeat gönder
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      sendHeartbeat(token, sessionId);
    });

    // 3. BLE sinyal kaybını izle
    _watchBLESignal(token, sessionId);
  }
}

Future<void> sendHeartbeat(String token, String sessionId) async {
  await http.post(
    Uri.parse('$baseUrl/api/entry/heartbeat'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'sessionId': sessionId}),
  );
}
```

---

### 6. Sinyal Kaybı Bildirme

```dart
void _watchBLESignal(String token, String sessionId) {
  FlutterBluePlus.scanResults.listen((results) {
    final hocaninBeaconu = results.any((r) => isTeacherBeacon(r));

    if (!hocaninBeaconu) {
      // Sinyal kesildi
      _heartbeatTimer?.cancel();
      signalLost(token, sessionId);
    }
  });
}

Future<void> signalLost(String token, String sessionId) async {
  await http.post(
    Uri.parse('$baseUrl/api/entry/signal-lost'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'sessionId': sessionId}),
  );
}
```

---

### 7. Katılım Geçmişi

```dart
Future<List> getAttendanceHistory(String token, String courseId) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/student/courses/$courseId/attendance'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return jsonDecode(res.body)['attendance'];
}

// Dönen veri:
// [
//   { "started_at": "2026-05-04T09:00:00Z", "total_seconds": 3240, "status": "KATILDI" },
//   { "started_at": "2026-05-06T09:00:00Z", "total_seconds": 0,    "status": "KATILMADI" },
// ]
```

---

### 8. Kayıtlı Derslerimi Göster

```dart
Future<List> getMyCourses(String token) async {
  final res = await http.get(
    Uri.parse('$baseUrl/api/student/courses'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return jsonDecode(res.body)['courses'];
}
```

---

## Token Saklama (Her İki App)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Kaydet
await storage.write(key: 'jwt_token', value: token);
await storage.write(key: 'user_role', value: 'student'); // veya 'teacher'

// Oku
final token = await storage.read(key: 'jwt_token');

// Sil (çıkış)
await storage.delete(key: 'jwt_token');
```

---

## Uygulama Akış Şeması

```
Uygulama açılır
    ↓
Token var mı? (secure storage)
    ├── EVET → GET /auth/me → Ana sayfa
    └── HAYIR → Login ekranı
                    ↓
              Kayıt / Giriş
                    ↓
              E-posta doğrulama
                    ↓
              Token al → kaydet
                    ↓
          role == teacher?
          ├── EVET → Hoca Ana Sayfa
          │           Derslerim / Yoklama başlat
          └── HAYIR → Öğrenci Ana Sayfa
                       Derslerim / Katılım geçmişi
                       BLE + WS dinle
```

---

## Önemli Notlar

1. **Her istekte** `Authorization: Bearer <token>` header'ı zorunlu (login ve kayıt hariç)
2. **Token süresi** 8 saat — süresi dolunca tekrar login yaptır
3. **Heartbeat 10 saniyede bir** — bu süre backend ile senkronize, değiştirme
4. **BLE çalışmazsa** WebSocket fallback kullan — her ikisini de implement et
5. **Uygulama arka plana geçse bile** heartbeat devam etmeli (background service)
6. **iOS'ta BLE arka plan** için `bluetooth-central` background mode açılmalı

---

## Base URL Sabiti (Her İki App)

```dart
const String baseUrl = 'http://178.104.33.193:3002';
const String wsUrl   = 'ws://178.104.33.193:3002';
```
