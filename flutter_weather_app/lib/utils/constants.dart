/// Application constants, API endpoints, and configuration defaults.
class AppConstants {
  static const String appName = 'SkyCast';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // Weather API configuration (Defaults to Open-Meteo for keyless instant live data, 
  // with OpenWeatherMap API support)
  static const String defaultOpenWeatherMapApiKey = ''; // User can supply via Settings or compile flag
  static const String openWeatherMapBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String openMeteoForecastUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String openMeteoGeocodingUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  // SharedPreferences Keys
  static const String keySavedCities = 'saved_cities_list_v1';
  static const String keyTemperatureUnit = 'temp_unit_pref';
  static const String keyWindSpeedUnit = 'wind_unit_pref';
  static const String keyThemeMode = 'theme_mode_pref';
  static const String keyLastSelectedCity = 'last_selected_city';
  static const String keyApiKey = 'custom_weather_api_key';
  static const String keyUseGps = 'use_gps_pref';

  // Default Fallback Coordinates (London, UK)
  static const double defaultLatitude = 51.5074;
  static const double defaultLongitude = -0.1278;
  static const String defaultCityName = 'London';
  static const String defaultCountry = 'GB';

  // Units
  static const String unitCelsius = 'metric';
  static const String unitFahrenheit = 'imperial';
  static const String unitKmh = 'km/h';
  static const String unitMs = 'm/s';
}
