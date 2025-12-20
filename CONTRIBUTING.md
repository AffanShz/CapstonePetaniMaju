# 🤝 Panduan Kontribusi - Petani Maju

Terima kasih telah tertarik untuk berkontribusi ke proyek Petani Maju! Panduan ini akan membantu Anda memulai.

---

## 📑 Daftar Isi

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Git Workflow](#git-workflow)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Testing](#testing)
- [Reporting Issues](#reporting-issues)

---

## 🚀 Getting Started

### Prerequisites

Pastikan Anda sudah menginstall:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.0.0
- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0
- [Git](https://git-scm.com/)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- Android Emulator atau iOS Simulator

### Verifikasi Instalasi

```bash
# Cek versi Flutter
flutter --version

# Cek status Flutter
flutter doctor
```

---

## 💻 Development Setup

### 1. Fork Repository

Klik tombol "Fork" di halaman GitHub repository untuk membuat copy di akun Anda.

### 2. Clone Repository

```bash
# Clone dari fork Anda
git clone https://github.com/YOUR_USERNAME/CapstonePetaniMaju.git
cd petani_maju

# Tambahkan upstream remote
git remote add upstream https://github.com/AffanShz/CapstonePetaniMaju.git
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Setup Emulator/Simulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

### 5. Run Aplikasi

```bash
# Development mode
flutter run

# Hot reload
# Tekan 'r' di terminal atau Ctrl+S di IDE

# Hot restart
# Tekan 'R' di terminal
```

---

## 📝 Coding Standards

### Dart Style Guide

Ikuti [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide:

#### Naming Conventions

```dart
// Classes - PascalCase
class WeatherService { }

// Variables & Functions - camelCase
final weatherData = fetchWeather();
void loadData() { }

// Constants - lowerCamelCase
const maxCacheAge = 30;

// Private members - prefix with underscore
String _privateField;
void _privateMethod() { }

// File names - snake_case
// weather_service.dart
// main_weather_card.dart
```

#### Formatting

```bash
# Format semua file
dart format .

# Format file tertentu
dart format lib/path/to/file.dart
```

#### Linting

```bash
# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Code Organization

```dart
// 1. Imports (urut alfabetis dalam grup)
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:petani_maju/data/datasources/cache_service.dart';

// 2. Class declaration
class MyWidget extends StatefulWidget {
  // 3. Static/const fields
  static const String defaultTitle = 'Hello';
  
  // 4. Instance fields
  final String title;
  
  // 5. Constructor
  const MyWidget({super.key, required this.title});
  
  // 6. createState
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 7. State variables
  bool _isLoading = false;
  
  // 8. Lifecycle methods
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  // 9. Private methods
  void _handleTap() { }
  
  // 10. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Documentation

Tambahkan dokumentasi untuk:

- Public classes dan methods
- Complex logic
- API parameters dan return types

```dart
/// Service untuk caching data lokal menggunakan Hive.
/// 
/// Mendukung pendekatan offline-first: load cache dulu, fetch API kemudian.
/// 
/// Example:
/// ```dart
/// final cache = CacheService();
/// await cache.saveWeatherData(currentWeather: data, forecastList: list);
/// ```
class CacheService {
  /// Simpan data cuaca ke cache.
  /// 
  /// [currentWeather] - Map data cuaca terkini dari API
  /// [forecastList] - List data forecast dari API
  Future<void> saveWeatherData({
    required Map<String, dynamic> currentWeather,
    required List<dynamic> forecastList,
  }) async {
    // implementation
  }
}
```

---

## 🔀 Git Workflow

### Branch Strategy

```
main          - Production-ready code
├── develop   - Integration branch
│   ├── feature/xxx  - New features
│   ├── bugfix/xxx   - Bug fixes
│   └── hotfix/xxx   - Urgent fixes
```

### Creating a Feature Branch

```bash
# Sync dengan upstream
git fetch upstream
git checkout develop
git merge upstream/develop

# Buat branch baru
git checkout -b feature/nama-fitur
```

### Commit Messages

Format: `<type>(<scope>): <description>`

#### Types

| Type | Description |
|------|-------------|
| `feat` | Fitur baru |
| `fix` | Bug fix |
| `docs` | Dokumentasi |
| `style` | Formatting, semicolons, dll |
| `refactor` | Refactoring code |
| `test` | Menambah tests |
| `chore` | Maintenance tasks |

#### Examples

```bash
git commit -m "feat(weather): add rain probability to forecast card"
git commit -m "fix(cache): handle null values in tips data"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(home): extract weather card to separate widget"
```

### Keeping Your Branch Updated

```bash
# Fetch latest changes
git fetch upstream

# Rebase your branch
git rebase upstream/develop

# Force push if needed (only on your feature branch!)
git push --force-with-lease origin feature/nama-fitur
```

---

## 🔄 Pull Request Guidelines

### Before Submitting

- [ ] Code sudah terformat (`dart format .`)
- [ ] Tidak ada warning dari analyzer (`flutter analyze`)
- [ ] Semua tests passing (`flutter test`)
- [ ] Aplikasi berjalan tanpa error
- [ ] Sudah sync dengan branch `develop` terbaru
- [ ] Commit messages sesuai convention

### PR Template

```markdown
## Description
[Jelaskan perubahan yang Anda buat]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Screenshots (if applicable)
[Tambahkan screenshot untuk perubahan UI]

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed my code
- [ ] Added comments for complex logic
- [ ] Updated documentation if needed
- [ ] No new warnings
```

### Review Process

1. Submit PR ke branch `develop`
2. Tunggu review dari maintainer
3. Address feedback jika ada
4. Setelah approved, PR akan di-merge

---

## 🧪 Testing

### Running Tests

```bash
# Run semua tests
flutter test

# Run tests dengan coverage
flutter test --coverage

# Run specific test file
flutter test test/path/to/test.dart
```

### Writing Tests

```dart
// test/services/weather_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:petani_maju/data/datasources/weather_service.dart';

void main() {
  group('WeatherService', () {
    late WeatherService service;
    
    setUp(() {
      service = WeatherService();
    });
    
    test('fetchCurrentWeather returns valid data', () async {
      final result = await service.fetchCurrentWeather();
      
      expect(result, isNotNull);
      expect(result['main'], isNotNull);
      expect(result['weather'], isA<List>());
    });
    
    test('fetchForecast returns list of forecasts', () async {
      final result = await service.fetchForecast();
      
      expect(result['list'], isA<List>());
      expect(result['list'].length, greaterThan(0));
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/main_weather_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petani_maju/widgets/main_weather_card.dart';

void main() {
  testWidgets('MainWeatherCard displays temperature', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MainWeatherCard(
          temperature: 28.5,
          description: 'Cerah',
          location: 'Jakarta',
        ),
      ),
    );
    
    expect(find.text('28°C'), findsOneWidget);
    expect(find.text('Cerah'), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
  });
}
```

---

## 🐛 Reporting Issues

### Bug Report Template

```markdown
## Bug Description
[Deskripsi singkat bug]

## Steps to Reproduce
1. Buka aplikasi
2. Pergi ke '...'
3. Klik pada '...'
4. Lihat error

## Expected Behavior
[Apa yang seharusnya terjadi]

## Actual Behavior
[Apa yang terjadi]

## Screenshots
[Jika applicable]

## Environment
- Flutter version: [e.g., 3.16.0]
- Dart version: [e.g., 3.2.0]
- Device: [e.g., Samsung Galaxy S21]
- OS: [e.g., Android 13]
```

### Feature Request Template

```markdown
## Feature Description
[Deskripsi fitur yang diinginkan]

## Use Case
[Mengapa fitur ini dibutuhkan]

## Proposed Solution
[Bagaimana fitur ini bisa diimplementasikan]

## Alternatives Considered
[Alternatif lain yang dipertimbangkan]

## Additional Context
[Informasi tambahan]
```

---

## 📂 Project Structure for New Features

Ketika menambah fitur baru, ikuti struktur yang sudah ada:

```
lib/features/nama_fitur/
├── screens/
│   └── nama_fitur_screen.dart
├── widgets/
│   ├── widget_satu.dart
│   └── widget_dua.dart
└── (opsional) models/
    └── nama_model.dart
```

Jika fitur memerlukan service baru:

```
lib/data/datasources/
└── nama_fitur_service.dart
```

---

## 💬 Getting Help

Jika Anda memiliki pertanyaan:

1. Cek [dokumentasi](./DOCS.md) terlebih dahulu
2. Search existing issues
3. Buat issue baru dengan label `question`

---

## 🙏 Acknowledgments

Terima kasih kepada semua kontributor yang telah membantu mengembangkan Petani Maju!

---

*Panduan kontribusi ini terakhir diperbarui: Desember 2024*
