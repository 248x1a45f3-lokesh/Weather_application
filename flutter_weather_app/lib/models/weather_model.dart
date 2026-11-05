/// Complete weather model holding real-time atmospheric measurements.
class WeatherModel {
  final String cityName;
  final String country;
  final double temperature; // In Celsius by default
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity; // In percentage
  final double windSpeed; // km/h or m/s based on provider
  final int windDirection; // degrees (0-360)
  final int pressure; // hPa
  final double visibility; // km
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndex;
  final bool isDay;
  final DateTime timestamp;

  const WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.sunrise,
    required this.sunset,
    required this.uvIndex,
    required this.isDay,
    required this.timestamp,
  });

  /// Factory constructor for OpenWeatherMap standard JSON response
  factory WeatherModel.fromOpenWeatherMapJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final weatherFirst = weatherList.isNotEmpty ? (weatherList.first as Map<String, dynamic>) : <String, dynamic>{};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    final sunriseSec = sys['sunrise'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final sunsetSec = sys['sunset'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 43200);
    final dtSec = json['dt'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

    return WeatherModel(
      cityName: json['name'] as String? ?? 'Current Location',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      condition: weatherFirst['main'] as String? ?? 'Clear',
      description: weatherFirst['description'] as String? ?? 'Clear Sky',
      iconCode: weatherFirst['icon'] as String? ?? '01d',
      humidity: main['humidity'] as int? ?? 50,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: wind['deg'] as int? ?? 0,
      pressure: main['pressure'] as int? ?? 1013,
      visibility: ((json['visibility'] as num?)?.toDouble() ?? 10000) / 1000,
      sunrise: DateTime.fromMillisecondsSinceEpoch(sunriseSec * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(sunsetSec * 1000),
      uvIndex: 4.5,
      isDay: (weatherFirst['icon'] as String? ?? 'd').contains('d'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(dtSec * 1000),
    );
  }

  /// Factory constructor for Open-Meteo response
  factory WeatherModel.fromOpenMeteo({
    required Map<String, dynamic> current,
    required Map<String, dynamic> daily,
    required String cityName,
    required String country,
  }) {
    final now = DateTime.now();
    final weatherCode = current['weather_code'] as int? ?? 0;
    final conditionMap = _mapWmoCode(weatherCode);
    final isDay = (current['is_day'] as int? ?? 1) == 1;

    DateTime sunrise = now;
    DateTime sunset = now.add(const Duration(hours: 12));
    final sunriseList = daily['sunrise'] as List<dynamic>?;
    final sunsetList = daily['sunset'] as List<dynamic>?;
    if (sunriseList != null && sunriseList.isNotEmpty) {
      sunrise = DateTime.tryParse(sunriseList.first.toString()) ?? sunrise;
    }
    if (sunsetList != null && sunsetList.isNotEmpty) {
      sunset = DateTime.tryParse(sunsetList.first.toString()) ?? sunset;
    }

    final tempMaxList = daily['temperature_2m_max'] as List<dynamic>?;
    final tempMinList = daily['temperature_2m_min'] as List<dynamic>?;
    final uvList = daily['uv_index_max'] as List<dynamic>?;

    return WeatherModel(
      cityName: cityName,
      country: country,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 20.0,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 20.0,
      tempMin: tempMinList != null && tempMinList.isNotEmpty ? (tempMinList.first as num).toDouble() : 15.0,
      tempMax: tempMaxList != null && tempMaxList.isNotEmpty ? (tempMaxList.first as num).toDouble() : 25.0,
      condition: conditionMap['main'] ?? 'Clear',
      description: conditionMap['desc'] ?? 'Clear Sky',
      iconCode: isDay ? '01d' : '01n',
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 50,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      windDirection: (current['wind_direction_10m'] as num?)?.toInt() ?? 0,
      pressure: (current['surface_pressure'] as num?)?.toInt() ?? 1013,
      visibility: 10.0,
      sunrise: sunrise,
      sunset: sunset,
      uvIndex: uvList != null && uvList.isNotEmpty ? (uvList.first as num).toDouble() : 5.0,
      isDay: isDay,
      timestamp: now,
    );
  }

  static Map<String, String> _mapWmoCode(int code) {
    if (code == 0) return {'main': 'Clear', 'desc': 'Clear sky'};
    if (code == 1) return {'main': 'Mainly Clear', 'desc': 'Mainly clear'};
    if (code == 2) return {'main': 'Partly Cloudy', 'desc': 'Partly cloudy'};
    if (code == 3) return {'main': 'Overcast', 'desc': 'Overcast'};
    if (code >= 45 && code <= 48) return {'main': 'Fog', 'desc': 'Foggy conditions'};
    if (code >= 51 && code <= 55) return {'main': 'Drizzle', 'desc': 'Light drizzle'};
    if (code >= 61 && code <= 65) return {'main': 'Rain', 'desc': 'Rain showers'};
    if (code >= 71 && code <= 77) return {'main': 'Snow', 'desc': 'Snowfall'};
    if (code >= 80 && code <= 82) return {'main': 'Rain Showers', 'desc': 'Heavy rain showers'};
    if (code >= 85 && code <= 86) return {'main': 'Snow Showers', 'desc': 'Snow showers'};
    if (code >= 95) return {'main': 'Thunderstorm', 'desc': 'Thunderstorm'};
    return {'main': 'Clear', 'desc': 'Clear sky'};
  }

  String get windCompassDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((windDirection + 22.5) % 360 / 45).floor();
    return directions[index % 8];
  }
}
