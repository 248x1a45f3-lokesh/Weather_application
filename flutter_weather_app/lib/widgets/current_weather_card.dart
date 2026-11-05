import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_icons.dart';

/// Visually attractive Material 3 current weather hero card with dynamic gradient.
class CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final isSaved = provider.isCitySaved(provider.selectedCity);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = WeatherIconsHelper.getWeatherGradient(
      weather.condition,
      isDay: weather.isDay,
      isDarkTheme: isDark,
    );

    final formattedDate = DateFormat('EEEE, MMMM d').format(weather.timestamp);
    final formattedTime = DateFormat('h:mm a').format(weather.timestamp);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: City, Country, and Favorite Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            weather.cityName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        '$formattedDate · $formattedTime',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isSaved ? Colors.pinkAccent : Colors.white,
                  size: 24,
                ),
                tooltip: isSaved ? 'Remove from favorites' : 'Save to favorites',
                onPressed: () => provider.toggleFavorite(provider.selectedCity),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Temperature and Weather Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.formatTemperature(weather.temperature),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weather.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Large Icon
              Icon(
                WeatherIconsHelper.getIconData(weather.condition, isDay: weather.isDay),
                size: 72,
                color: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Divider
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),

          const SizedBox(height: 16),

          // Footer Metrics: Feels Like, Min / Max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feels like ${provider.formatTemperature(weather.feelsLike)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'H: ${provider.formatTemperature(weather.tempMax)}   L: ${provider.formatTemperature(weather.tempMin)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
