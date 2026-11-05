import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/city_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Central state manager using Provider and ChangeNotifier.
class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService;
  final LocationService _locationService;
  final StorageService _storageService;

  WeatherProvider({
    WeatherService? weatherService,
    LocationService? locationService,
    StorageService? storageService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _locationService = locationService ?? LocationService(),
        _storageService = storageService ?? StorageService();

  // State Variables
  WeatherModel? _currentWeather;
  List<HourlyForecastModel> _hourlyForecast = [];
  List<DailyForecastModel> _weeklyForecast = [];
  CityModel _selectedCity = const CityModel(
    name: 'London',
    latitude: AppConstants.defaultLatitude,
    longitude: AppConstants.defaultLongitude,
    country: 'United Kingdom',
    isFavorite: true,
  );
  List<CityModel> _savedCities = [];
  Map<String, WeatherModel> _savedCitiesWeather = {};

  bool _isLoading = false;
  String? _errorMessage;

  String _temperatureUnit = AppConstants.unitCelsius; // 'metric' or 'imperial'
  String _windSpeedUnit = AppConstants.unitKmh; // 'km/h' or 'm/s'
  ThemeMode _themeMode = ThemeMode.system;

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  List<HourlyForecastModel> get hourlyForecast => _hourlyForecast;
  List<DailyForecastModel> get weeklyForecast => _weeklyForecast;
  CityModel get selectedCity => _selectedCity;
  List<CityModel> get savedCities => _savedCities;
  Map<String, WeatherModel> get savedCitiesWeather => _savedCitiesWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get temperatureUnit => _temperatureUnit;
  String get windSpeedUnit => _windSpeedUnit;
  ThemeMode get themeMode => _themeMode;
  bool get isCelsius => _temperatureUnit == AppConstants.unitCelsius;

  /// Initialize state from local persistent storage and load weather
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load saved preferences
      _temperatureUnit = await _storageService.getTemperatureUnit();
      _windSpeedUnit = await _storageService.getWindSpeedUnit();
      final modeStr = await _storageService.getThemeMode();
      _themeMode = _parseThemeMode(modeStr);

      final customKey = await _storageService.getCustomApiKey();
      if (customKey != null) {
        _weatherService.apiKey = customKey;
      }

      // Load saved cities
      _savedCities = await _storageService.loadSavedCities();

      // Check last selected city
      final lastCity = await _storageService.getLastSelectedCity();
      if (lastCity != null) {
        _selectedCity = lastCity;
      } else if (_savedCities.isNotEmpty) {
        _selectedCity = _savedCities.first;
      }

      // Fetch primary weather
      await _fetchWeatherInternal(_selectedCity);

      // Fetch weather for other saved cities in background
      _fetchSavedCitiesWeather();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change active city and fetch its forecast
  Future<void> selectCity(CityModel city) async {
    _selectedCity = city;
    await _storageService.setLastSelectedCity(city);
    await fetchWeatherForCity(city);
  }

  /// Fetch weather for a given city
  Future<void> fetchWeatherForCity(CityModel city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchWeatherInternal(city);
    } catch (e) {
      _errorMessage = _getFriendlyErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh weather for currently selected city
  Future<void> refreshWeather() async {
    await fetchWeatherForCity(_selectedCity);
    _fetchSavedCitiesWeather();
  }

  /// Use device GPS to fetch local weather
  Future<void> fetchWeatherForCurrentLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final city = await _locationService.getCurrentLocationCity();
      _selectedCity = city;
      await _storageService.setLastSelectedCity(city);
      await _fetchWeatherInternal(city);
    } catch (e) {
      _errorMessage = 'Location error: ${e.toString().replaceAll('Exception:', '').trim()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal fetch method
  Future<void> _fetchWeatherInternal(CityModel city) async {
    final result = await _weatherService.fetchWeatherData(
      latitude: city.latitude,
      longitude: city.longitude,
      cityName: city.name,
      country: city.country,
    );

    _currentWeather = result.current;
    _hourlyForecast = result.hourly;
    _weeklyForecast = result.daily;
    _errorMessage = null;
  }

  /// Fetch lightweight weather for each saved city
  Future<void> _fetchSavedCitiesWeather() async {
    for (final city in _savedCities) {
      try {
        final result = await _weatherService.fetchWeatherData(
          latitude: city.latitude,
          longitude: city.longitude,
          cityName: city.name,
          country: city.country,
        );
        _savedCitiesWeather[city.name.toLowerCase()] = result.current;
        notifyListeners();
      } catch (_) {
        // Skip failed secondary city
      }
    }
  }

  /// Add city to favorites (prevents duplicates)
  Future<void> addCityToSaved(CityModel city) async {
    final exists = _savedCities.any(
      (c) => c.name.toLowerCase() == city.name.toLowerCase() && c.country.toLowerCase() == city.country.toLowerCase(),
    );
    if (!exists) {
      final updatedCity = city.copyWith(isFavorite: true);
      _savedCities.add(updatedCity);
      await _storageService.saveCities(_savedCities);
      
      // Fetch its weather card
      try {
        final result = await _weatherService.fetchWeatherData(
          latitude: updatedCity.latitude,
          longitude: updatedCity.longitude,
          cityName: updatedCity.name,
          country: updatedCity.country,
        );
        _savedCitiesWeather[updatedCity.name.toLowerCase()] = result.current;
      } catch (_) {}

      notifyListeners();
    }
  }

  /// Remove city from favorites
  Future<void> removeCityFromSaved(CityModel city) async {
    _savedCities.removeWhere(
      (c) => c.name.toLowerCase() == city.name.toLowerCase() && c.country.toLowerCase() == city.country.toLowerCase(),
    );
    _savedCitiesWeather.remove(city.name.toLowerCase());
    await _storageService.saveCities(_savedCities);
    notifyListeners();
  }

  /// Check if a city is in favorites
  bool isCitySaved(CityModel city) {
    return _savedCities.any(
      (c) => c.name.toLowerCase() == city.name.toLowerCase() && c.country.toLowerCase() == city.country.toLowerCase(),
    );
  }

  /// Toggle favorite status of current city
  Future<void> toggleFavorite(CityModel city) async {
    if (isCitySaved(city)) {
      await removeCityFromSaved(city);
    } else {
      await addCityToSaved(city);
    }
  }

  /// Search cities via geocoding service
  Future<List<CityModel>> searchCities(String query) async {
    return await _weatherService.searchCities(query);
  }

  // Unit and Theme updates
  Future<void> setTemperatureUnit(String unit) async {
    _temperatureUnit = unit;
    await _storageService.setTemperatureUnit(unit);
    notifyListeners();
  }

  Future<void> setWindSpeedUnit(String unit) async {
    _windSpeedUnit = unit;
    await _storageService.setWindSpeedUnit(unit);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final modeStr = mode == ThemeMode.light ? 'light' : (mode == ThemeMode.dark ? 'dark' : 'system');
    await _storageService.setThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> setCustomApiKey(String? key) async {
    _weatherService.apiKey = key;
    await _storageService.setCustomApiKey(key);
    notifyListeners();
    await refreshWeather();
  }

  // --- Formatting Helpers for UI ---
  String formatTemperature(double celsius) {
    if (_temperatureUnit == AppConstants.unitFahrenheit) {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.round()}°F';
    }
    return '${celsius.round()}°C';
  }

  int convertTemperature(double celsius) {
    if (_temperatureUnit == AppConstants.unitFahrenheit) {
      return ((celsius * 9 / 5) + 32).round();
    }
    return celsius.round();
  }

  String formatWindSpeed(double speedKmh) {
    if (_windSpeedUnit == AppConstants.unitMs) {
      final ms = speedKmh / 3.6;
      return '${ms.toStringAsFixed(1)} m/s';
    }
    return '${speedKmh.round()} km/h';
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  static String _getFriendlyErrorMessage(dynamic error) {
    final str = error.toString();
    if (str.contains('SocketException') || str.contains('No Internet')) {
      return 'No internet connection. Please check Wi-Fi or mobile data.';
    }
    if (str.contains('401') || str.contains('Unauthorized')) {
      return 'Invalid API Key. Please verify in Settings.';
    }
    if (str.contains('404')) {
      return 'City or weather data not found. Try searching another location.';
    }
    if (str.contains('429')) {
      return 'Weather service rate limit reached. Please try again shortly.';
    }
    return 'Unable to fetch weather. Please tap retry.';
  }
}
