import 'package:flutter/material.dart';

/// Maps weather condition codes and descriptions to Material Icons and gradient palettes.
class WeatherIconsHelper {
  /// Return appropriate IconData based on condition or WMO weather code
  static IconData getIconData(String condition, {bool isDay = true}) {
    final lower = condition.toLowerCase();
    
    if (lower.contains('thunder') || lower.contains('storm')) {
      return Icons.thunderstorm_rounded;
    } else if (lower.contains('snow') || lower.contains('flurr') || lower.contains('sleet') || lower.contains('blizzard')) {
      return Icons.ac_unit_rounded;
    } else if (lower.contains('drizzle') || lower.contains('shower')) {
      return Icons.grain_rounded;
    } else if (lower.contains('rain')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      if (lower.contains('scattered') || lower.contains('few') || lower.contains('partly')) {
        return isDay ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
      }
      return Icons.cloud_rounded;
    } else if (lower.contains('fog') || lower.contains('mist') || lower.contains('haze')) {
      return Icons.blur_on_rounded;
    } else if (lower.contains('wind')) {
      return Icons.air_rounded;
    } else {
      return isDay ? Icons.wb_sunny_rounded : Icons.bedtime_rounded;
    }
  }

  /// Get color theme gradient for weather cards and dynamic background
  static List<Color> getWeatherGradient(String condition, {bool isDay = true, bool isDarkTheme = false}) {
    final lower = condition.toLowerCase();

    if (!isDay) {
      // Night theme
      return [
        const Color(0xFF0F172A), // Deep Slate Navy
        const Color(0xFF1E293B),
        const Color(0xFF334155),
      ];
    }

    if (lower.contains('thunder') || lower.contains('storm')) {
      return [
        const Color(0xFF1E293B),
        const Color(0xFF475569),
        const Color(0xFF64748B),
      ];
    } else if (lower.contains('rain') || lower.contains('drizzle')) {
      return [
        const Color(0xFF1E3A8A), // Dark blue
        const Color(0xFF3B82F6),
        const Color(0xFF60A5FA),
      ];
    } else if (lower.contains('snow')) {
      return [
        const Color(0xFF475569),
        const Color(0xFF94A3B8),
        const Color(0xFFCBD5E1),
      ];
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      return isDarkTheme
          ? [const Color(0xFF1E293B), const Color(0xFF334155), const Color(0xFF475569)]
          : [const Color(0xFF475569), const Color(0xFF64748B), const Color(0xFF94A3B8)];
    } else {
      // Sunny / Clear
      return [
        const Color(0xFFD97706), // Warm Amber
        const Color(0xFFF59E0B),
        const Color(0xFFFBBF24),
      ];
    }
  }
}
