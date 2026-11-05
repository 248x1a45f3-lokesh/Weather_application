import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city_model.dart';
import '../utils/constants.dart';

/// StorageService provides local persistence using SharedPreferences.
class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService must be initialized via init() before use.');
    }
    return _prefs!;
  }

  // --- Saved Favorite Cities ---
  Future<List<CityModel>> loadSavedCities() async {
    await init();
    final jsonList = prefs.getStringList(AppConstants.keySavedCities);
    if (jsonList == null || jsonList.isEmpty) {
      // Default initial cities
      return [
        const CityModel(name: 'London', latitude: 51.5074, longitude: -0.1278, country: 'United Kingdom', isFavorite: true),
        const CityModel(name: 'New York', latitude: 40.7128, longitude: -74.0060, country: 'United States', isFavorite: true),
        const CityModel(name: 'Tokyo', latitude: 35.6762, longitude: 139.6503, country: 'Japan', isFavorite: true),
      ];
    }

    return jsonList.map((item) {
      final map = json.decode(item) as Map<String, dynamic>;
      return CityModel.fromJson(map);
    }).toList();
  }

  Future<void> saveCities(List<CityModel> cities) async {
    await init();
    final jsonList = cities.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(AppConstants.keySavedCities, jsonList);
  }

  // --- Preferences ---
  Future<String> getTemperatureUnit() async {
    await init();
    return prefs.getString(AppConstants.keyTemperatureUnit) ?? AppConstants.unitCelsius;
  }

  Future<void> setTemperatureUnit(String unit) async {
    await init();
    await prefs.setString(AppConstants.keyTemperatureUnit, unit);
  }

  Future<String> getWindSpeedUnit() async {
    await init();
    return prefs.getString(AppConstants.keyWindSpeedUnit) ?? AppConstants.unitKmh;
  }

  Future<void> setWindSpeedUnit(String unit) async {
    await init();
    await prefs.setString(AppConstants.keyWindSpeedUnit, unit);
  }

  Future<String> getThemeMode() async {
    await init();
    return prefs.getString(AppConstants.keyThemeMode) ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    await init();
    await prefs.setString(AppConstants.keyThemeMode, mode);
  }

  Future<String?> getCustomApiKey() async {
    await init();
    return prefs.getString(AppConstants.keyApiKey);
  }

  Future<void> setCustomApiKey(String? key) async {
    await init();
    if (key == null || key.isEmpty) {
      await prefs.remove(AppConstants.keyApiKey);
    } else {
      await prefs.setString(AppConstants.keyApiKey, key);
    }
  }

  Future<CityModel?> getLastSelectedCity() async {
    await init();
    final jsonStr = prefs.getString(AppConstants.keyLastSelectedCity);
    if (jsonStr != null) {
      return CityModel.fromJson(json.decode(jsonStr) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> setLastSelectedCity(CityModel city) async {
    await init();
    await prefs.setString(AppConstants.keyLastSelectedCity, json.encode(city.toJson()));
  }
}
