# SkyCast - Flutter Weather Forecast Android Application

A complete, modern, and responsive Weather Forecast Android application developed with Flutter 3.35+, Dart null safety, Provider for state management, `fl_chart` for weather visualizations, and real live weather APIs (Open-Meteo and OpenWeatherMap).

---

## 1. Project Folder Structure

```
flutter_weather_app/
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml      # Internet & GPS Location permissions
├── lib/
│   ├── main.dart                            # App entrypoint & Provider tree
│   ├── models/
│   │   ├── weather_model.dart               # Complete current weather metrics
│   │   ├── forecast_model.dart              # Hourly & 7-Day daily forecast models
│   │   └── city_model.dart                  # City data model with JSON serialization
│   ├── services/
│   │   ├── weather_service.dart             # Live weather API & Geocoding client
│   │   ├── location_service.dart            # Device GPS permission & geocoding
│   │   └── storage_service.dart             # SharedPreferences persistence
│   ├── providers/
│   │   └── weather_provider.dart            # ChangeNotifier central state manager
│   ├── screens/
│   │   ├── home_screen.dart                 # Dashboard with dynamic weather cards
│   │   ├── hourly_forecast_screen.dart      # 24-Hour forecast & temperature curve
│   │   ├── weekly_forecast_screen.dart      # 7-Day forecast with modal detail dialog
│   │   ├── saved_cities_screen.dart         # Favorites management with search & delete
│   │   └── settings_screen.dart             # Units (°C/°F, km/h vs m/s), theme & API keys
│   ├── widgets/
│   │   ├── current_weather_card.dart        # Weather card with condition gradients
│   │   ├── hourly_forecast_card.dart        # Horizontally scrollable 24h cards
│   │   ├── daily_forecast_card.dart         # 7-day row with min/max range bar
│   │   ├── weather_details_card.dart        # 6-metric atmospheric grid
│   │   ├── city_search_bar.dart             # Search bar with auto-suggestions & GPS
│   │   ├── weather_chart.dart               # fl_chart Bezier temperature trend
│   │   └── bottom_navigation_bar.dart       # Material 3 navigation destinations
│   └── utils/
│       ├── app_theme.dart                   # Material 3 light & dark theme definitions
│       ├── weather_icons.dart               # Dynamic icons & condition color gradients
│       └── constants.dart                   # Endpoints, default locations & preference keys
├── test/
│   └── widget_test.dart                     # Flutter widget test suite
└── pubspec.yaml                             # Dependencies & Flutter SDK constraints
```

---

## 2. API Configuration Instructions

SkyCast supports two real live weather backends:

1. **Zero-Configuration Instant Live Weather (Open-Meteo)**:
   - Built-in by default! Open-Meteo requires **no API key** and has no signup hurdles.
   - Provides live global forecasts, 24-hour hourly temperatures, rain probabilities, wind speeds, UV index, and 7-day extended forecasts.

2. **OpenWeatherMap Integration (Optional)**:
   - If you have an OpenWeatherMap API key:
     1. Open the app on your Android device.
     2. Navigate to **Settings** (bottom tab or gear icon).
     3. Tap **Custom API Key** and paste your 32-character key from [OpenWeatherMap](https://home.openweathermap.org/api_keys).
     4. The app will immediately switch to OpenWeatherMap for live queries.
     5. Alternatively, set `defaultOpenWeatherMapApiKey` in `lib/utils/constants.dart`.

---

## 3. Instructions to Run the Application

### Prerequisites:
- Flutter SDK `>= 3.35.0`
- Dart SDK `>= 3.3.0`
- Android Studio with Android SDK API 34+ and Android Emulator (or a physical Android phone with USB Debugging enabled)

### Steps:

1. **Open terminal in the project directory**:
   ```bash
   cd flutter_weather_app
   ```

2. **Install all dependencies from `pubspec.yaml`**:
   ```bash
   flutter pub get
   ```

3. **Verify connected devices**:
   ```bash
   flutter devices
   ```

4. **Run on Android device or emulator**:
   ```bash
   flutter run
   ```
   *(To run specifically on Android, run `flutter run -d android`)*

---

## 4. Running the Flutter Widget Tests

To execute the unit and widget test suite:

```bash
flutter test
```

This verifies:
- `CurrentWeatherCard` widget rendering with mock atmospheric data
- `WeatherProvider` temperature unit conversion (°C to °F)
- `CityModel` equality checks and JSON serialization

---

## 5. Generating a Release APK

To create an optimized, standalone release APK for installation on Android phones:

### Step 1: Build Release APK directly
```bash
flutter build apk --release
```

The output APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 2: (Optional) Build Split Per-ABI APKs (Smaller file size)
To generate smaller APKs optimized for specific CPU architectures (ARM64, ARM32, x86_64):
```bash
flutter build apk --split-per-abi --release
```

### Step 3: (For Google Play Store) Build Android App Bundle (.aab)
```bash
flutter build appbundle --release
```
The output App Bundle will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Signing Configuration (Production Keystore)
For official Play Store distribution:
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `/android/key.properties` with:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=/path/to/upload-keystore.jks
   ```
3. Reference `key.properties` in `android/app/build.gradle`.
