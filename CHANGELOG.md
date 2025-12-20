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
