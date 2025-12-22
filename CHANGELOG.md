# 📋 Changelog - Petani Maju

Semua perubahan penting pada proyek ini akan didokumentasikan di file ini.

Format berdasarkan [Keep a Changelog](https://keepachangelog.com/id-ID/1.0.0/),
dan proyek ini mengikuti [Semantic Versioning](https://semver.org/lang/id/).

---

## [Unreleased]

### Planned
- Notifikasi push untuk peringatan cuaca
- Multi-language support
- Dark mode
- Profil pengguna

---

## [0.2.0] - 2024-12-21

### 🎉 Offline Mode & Stability Update

Rilis yang berfokus pada stabilitas dan dukungan offline untuk pengalaman pengguna yang lebih baik.

### Added

#### 📴 Fitur Offline Mode
- Toggle Offline Mode di halaman Settings
- Auto-enable offline mode ketika tidak ada koneksi saat startup
- Snackbar notifikasi ketika app start dalam mode offline
- Pest data caching menggunakan Hive

#### ⏱️ Timeout Management
- Supabase initialization timeout (10 detik)
- Weather API timeout (10 detik)
- Tips API timeout (10 detik)
- Pest API timeout (10 detik)
- Location API timeout (10 detik)
- Geolocator timeout (5 detik)

### Changed

#### 🔄 Improved Image Loading
- Semua `Image.network` diganti dengan `CachedNetworkImage`
- Fallback icons ketika gambar gagal dimuat
- Placeholder icons saat loading

#### ⚡ Performance Improvements
- Deferred initialization menggunakan `addPostFrameCallback`
- Reduced location accuracy untuk startup lebih cepat
- Simplified navigation (tanpa IndexedStack caching)

### Fixed

#### 🐛 Bug Fixes
- App freeze saat tidak ada internet
- App crash saat kembali dari detail screen
- Splash screen stuck saat offline
- setState called after dispose
- Frame skipping saat startup

### Technical Details

#### New Dependencies
```yaml
dependencies:
  cached_network_image: ^3.4.1  # Untuk image caching
```

#### Updated Files
- `lib/main.dart` - Supabase timeout, offline detection
- `lib/core/services/cache_service.dart` - Pest caching, offline mode
- `lib/data/datasources/weather_service.dart` - 10s timeout
- `lib/data/datasources/tips_services.dart` - 10s timeout
- `lib/data/datasources/pest_services.dart` - 10s timeout
- `lib/data/datasources/location_service.dart` - 10s timeout
- `lib/features/home/screens/home_screen.dart` - Deferred init, offline check
- `lib/features/tips/screens/tips_screen.dart` - Deferred init, offline check
- `lib/features/pests/screens/pest_screen.dart` - Deferred init, offline check
- `lib/features/weather/screens/weather_detail_screen.dart` - Offline check
- `lib/features/settings/screens/settings_screen.dart` - Offline toggle
- `lib/widgets/main_weather_card.dart` - CachedNetworkImage
- `lib/features/home/widgets/forecast_list.dart` - CachedNetworkImage
- `lib/widgets/navbaar.dart` - Simplified navigation

---


## [0.1.0] - 2024-12-17

### 🎉 Initial Release

Rilis pertama aplikasi Petani Maju dengan fitur-fitur dasar untuk membantu petani Indonesia.

### Added

#### 🌤️ Fitur Cuaca
- Cuaca real-time berdasarkan lokasi pengguna
- Prediksi cuaca 4 jam ke depan dengan format hari dan tanggal
- Lokasi detail (Desa, Kecamatan, Kabupaten, Provinsi)
- Tema dinamis berdasarkan kondisi cuaca (cerah, hujan, berawan)
- Peringatan otomatis saat diprediksi hujan dalam 24 jam
- Tombol refresh untuk update data cuaca

#### 📚 Fitur Tips Pertanian
- Daftar tips dari database Supabase
- Filter tips berdasarkan kategori (Padi, Jagung, Nutrisi, dll)
- Halaman detail tips dengan gambar dan konten lengkap

#### 📅 Fitur Kalender
- Kalender untuk perencanaan aktivitas pertanian

#### 🐛 Fitur Hama & Penyakit
- Halaman informasi hama dan penyakit tanaman

#### ⚙️ Fitur Pengaturan
- Halaman pengaturan aplikasi

#### 💾 Fitur Offline
- Local caching menggunakan Hive
- Cache-first loading untuk pengalaman offline
- Graceful fallback ketika tidak ada koneksi internet

#### 🧭 Navigasi
- Bottom navigation bar dengan 4 tab (Home, Kalender, Tips, Settings)

#### 📍 Lokasi
- Request permission lokasi saat aplikasi dibuka
- Reverse geocoding menggunakan OpenStreetMap Nominatim

### Technical Details

#### Dependencies
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

#### API Integrations
- OpenWeatherMap API untuk data cuaca
- OpenStreetMap Nominatim untuk reverse geocoding
- Supabase untuk database tips pertanian

#### Minimum Requirements
- Flutter SDK >= 3.0.0
- Android SDK >= 21 (Android 5.0)
- iOS >= 12.0

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 0.1.0 | 2024-12-17 | Initial Release |

---

## Legend

- 🎉 **Added** - Fitur baru
- 🔄 **Changed** - Perubahan pada fitur yang ada
- 🗑️ **Deprecated** - Fitur yang akan dihapus di versi mendatang
- ❌ **Removed** - Fitur yang dihapus
- 🐛 **Fixed** - Bug fixes
- 🔒 **Security** - Perbaikan keamanan

---

## Cara Update Changelog

Saat melakukan perubahan pada project, tambahkan entry baru di section `[Unreleased]`:

```markdown
## [Unreleased]

### Added
- Deskripsi fitur baru yang ditambahkan

### Changed
- Deskripsi perubahan pada fitur yang ada

### Fixed
- Deskripsi bug yang diperbaiki
```

Saat siap merilis versi baru:
1. Ganti `[Unreleased]` menjadi `[X.X.X] - YYYY-MM-DD`
2. Tambahkan section `[Unreleased]` baru di atas
3. Update tabel Version History

---

*Changelog ini mengikuti format [Keep a Changelog](https://keepachangelog.com/)*
