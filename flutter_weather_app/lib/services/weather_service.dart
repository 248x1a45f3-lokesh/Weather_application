import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/city_model.dart';
import '../utils/constants.dart';

/// WeatherService coordinates all network API requests to weather providers.
/// Supports OpenWeatherMap (with API Key) and Open-Meteo (zero-key live forecast).
class WeatherService {
  final http.Client _client;
  String? apiKey;

  WeatherService({http.Client? client, this.apiKey})
      : _client = client ?? http.Client();

  /// Search cities by query string
  Future<List<CityModel>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        '${AppConstants.openMeteoGeocodingUrl}?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) return [];

        return results.map((item) {
          final map = item as Map<String, dynamic>;
          return CityModel(
            name: map['name'] as String? ?? query,
            latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
            country: map['country'] as String? ?? (map['country_code'] as String? ?? ''),
            state: map['admin1'] as String?,
          );
        }).toList();
      } else {
        throw HttpException('City search failed with status ${response.statusCode}');
      }
    } on SocketException {
      throw const SocketException('No Internet connection. Please check your network.');
    } catch (e) {
      // Return empty or rethrow
      return [];
    }
  }

  /// Fetch full weather bundle (Current + 24h Hourly + 7-Day Forecast)
  Future<{
    WeatherModel current,
    List<HourlyForecastModel> hourly,
    List<DailyForecastModel> daily,
  }> fetchWeatherData({
    required double latitude,
    required double longitude,
    required String cityName,
    String country = '',
  }) async {
    // If user provided a valid OpenWeatherMap key, we can query OWM or default to Open-Meteo
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      try {
        return await _fetchFromOpenWeatherMap(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
          country: country,
        );
      } catch (e) {
        // Fallback safely to Open-Meteo if OWM key fails or has quota issue
        return await _fetchFromOpenMeteo(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
          country: country,
        );
      }
    }

    // Default to Open-Meteo (Real live data, global, zero configuration required)
    return await _fetchFromOpenMeteo(
      latitude: latitude,
      longitude: longitude,
      cityName: cityName,
      country: country,
    );
  }

  /// Open-Meteo live API implementation
  Future<{
    WeatherModel current,
    List<HourlyForecastModel> hourly,
    List<DailyForecastModel> daily,
  }> _fetchFromOpenMeteo({
    required double latitude,
    required double longitude,
    required String cityName,
    required String country,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.openMeteoForecastUrl}?'
        'latitude=$latitude&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,surface_pressure,wind_speed_10m,wind_direction_10m'
        '&hourly=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation_probability,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_probability_max,wind_speed_10m_max'
        '&timezone=auto',
      );

      final response = await _client.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw HttpException('Open-Meteo returned status code: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final currentMap = data['current'] as Map<String, dynamic>? ?? {};
      final dailyMap = data['daily'] as Map<String, dynamic>? ?? {};
      final hourlyMap = data['hourly'] as Map<String, dynamic>? ?? {};

      // Parse Current Weather
      final currentWeather = WeatherModel.fromOpenMeteo(
        current: currentMap,
        daily: dailyMap,
        cityName: cityName,
        country: country,
      );

      // Parse Hourly Forecast (Next 24 hours)
      final List<HourlyForecastModel> hourlyList = [];
      final hourlyTimes = (hourlyMap['time'] as List<dynamic>?) ?? [];
      final hourlyTemps = (hourlyMap['temperature_2m'] as List<dynamic>?) ?? [];
      final hourlyFeels = (hourlyMap['apparent_temperature'] as List<dynamic>?) ?? [];
      final hourlyCodes = (hourlyMap['weather_code'] as List<dynamic>?) ?? [];
      final hourlyPops = (hourlyMap['precipitation_probability'] as List<dynamic>?) ?? [];
      final hourlyWinds = (hourlyMap['wind_speed_10m'] as List<dynamic>?) ?? [];
      final hourlyHumids = (hourlyMap['relative_humidity_2m'] as List<dynamic>?) ?? [];

      final now = DateTime.now();
      int startIndex = 0;
      for (int i = 0; i < hourlyTimes.length; i++) {
        final t = DateTime.tryParse(hourlyTimes[i].toString());
        if (t != null && t.isAfter(now.subtract(const Duration(hours: 1)))) {
          startIndex = i;
          break;
        }
      }

      for (int i = startIndex; i < startIndex + 24 && i < hourlyTimes.length; i++) {
        final t = DateTime.tryParse(hourlyTimes[i].toString()) ?? now;
        final code = (hourlyCodes[i] as num?)?.toInt() ?? 0;
        final conditionInfo = _mapCodeToCondition(code);
        final hour = t.hour;
        final isDay = hour >= 6 && hour < 20;

        hourlyList.add(
          HourlyForecastModel(
            time: t,
            temperature: (hourlyTemps[i] as num?)?.toDouble() ?? 20.0,
            feelsLike: (hourlyFeels[i] as num?)?.toDouble() ?? 20.0,
            condition: conditionInfo['main'] ?? 'Clear',
            description: conditionInfo['desc'] ?? 'Clear',
            iconCode: isDay ? '01d' : '01n',
            rainProbability: (hourlyPops[i] as num?)?.toInt() ?? 0,
            windSpeed: (hourlyWinds[i] as num?)?.toDouble() ?? 0.0,
            humidity: (hourlyHumids[i] as num?)?.toInt() ?? 50,
            isDay: isDay,
          ),
        );
      }

      // Parse 7-Day Forecast
      final List<DailyForecastModel> dailyList = [];
      final dailyTimes = (dailyMap['time'] as List<dynamic>?) ?? [];
      final dailyCodes = (dailyMap['weather_code'] as List<dynamic>?) ?? [];
      final dailyMax = (dailyMap['temperature_2m_max'] as List<dynamic>?) ?? [];
      final dailyMin = (dailyMap['temperature_2m_min'] as List<dynamic>?) ?? [];
      final dailyPops = (dailyMap['precipitation_probability_max'] as List<dynamic>?) ?? [];
      final dailyWinds = (dailyMap['wind_speed_10m_max'] as List<dynamic>?) ?? [];
      final dailySunrises = (dailyMap['sunrise'] as List<dynamic>?) ?? [];
      final dailySunsets = (dailyMap['sunset'] as List<dynamic>?) ?? [];
      final dailyUvs = (dailyMap['uv_index_max'] as List<dynamic>?) ?? [];

      for (int i = 0; i < dailyTimes.length && i < 7; i++) {
        final date = DateTime.tryParse(dailyTimes[i].toString()) ?? now.add(Duration(days: i));
        final code = (dailyCodes[i] as num?)?.toInt() ?? 0;
        final conditionInfo = _mapCodeToCondition(code);
        final dayName = i == 0 ? 'Today' : _getDayName(date.weekday);

        DateTime? sunrise;
        DateTime? sunset;
        if (i < dailySunrises.length) {
          sunrise = DateTime.tryParse(dailySunrises[i].toString());
        }
        if (i < dailySunsets.length) {
          sunset = DateTime.tryParse(dailySunsets[i].toString());
        }

        dailyList.add(
          DailyForecastModel(
            date: date,
            dayName: dayName,
            tempMin: (dailyMin[i] as num?)?.toDouble() ?? 15.0,
            tempMax: (dailyMax[i] as num?)?.toDouble() ?? 25.0,
            condition: conditionInfo['main'] ?? 'Clear',
            description: conditionInfo['desc'] ?? 'Clear Sky',
            iconCode: '01d',
            rainProbability: (dailyPops[i] as num?)?.toInt() ?? 0,
            humidity: 60,
            windSpeed: (dailyWinds[i] as num?)?.toDouble() ?? 10.0,
            uvIndex: (dailyUvs[i] as num?)?.toDouble() ?? 5.0,
            sunrise: sunrise,
            sunset: sunset,
          ),
        );
      }

      return (current: currentWeather, hourly: hourlyList, daily: dailyList);
    } on SocketException {
      throw const SocketException('No Internet connection. Please check your network.');
    } catch (e) {
      throw Exception('Failed to fetch weather: $e');
    }
  }

  /// OpenWeatherMap implementation
  Future<{
    WeatherModel current,
    List<HourlyForecastModel> hourly,
    List<DailyForecastModel> daily,
  }> _fetchFromOpenWeatherMap({
    required double latitude,
    required double longitude,
    required String cityName,
    required String country,
  }) async {
    final curUri = Uri.parse(
      '${AppConstants.openWeatherMapBaseUrl}/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey',
    );
    final curRes = await _client.get(curUri);
    if (curRes.statusCode != 200) {
      throw HttpException('OpenWeatherMap current weather error: ${curRes.statusCode}');
    }
    final curData = json.decode(curRes.body) as Map<String, dynamic>;
    final currentWeather = WeatherModel.fromOpenWeatherMapJson(curData);

    // Fetch 5-day / 3-hour forecast
    final forecastUri = Uri.parse(
      '${AppConstants.openWeatherMapBaseUrl}/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey',
    );
    final forecastRes = await _client.get(forecastUri);
    if (forecastRes.statusCode != 200) {
      throw HttpException('OpenWeatherMap forecast error: ${forecastRes.statusCode}');
    }
    final forecastData = json.decode(forecastRes.body) as Map<String, dynamic>;
    final list = (forecastData['list'] as List<dynamic>?) ?? [];

    final hourly = list.take(8).map((item) {
      return HourlyForecastModel.fromOpenWeatherMapJson(item as Map<String, dynamic>);
    }).toList();

    // Group for 5 to 7 days
    final daily = <DailyForecastModel>[];
    // Create daily aggregations from 3-hour slots
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in list) {
      final dtTxt = item['dt_txt'] as String? ?? '';
      final dateKey = dtTxt.split(' ').first;
      grouped.putIfAbsent(dateKey, () => []).add(item as Map<String, dynamic>);
    }

    grouped.forEach((dateStr, items) {
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      double min = 999.0;
      double max = -999.0;
      for (var it in items) {
        final main = it['main'] as Map<String, dynamic>;
        final t = (main['temp'] as num).toDouble();
        if (t < min) min = t;
        if (t > max) max = t;
      }
      final firstWeather = (items.first['weather'] as List<dynamic>).first as Map<String, dynamic>;

      daily.add(
        DailyForecastModel(
          date: date,
          dayName: _getDayName(date.weekday),
          tempMin: min,
          tempMax: max,
          condition: firstWeather['main'] ?? 'Clear',
          description: firstWeather['description'] ?? 'Clear',
          iconCode: firstWeather['icon'] ?? '01d',
          rainProbability: ((items.first['pop'] as num?)?.toDouble() ?? 0 * 100).round(),
          humidity: (items.first['main']['humidity'] as num?)?.toInt() ?? 50,
          windSpeed: (items.first['wind']['speed'] as num?)?.toDouble() ?? 5.0,
          uvIndex: 5.0,
        ),
      );
    });

    return (current: currentWeather, hourly: hourly, daily: daily);
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
      default: return '';
    }
  }

  static Map<String, String> _mapCodeToCondition(int code) {
    if (code == 0) return {'main': 'Clear', 'desc': 'Clear sky'};
    if (code == 1) return {'main': 'Mainly Clear', 'desc': 'Mainly clear'};
    if (code == 2) return {'main': 'Partly Cloudy', 'desc': 'Partly cloudy'};
    if (code == 3) return {'main': 'Overcast', 'desc': 'Overcast'};
    if (code >= 45 && code <= 48) return {'main': 'Fog', 'desc': 'Foggy'};
    if (code >= 51 && code <= 55) return {'main': 'Drizzle', 'desc': 'Light drizzle'};
    if (code >= 61 && code <= 65) return {'main': 'Rain', 'desc': 'Rain showers'};
    if (code >= 71 && code <= 77) return {'main': 'Snow', 'desc': 'Snowfall'};
    if (code >= 80 && code <= 82) return {'main': 'Rain Showers', 'desc': 'Showers'};
    if (code >= 95) return {'main': 'Thunderstorm', 'desc': 'Thunderstorm'};
    return {'main': 'Clear', 'desc': 'Clear'};
  }
}
