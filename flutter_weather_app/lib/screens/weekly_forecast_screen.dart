import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/daily_forecast_card.dart';

/// Screen 3: 7-Day Extended Forecast with high/low temperature spectrum and detail modal.
class WeeklyForecastScreen extends StatelessWidget {
  const WeeklyForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();
    final daily = provider.weeklyForecast;

    double globalMin = 100.0;
    double globalMax = -100.0;
    for (var item in daily) {
      if (item.tempMin < globalMin) globalMin = item.tempMin;
      if (item.tempMax > globalMax) globalMax = item.tempMax;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('7-Day Forecast', style: TextStyle(fontWeight: FontWeight.w700)),
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
      body: provider.isLoading && daily.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : daily.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No 7-day forecast data available'),
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
                      // Instructions banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.touch_app_rounded, size: 18, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap any day to see detailed atmospheric metrics, wind peaks, and UV exposure.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 7-Day Card Container
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: daily.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: theme.colorScheme.outline.withValues(alpha: 0.25),
                          ),
                          itemBuilder: (context, index) {
                            return DailyForecastCard(
                              daily: daily[index],
                              globalMin: globalMin,
                              globalMax: globalMax,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}
