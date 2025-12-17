# 🌾 Petani Maju

Aplikasi mobile untuk membantu petani Indonesia dengan informasi cuaca, tips pertanian, dan kalender tanam.

## 📚 Dokumentasi

| Dokumen | Deskripsi |
|---------|-----------|
| [📖 DOCS.md](./DOCS.md) | Dokumentasi teknis lengkap |
| [🔌 API.md](./API.md) | Dokumentasi API dan endpoints |
| [🤝 CONTRIBUTING.md](./CONTRIBUTING.md) | Panduan kontribusi |
| [📋 CHANGELOG.md](./CHANGELOG.md) | Log perubahan versi |

## 📱 Fitur Utama

### 🌤️ Cuaca
- **Cuaca Real-time** - Data cuaca terkini dari lokasi pengguna
- **Prediksi 4 Jam** - Forecast cuaca per 4 jam dengan hari dan tanggal
- **Lokasi Detail** - Menampilkan Desa, Kecamatan, Kabupaten, Provinsi
- **Tema Dinamis** - Warna berubah sesuai kondisi cuaca (cerah, hujan, berawan, dll)
- **Peringatan Hujan** - Notifikasi otomatis jika diprediksi hujan dalam 24 jam

### 📚 Tips Pertanian
- **Tips dari Database** - Konten tips dari Supabase backend
- **Kategori Filter** - Filter berdasarkan kategori (Padi, Jagung, Nutrisi, dll)
- **Detail Tips** - Halaman detail dengan gambar dan konten lengkap

### 📅 Kalender Tanam
- Kalender untuk perencanaan aktivitas pertanian

### 🐛 Hama & Penyakit
- Informasi tentang hama dan penyakit tanaman

### 💾 Offline Support
- **Hive Local Caching** - Data tersimpan lokal untuk akses offline
- **Cache-first Loading** - Tampilkan data cache dulu, fetch API di background
- **Graceful Fallback** - Tetap berfungsi saat tidak ada internet

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.x |
| State Management | StatefulWidget |
| Backend | Supabase |
| Weather API | OpenWeatherMap |
| Geocoding | OpenStreetMap Nominatim |
| Local Storage | Hive |
| Location | Geolocator |

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  geolocator: ^14.0.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.6.0
  intl: ^0.20.2
  permission_handler: ^12.0.1
  supabase_flutter: ^2.0.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / VS Code
- Android Emulator atau iOS Simulator

### Installation

1. Clone repository
```bash
git clone https://github.com/AffanShz/CapstonePetaniMaju.git
cd petani_maju
```

2. Install dependencies
```bash
flutter pub get
```

3. Run aplikasi
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── data/
│   └── datasources/
│       ├── cache_service.dart    # Hive local caching
│       ├── location_service.dart # Reverse geocoding
│       ├── tips_services.dart    # Supabase tips API
│       └── weather_service.dart  # OpenWeatherMap API
├── features/
│   ├── calendar/                 # Kalender tanam
│   ├── home/                     # Home screen & widgets
│   ├── pests/                    # Hama & penyakit
│   ├── tips/                     # Tips pertanian
│   └── weather/                  # Detail cuaca
├── utils/
│   └── weather_utils.dart        # Weather translation
├── widgets/                      # Reusable widgets
└── main.dart                     # App entry point
```

## 🔄 Caching Flow

```
App Dibuka
    ↓
Load dari Hive Cache (instant)
    ↓
Tampilkan data cached
    ↓
Fetch API (background)
    ↓
Berhasil? → Update cache + UI
Gagal? → Tetap tampilkan cached data
```

## 👥 Team

- Capstone Project Team

## 📄 License

This project is for educational purposes.
