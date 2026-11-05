import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_icons.dart';

/// Interactive 7-Day Forecast row card with temperature range bar and detailed dialog.
class DailyForecastCard extends StatelessWidget {
  final DailyForecastModel daily;
  final double globalMin;
  final double globalMax;

  const DailyForecastCard({
    super.key,
    required this.daily,
    required this.globalMin,
    required this.globalMax,
  });

  void _showDayDetails(BuildContext context, WeatherProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        daily.dayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        daily.formattedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    WeatherIconsHelper.getIconData(daily.condition),
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _modalRow('Condition', '${daily.condition} (${daily.description})'),
                    const Divider(height: 18),
                    _modalRow('High / Low', '${provider.formatTemperature(daily.tempMax)} / ${provider.formatTemperature(daily.tempMin)}'),
                    const Divider(height: 18),
                    _modalRow('Rain Probability', '${daily.rainProbability}%'),
                    const Divider(height: 18),
                    _modalRow('Max Wind Speed', provider.formatWindSpeed(daily.windSpeed)),
                    const Divider(height: 18),
                    _modalRow('Peak UV Index', daily.uvIndex.toStringAsFixed(1)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _modalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    return InkWell(
      onTap: () => _showDayDetails(context, provider),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Day Label
            SizedBox(
              width: 80,
              child: Text(
                daily.dayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

            // Icon + Rain prob
            SizedBox(
              width: 64,
              child: Row(
                children: [
                  Icon(
                    WeatherIconsHelper.getIconData(daily.condition),
                    size: 22,
                    color: theme.colorScheme.onSurface,
                  ),
                  if (daily.rainProbability > 20) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${daily.rainProbability}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Min Temp
            SizedBox(
              width: 36,
              child: Text(
                provider.formatTemperature(daily.tempMin),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Visual Range Bar
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalRange = (globalMax - globalMin) <= 0 ? 1.0 : (globalMax - globalMin);
                  final leftRatio = ((daily.tempMin - globalMin) / totalRange).clamp(0.0, 1.0);
                  final rightRatio = ((daily.tempMax - globalMin) / totalRange).clamp(0.0, 1.0);

                  return Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: constraints.maxWidth * leftRatio,
                          right: constraints.maxWidth * (1.0 - rightRatio),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF38BDF8), Color(0xFFF59E0B)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            // Max Temp
            SizedBox(
              width: 36,
              child: Text(
                provider.formatTemperature(daily.tempMax),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
