# Kablosuz Yoklama Sistemi — API Dokümantasyonu

**Base URL:** `http://178.104.33.193:3002`  
**Format:** JSON  
**Auth:** Bearer Token (JWT)

---

## AUTH

### Öğrenci Kaydı
```
POST /auth/register/student
```
**Body:**
```json
{
  "name": "Ali Veli",
  "email": "ali@ogr.inonu.edu.tr",
  "password": "123456",
  "studentNo": "20210001",
  "department": "Bilgisayar Mühendisliği"
}
```
> ⚠️ Email mutlaka `@ogr.inonu.edu.tr` ile bitmeli.

**Başarılı Yanıt (201):**
```json
{ "message": "Kayıt başarılı. E-postanıza doğrulama kodu gönderildi." }
```

---

### Hoca Kaydı
```
POST /auth/register/teacher
```
**Body:**
```json
{
  "name": "Prof. Ayşe Kaya",
  "email": "ayse.kaya@gmail.com",
  "password": "123456",
  "department": "Bilgisayar Mühendisliği"
}
```

**Başarılı Yanıt (201):**
```json
{ "message": "Kayıt başarılı. E-postanıza doğrulama kodu gönderildi." }
```

---

### E-posta Doğrulama
```
POST /auth/verify
```
**Body:**
```json
{
  "email": "ali@ogr.inonu.edu.tr",
  "code": "483921"
}
```
**Başarılı Yanıt (200):**
```json
{
  "message": "E-posta doğrulandı.",
  "user": {
    "id": "ogr_xxx",
    "name": "Ali Veli",
    "email": "ali@ogr.inonu.edu.tr",
    "role": "student",
    "student_no": "20210001",
    "department": "Bilgisayar Mühendisliği",
    "verified": true
  },
  "token": "eyJhbG..."
}
```
> 💡 Bu token'ı kaydet — diğer tüm isteklerde kullanılacak.

---

### Kodu Tekrar Gönder
```
POST /auth/resend-code
```
**Body:**
```json
{ "email": "ali@ogr.inonu.edu.tr" }
```

---

### Giriş
```
POST /auth/login
```
**Body:**
```json
{
  "email": "ali@ogr.inonu.edu.tr",
  "password": "123456"
}
```
**Başarılı Yanıt (200):**
```json
{
  "user": { "id": "ogr_xxx", "name": "Ali Veli", "role": "student", ... },
  "token": "eyJhbG..."
}
```

---

### Profil Bilgisi
```
GET /auth/me
Authorization: Bearer <token>
```
**Yanıt:**
```json
{
  "user": {
    "id": "ogr_xxx",
    "name": "Ali Veli",
    "email": "ali@ogr.inonu.edu.tr",
    "role": "student",
    "student_no": "20210001",
    "department": "Bilgisayar Mühendisliği",
    "verified": true
  }
}
```

---

## DERS YÖNETİMİ (HOCA)

> Tüm bu endpoint'ler `role: "teacher"` token gerektirir.

### Ders Oluştur
```
POST /api/courses
Authorization: Bearer <token>
```
**Body:**
```json
{
  "name": "Bilgisayar Ağları",
  "code": "BLM301",
  "description": "Ağ protokolleri ve güvenlik",
  "schedule": { "day": "Pazartesi", "time": "09:00" }
}
```
**Yanıt (201):**
```json
{
  "course": {
    "id": "3d45cc04-...",
    "teacher_id": "hoca_xxx",
    "name": "Bilgisayar Ağları",
    "code": "BLM301",
    "created_at": "2026-05-04T10:00:00.000Z"
  }
}
```

---

### Derslerimi Listele
```
GET /api/courses
Authorization: Bearer <token>
```
**Yanıt:**
```json
{
  "courses": [
    { "id": "3d45cc04-...", "name": "Bilgisayar Ağları", "code": "BLM301", ... }
  ]
}
```

---

### Derse Öğrenci Ekle (E-posta ile)
```
POST /api/courses/:courseId/students
Authorization: Bearer <token>
```
**Body:**
```json
{ "email": "ali@ogr.inonu.edu.tr" }
```
**Yanıt (201):**
```json
{
  "student": {
    "id": "ogr_xxx",
    "name": "Ali Veli",
    "email": "ali@ogr.inonu.edu.tr",
    "student_no": "20210001"
  }
}
```

---

### Dersteki Öğrencileri Listele
```
GET /api/courses/:courseId/students
Authorization: Bearer <token>
```
**Yanıt:**
```json
{
  "students": [
    { "id": "ogr_xxx", "name": "Ali Veli", "email": "ali@ogr.inonu.edu.tr", "student_no": "20210001" }
  ]
}
```

---

### Dersten Öğrenci Çıkar
```
DELETE /api/courses/:courseId/students/:studentId
Authorization: Bearer <token>
```

---

## YOKLAMA (HOCA)

### Yoklama Başlat
```
POST /api/sessions/start
Authorization: Bearer <token>
```
**Body:**
```json
{
  "courseId": "3d45cc04-...",
  "minDuration": 30,
  "gracePeriod": 5
}
```
> `minDuration`: Geçerli sayılmak için minimum sınıfta kalma süresi (dakika)  
> `gracePeriod`: Sinyal kesilince bekleme süresi (dakika, default 5)

**Yanıt (201):**
```json
{
  "sessionId": "abc123-...",
  "token": "eyJhbG..."
}
```
> 💡 `token` — BLE beacon'a ve WebSocket'e gömülür. Öğrencilere bu token iletilir.

---

### Anlık Katılım Listesi
```
GET /api/sessions/:sessionId/entries
Authorization: Bearer <token>
```
**Yanıt:**
```json
{
  "entries": [
    {
      "studentId": "ogr_xxx",
      "name": "Ali Veli",
      "studentNo": "20210001",
      "totalSeconds": 1200,
      "status": "KATILDI"
    },
    {
      "studentId": "ogr_yyy",
      "name": "Ayşe Er",
      "studentNo": "20210002",
      "totalSeconds": 0,
      "status": "KATILMADI"
    }
  ]
}
```
> `status` değerleri: `KATILDI` / `DEVAM_EDIYOR` / `KATILMADI`

---

### Yoklamayı Bitir
```
POST /api/sessions/:sessionId/end
Authorization: Bearer <token>
```
> Bitince tüm sonuçlar PostgreSQL'e kalıcı olarak kaydedilir.

---

## YOKLAMA (ÖĞRENCİ)

> Tüm bu endpoint'ler `role: "student"` token gerektirir.

### Giriş Kaydı Aç (Check-in)
```
POST /api/entry/checkin
Authorization: Bearer <token>
```
**Body:**
```json
{ "sessionId": "abc123-..." }
```
> BLE sinyali veya WebSocket ile `sessionId` alındıktan sonra çağrılır.

**Yanıt (201):**
```json
{
  "entry": {
    "studentId": "ogr_xxx",
    "entryAt": 1777900000000,
    "totalSeconds": 0
  }
}
```

---

### Heartbeat (Her 10 Saniyede Bir)
```
POST /api/entry/heartbeat
Authorization: Bearer <token>
```
**Body:**
```json
{ "sessionId": "abc123-..." }
```
**Yanıt:**
```json
{ "totalSeconds": 600 }
```
> ⚠️ Bu endpoint BLE sinyali algılandığı sürece her 10 saniyede bir çağrılmalı.

---

### Sinyal Kaybı Bildir
```
POST /api/entry/signal-lost
Authorization: Bearer <token>
```
**Body:**
```json
{ "sessionId": "abc123-..." }
```
> BLE sinyali kesilince çağrılır. Grace period (5 dk) başlar.

---

## ÖĞRENCİ PANELİ

### Kayıtlı Olduğum Dersler
```
GET /api/student/courses
Authorization: Bearer <token>
```
**Yanıt:**
```json
{
  "courses": [
    { "id": "3d45cc04-...", "name": "Bilgisayar Ağları", "code": "BLM301", ... }
  ]
}
```

---

### Bir Dersteki Katılım Geçmişim
```
GET /api/student/courses/:courseId/attendance
Authorization: Bearer <token>
```
**Yanıt:**
```json
{
  "attendance": [
    {
      "session_id": "abc123-...",
      "started_at": "2026-05-04T09:00:00.000Z",
      "ended_at": "2026-05-04T10:30:00.000Z",
      "total_seconds": 3240,
      "status": "KATILDI"
    },
    {
      "session_id": "def456-...",
      "started_at": "2026-05-06T09:00:00.000Z",
      "ended_at": "2026-05-06T10:30:00.000Z",
      "total_seconds": 0,
      "status": "KATILMADI"
    }
  ]
}
```

---

## WEBSOCKET

```
WS ws://178.104.33.193:3002/ws?token=<jwt>&sessionId=<id>
```

**Hoca bağlantısı** (canlı liste için):
```
ws://178.104.33.193:3002/ws?token=<hoca_token>&sessionId=<sessionId>
```

**Öğrenci bağlantısı** (BLE'siz push için):
```
ws://178.104.33.193:3002/ws?token=<ogrenci_token>
```

**Sunucudan gelen mesajlar:**

```json
// Yoklama başladı (öğrenciye)
{ "type": "SESSION_TOKEN", "sessionId": "abc123", "token": "eyJ...", "courseId": "3d45cc04" }

// Katılım güncellendi (hocaya)
{ "type": "ENTRY_UPDATE", "sessionId": "abc123", "studentId": "ogr_xxx", "totalSeconds": 600, "status": "KATILDI" }
```

---

## HATA KODLARI

| HTTP | Anlam |
|------|-------|
| 400 | Geçersiz istek / Eksik alan |
| 401 | Token yok veya geçersiz |
| 403 | Yetki yok (rol uyumsuz, doğrulanmamış hesap) |
| 404 | Kayıt bulunamadı |

---

## SAĞLIK KONTROLÜ
```
GET /health
```
```json
{ "ok": true, "ts": 1777900000000 }
```
