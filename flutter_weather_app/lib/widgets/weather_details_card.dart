import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

/// Clean grid card displaying detailed meteorological stats.
class WeatherDetailsCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    final sunriseStr = DateFormat('h:mm a').format(weather.sunrise);
    final sunsetStr = DateFormat('h:mm a').format(weather.sunset);

    final items = [
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'Humidity',
        value: '${weather.humidity}%',
        subtext: 'Dew point ~${(weather.temperature - ((100 - weather.humidity) / 5)).round()}°',
      ),
      _DetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value: provider.formatWindSpeed(weather.windSpeed),
        subtext: '${weather.windCompassDirection} · ${weather.windDirection}°',
      ),
      _DetailItem(
        icon: Icons.speed_rounded,
        label: 'Pressure',
        value: '${weather.pressure} hPa',
        subtext: weather.pressure > 1013 ? 'High pressure' : 'Normal pressure',
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: 'Visibility',
        value: '${weather.visibility.toStringAsFixed(1)} km',
        subtext: weather.visibility >= 10 ? 'Clear view' : 'Limited view',
      ),
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        label: 'Sunrise / Sunset',
        value: sunriseStr,
        subtext: 'Sunset $sunsetStr',
      ),
      _DetailItem(
        icon: Icons.light_mode_outlined,
        label: 'UV Index',
        value: weather.uvIndex.toStringAsFixed(1),
        subtext: weather.uvIndex >= 6 ? 'High UV alert' : 'Moderate',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Weather Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.6,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final it = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(it.icon, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          it.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      it.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      it.subtext,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String subtext;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtext,
  });
}
