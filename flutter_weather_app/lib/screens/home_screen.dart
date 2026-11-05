import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/city_search_bar.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/weather_details_card.dart';

/// Screen 1: Home Dashboard with Current Weather, Search, Hourly preview, and Details.
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const HomeScreen({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_queue_rounded, size: 22),
            SizedBox(width: 8),
            Text('SkyCast', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: onOpenSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refreshWeather(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar with GPS trigger
              CitySearchBar(
                onRefresh: () => provider.refreshWeather(),
              ),

              const SizedBox(height: 18),

              // Loading State
              if (provider.isLoading && provider.currentWeather == null) ...[
                const SizedBox(height: 100),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Fetching live atmospheric data...'),
                    ],
                  ),
                ),
              ]
              // Error State
              else if (provider.errorMessage != null && provider.currentWeather == null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        'Weather Unavailable',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () => provider.refreshWeather(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ]
              // Live Weather Content
              else if (provider.currentWeather != null) ...[
                // Current Weather Card
                CurrentWeatherCard(weather: provider.currentWeather!),

                const SizedBox(height: 18),

                // Hourly Preview
                if (provider.hourlyForecast.isNotEmpty) ...[
                  HourlyForecastCard(hourly: provider.hourlyForecast),
                  const SizedBox(height: 18),
                ],

                // Weather Details (Humidity, Wind, Pressure, etc.)
                WeatherDetailsCard(weather: provider.currentWeather!),

                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
