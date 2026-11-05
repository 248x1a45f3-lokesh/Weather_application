import 'package:intl/intl.dart';

/// Model representing a single hour forecast (for 24h view).
class HourlyForecastModel {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final String iconCode;
  final int rainProbability; // 0-100%
  final double windSpeed; // km/h
  final int humidity;
  final bool isDay;

  const HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.rainProbability,
    required this.windSpeed,
    required this.humidity,
    required this.isDay,
  });

  String get formattedHour => DateFormat('h a').format(time); // e.g. "3 PM"
  String get formatted24Hour => DateFormat('HH:mm').format(time); // e.g. "15:00"

  factory HourlyForecastModel.fromOpenWeatherMapJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final weatherFirst = weatherList.isNotEmpty ? (weatherList.first as Map<String, dynamic>) : <String, dynamic>{};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final dtSec = json['dt'] as int? ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final pop = (json['pop'] as num?)?.toDouble() ?? 0.0;

    return HourlyForecastModel(
      time: DateTime.fromMillisecondsSinceEpoch(dtSec * 1000),
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      condition: weatherFirst['main'] as String? ?? 'Clear',
      description: weatherFirst['description'] as String? ?? 'Clear',
      iconCode: weatherFirst['icon'] as String? ?? '01d',
      rainProbability: (pop * 100).round(),
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      humidity: main['humidity'] as int? ?? 50,
      isDay: (weatherFirst['icon'] as String? ?? 'd').contains('d'),
    );
  }
}

/// Model representing a single day forecast (for 7-day view).
class DailyForecastModel {
  final DateTime date;
  final String dayName; // "Monday", "Today", etc.
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String iconCode;
  final int rainProbability; // 0-100%
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;

  const DailyForecastModel({
    required this.date,
    required this.dayName,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.rainProbability,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    this.sunrise,
    this.sunset,
  });

  String get shortDayName {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return DateFormat('EEE').format(date); // Mon, Tue
  }

  String get formattedDate => DateFormat('MMM d').format(date);
}
