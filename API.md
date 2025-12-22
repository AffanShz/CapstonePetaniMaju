# 🔌 Dokumentasi API - Petani Maju

Dokumentasi lengkap tentang API dan service yang digunakan pada aplikasi Petani Maju.

---

## 📑 Daftar Isi

- [OpenWeatherMap API](#openweathermap-api)
- [OpenStreetMap Nominatim](#openstreetmap-nominatim)
- [Supabase API](#supabase-api)

---

## 🌤️ OpenWeatherMap API

API untuk mendapatkan data cuaca real-time dan forecast.

### Konfigurasi

| Property | Value |
|----------|-------|
| Base URL | `https://api.openweathermap.org/data/2.5` |
| API Key | `51...........................` |
| Default Coordinates | Lat: `-6.5716`, Lon: `107.7587` |
| Units | `metric` (Celsius) |
| Language | `id` (Indonesia) |

---

### 1. Current Weather

Mendapatkan data cuaca terkini.

#### Endpoint
```
GET /weather
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lat` | double | Yes | Latitude lokasi |
| `lon` | double | Yes | Longitude lokasi |
| `appid` | string | Yes | API key |
| `units` | string | No | Unit suhu (`metric`, `imperial`, `standard`) |
| `lang` | string | No | Bahasa response |

#### Request Example
```
GET https://api.openweathermap.org/data/2.5/weather?lat=-6.5716&lon=107.7587&appid=API_KEY&units=metric&lang=id
```

#### Response Example
```json
{
  "coord": {
    "lon": 107.7587,
    "lat": -6.5716
  },
  "weather": [
    {
      "id": 800,
      "main": "Clear",
      "description": "clear sky",
      "icon": "01d"
    }
  ],
  "main": {
    "temp": 28.5,
    "feels_like": 32.1,
    "temp_min": 27.0,
    "temp_max": 30.0,
    "pressure": 1010,
    "humidity": 75
  },
  "visibility": 10000,
  "wind": {
    "speed": 3.5,
    "deg": 180
  },
  "clouds": {
    "all": 10
  },
  "dt": 1702800000,
  "sys": {
    "country": "ID",
    "sunrise": 1702766400,
    "sunset": 1702812000
  },
  "timezone": 25200,
  "name": "Cianjur"
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `coord` | object | Koordinat lokasi |
| `weather` | array | Array kondisi cuaca |
| `weather[].main` | string | Kategori cuaca (Clear, Clouds, Rain, dll) |
| `weather[].description` | string | Deskripsi detail cuaca |
| `weather[].icon` | string | Kode ikon cuaca |
| `main.temp` | number | Suhu saat ini |
| `main.feels_like` | number | Suhu yang dirasakan |
| `main.humidity` | number | Kelembaban (%) |
| `main.pressure` | number | Tekanan udara (hPa) |
| `wind.speed` | number | Kecepatan angin (m/s) |
| `name` | string | Nama lokasi |

#### Service Implementation
```dart
// lib/data/datasources/weather_service.dart
Future<Map<String, dynamic>> fetchCurrentWeather({double? lat, double? lon}) async {
  final latitude = lat ?? this.lat;
  final longitude = lon ?? this.lon;
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=id'
  );
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load current weather');
  }
}
```

---

### 2. Weather Forecast

Mendapatkan forecast cuaca 5 hari / 3 jam.

#### Endpoint
```
GET /forecast
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lat` | double | Yes | Latitude lokasi |
| `lon` | double | Yes | Longitude lokasi |
| `appid` | string | Yes | API key |
| `units` | string | No | Unit suhu |
| `lang` | string | No | Bahasa response |

#### Request Example
```
GET https://api.openweathermap.org/data/2.5/forecast?lat=-6.5716&lon=107.7587&appid=API_KEY&units=metric&lang=id
```

#### Response Example
```json
{
  "cod": "200",
  "message": 0,
  "cnt": 40,
  "list": [
    {
      "dt": 1702803600,
      "main": {
        "temp": 28.5,
        "feels_like": 32.1,
        "temp_min": 27.0,
        "temp_max": 30.0,
        "pressure": 1010,
        "humidity": 75
      },
      "weather": [
        {
          "id": 800,
          "main": "Clear",
          "description": "clear sky",
          "icon": "01d"
        }
      ],
      "clouds": { "all": 10 },
      "wind": { "speed": 3.5, "deg": 180 },
      "visibility": 10000,
      "pop": 0.1,
      "dt_txt": "2024-12-17 12:00:00"
    }
    // ... 39 more entries (setiap 3 jam)
  ],
  "city": {
    "id": 1234567,
    "name": "Cianjur",
    "coord": { "lat": -6.5716, "lon": 107.7587 },
    "country": "ID",
    "timezone": 25200,
    "sunrise": 1702766400,
    "sunset": 1702812000
  }
}
```

#### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `cnt` | number | Jumlah forecast entries (max 40) |
| `list` | array | Array forecast per 3 jam |
| `list[].dt` | number | Unix timestamp |
| `list[].dt_txt` | string | Tanggal dan waktu dalam format string |
| `list[].pop` | number | Probability of precipitation (0-1) |
| `city` | object | Informasi kota |

#### Service Implementation
```dart
// lib/data/datasources/weather_service.dart
Future<Map<String, dynamic>> fetchForecast({double? lat, double? lon}) async {
  final latitude = lat ?? this.lat;
  final longitude = lon ?? this.lon;
  final url = Uri.parse(
    'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric&lang=id'
  );
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load forecast');
  }
}
```

---

## 🗺️ OpenStreetMap Nominatim

API untuk reverse geocoding (koordinat ke alamat).

### Konfigurasi

| Property | Value |
|----------|-------|
| Base URL | `https://nominatim.openstreetmap.org` |
| User-Agent | `PetaniMaju/1.0` |
| Language | `id` (Indonesia) |

> ⚠️ **Rate Limit**: Maksimal 1 request per detik. Tidak memerlukan API key.

---

### Reverse Geocoding

Mengkonversi koordinat menjadi alamat lengkap.

#### Endpoint
```
GET /reverse
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `format` | string | Yes | Format response (`json`, `xml`) |
| `lat` | double | Yes | Latitude |
| `lon` | double | Yes | Longitude |
| `addressdetails` | integer | No | Include address details (1 = yes) |
| `accept-language` | string | No | Bahasa response |

#### Request Example
```
GET https://nominatim.openstreetmap.org/reverse?format=json&lat=-6.5716&lon=107.7587&addressdetails=1&accept-language=id
```

#### Response Example
```json
{
  "place_id": 123456789,
  "licence": "Data © OpenStreetMap contributors",
  "osm_type": "way",
  "osm_id": 12345678,
  "lat": "-6.5716",
  "lon": "107.7587",
  "display_name": "Jalan Raya, Desa Contoh, Kecamatan Contoh, Kabupaten Cianjur, Jawa Barat, 43253, Indonesia",
  "address": {
    "road": "Jalan Raya",
    "village": "Desa Contoh",
    "district": "Kecamatan Contoh",
    "county": "Kabupaten Cianjur",
    "state": "Jawa Barat",
    "postcode": "43253",
    "country": "Indonesia",
    "country_code": "id"
  }
}
```

#### Address Fields Mapping

| Field | Alternative | Description |
|-------|-------------|-------------|
| `village` | `suburb`, `neighbourhood` | Desa/Kelurahan |
| `district` | `city_district` | Kecamatan |
| `county` | `city` | Kabupaten/Kota |
| `state` | - | Provinsi |

#### Service Implementation
```dart
// lib/data/datasources/location_service.dart
Future<Map<String, String>> getDetailedLocation(double lat, double lon) async {
  try {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&addressdetails=1&accept-language=id'
    );
    
    final response = await http.get(url, headers: {
      'User-Agent': 'PetaniMaju/1.0',
    });
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['address'] ?? {};
      
      return {
        'village': address['village'] ?? address['suburb'] ?? address['neighbourhood'] ?? '',
        'district': address['district'] ?? address['city_district'] ?? '',
        'regency': address['county'] ?? address['city'] ?? '',
        'province': address['state'] ?? '',
        'full': _buildFullAddress(address),
      };
    }
  } catch (e) {
    // Return empty if geocoding fails
  }
  
  return {
    'village': '',
    'district': '',
    'regency': '',
    'province': '',
    'full': '',
  };
}
```

---

## 🔷 Supabase API

Backend untuk menyimpan dan mengambil data tips pertanian.

### Konfigurasi

| Property | Value |
|----------|-------|
| Project URL | `https://hlfkxflasywitfwbkrxu.supabase.co` |
| Anon Key | `eyJhbGciOiJIUzI1NiIs...` (truncated) |

---

### Tips Table

#### Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | uuid | Primary key |
| `title` | text | Judul tips |
| `content` | text | Isi konten tips |
| `category` | text | Kategori (Padi, Jagung, dll) |
| `image_url` | text | URL gambar (optional) |
| `created_at` | timestamp | Tanggal dibuat |

#### Fetch All Tips

```dart
// lib/data/datasources/tips_services.dart
Future<List<Map<String, dynamic>>> fetchTips() async {
  try {
    final response = await _supabase
        .from('tips')
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw Exception('Gagal memuat tips: $e');
  }
}
```

#### Response Example
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Cara Menanam Padi yang Baik",
    "content": "Langkah pertama adalah mempersiapkan lahan...",
    "category": "Padi",
    "image_url": "https://example.com/image.jpg",
    "created_at": "2024-12-01T10:00:00Z"
  },
  {
    "id": "223e4567-e89b-12d3-a456-426614174001",
    "title": "Pemupukan Jagung",
    "content": "Pupuk yang baik untuk jagung adalah...",
    "category": "Jagung",
    "image_url": null,
    "created_at": "2024-11-28T08:30:00Z"
  }
]
```

---

## 🔐 Error Handling

### HTTP Status Codes

| Code | Description | Action |
|------|-------------|--------|
| 200 | Success | Parse response |
| 400 | Bad Request | Check parameters |
| 401 | Unauthorized | Check API key |
| 404 | Not Found | Check endpoint URL |
| 429 | Too Many Requests | Implement rate limiting |
| 500 | Server Error | Retry with backoff |

### Implementation Pattern
```dart
try {
  final response = await http.get(url);
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('API Error: ${response.statusCode}');
  }
} catch (e) {
  // Log error
  // Return cached data if available
  // Show user-friendly error message
}
```

---

## 📊 Rate Limits

| API | Rate Limit |
|-----|------------|
| OpenWeatherMap (Free) | 60 calls/minute, 1,000,000 calls/month |
| Nominatim | 1 call/second |
| Supabase (Free) | 500 MB database, 2 GB bandwidth/month |

---

## 🔄 Caching Strategy

### Weather Data
- **Cache Duration**: 30 menit
- **Strategy**: Cache-first, fetch in background
- **Stale Check**: `isWeatherCacheStale(maxAgeMinutes: 30)`

### Tips Data
- **Cache Duration**: Unlimited (until manual refresh)
- **Strategy**: Cache-first, fetch in background

### Location Data
- **Cache Duration**: Unlimited (until location change)
- **Strategy**: Cache-first, update on GPS change

---

*Dokumentasi API ini terakhir diperbarui: Desember 2024*
