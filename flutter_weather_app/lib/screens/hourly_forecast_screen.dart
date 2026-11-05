import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_chart.dart';
import '../widgets/hourly_forecast_card.dart';
import '../utils/weather_icons.dart';

/// Screen 2: Detailed 24-Hour Hourly Forecast with interactive fl_chart and tabular breakdown.
class HourlyForecastScreen extends StatelessWidget {
  const HourlyForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();
    final hourly = provider.hourlyForecast;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('24-Hour Forecast', style: TextStyle(fontWeight: FontWeight.w700)),
            Text(
              provider.selectedCity.name,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: provider.isLoading && hourly.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : hourly.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No hourly forecast available'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => provider.refreshWeather(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Smooth fl_chart curve
                      WeatherChart(hourly: hourly),

                      const SizedBox(height: 18),

                      // Horizontal Quick Scroller
                      HourlyForecastCard(hourly: hourly),

                      const SizedBox(height: 18),

                      // Detailed 24-Hour Vertical Table
                      Container(
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
                                Icon(Icons.list_alt_rounded, size: 18, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Hourly Breakdown',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: hourly.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                              ),
                              itemBuilder: (context, index) {
                                final item = hourly[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    children: [
                                      // Time
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          item.formattedHour,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),

                                      // Icon
                                      Icon(
                                        WeatherIconsHelper.getIconData(item.condition, isDay: item.isDay),
                                        size: 22,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 10),

                                      // Condition
                                      Expanded(
                                        child: Text(
                                          item.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // Rain %
                                      SizedBox(
                                        width: 48,
                                        child: Row(
                                          children: [
                                            Icon(Icons.water_drop_rounded, size: 12, color: Colors.blueAccent.shade700),
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
                                      ),

                                      // Wind
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          provider.formatWindSpeed(item.windSpeed),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // Temp
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          provider.formatTemperature(item.temperature),
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
