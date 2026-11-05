import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_icons.dart';

/// Horizontally scrollable hourly card showing time, condition icon, temp, rain %, wind.
class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecastModel> hourly;

  const HourlyForecastCard({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    if (hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Next 24 Hours',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 136,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final item = hourly[index];
                final isCurrent = index == 0;

                return Container(
                  width: 84,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent
                          ? theme.colorScheme.primary.withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCurrent ? 'Now' : item.formattedHour,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        WeatherIconsHelper.getIconData(item.condition, isDay: item.isDay),
                        size: 26,
                        color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                      Text(
                        provider.formatTemperature(item.temperature),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Rain probability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_rounded,
                            size: 11,
                            color: Colors.blueAccent.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${item.rainProbability}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
