import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/constants.dart';

/// Screen 5: Settings Screen for units, theme, location permissions, and API key.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch stored api key
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final key = await context.read<WeatherProvider>().searchCities('');
    });
  }

  void _showApiKeyDialog(BuildContext context, WeatherProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('OpenWeatherMap API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'By default, SkyCast uses Open-Meteo with live weather data requiring zero configuration. Enter your personal key if you prefer OpenWeatherMap.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key (optional)',
                  hintText: 'Enter 32-character key',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _apiKeyController.clear();
                provider.setCustomApiKey(null);
                Navigator.pop(context);
              },
              child: const Text('Reset / Clear'),
            ),
            FilledButton(
              onPressed: () {
                final key = _apiKeyController.text.trim();
                provider.setCustomApiKey(key.isNotEmpty ? key : null);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        children: [
          // Section: Units
          _sectionHeader('Units & Preferences'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.thermostat_rounded),
                  title: const Text('Temperature Unit'),
                  subtitle: Text(provider.isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: AppConstants.unitCelsius, label: Text('°C')),
                      ButtonSegment(value: AppConstants.unitFahrenheit, label: Text('°F')),
                    ],
                    selected: {provider.temperatureUnit},
                    onSelectionChanged: (set) {
                      provider.setTemperatureUnit(set.first);
                    },
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.air_rounded),
                  title: const Text('Wind Speed Unit'),
                  subtitle: Text(provider.windSpeedUnit),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: AppConstants.unitKmh, label: Text('km/h')),
                      ButtonSegment(value: AppConstants.unitMs, label: Text('m/s')),
                    ],
                    selected: {provider.windSpeedUnit},
                    onSelectionChanged: (set) {
                      provider.setWindSpeedUnit(set.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Appearance
          _sectionHeader('Appearance'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: provider.themeMode,
                  onChanged: (val) => provider.setThemeMode(val!),
                  title: const Text('System Default'),
                  secondary: const Icon(Icons.brightness_auto_rounded),
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: provider.themeMode,
                  onChanged: (val) => provider.setThemeMode(val!),
                  title: const Text('Light Theme'),
                  secondary: const Icon(Icons.light_mode_rounded),
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: provider.themeMode,
                  onChanged: (val) => provider.setThemeMode(val!),
                  title: const Text('Dark Theme'),
                  secondary: const Icon(Icons.dark_mode_rounded),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: Location & API
          _sectionHeader('Location & Weather Service'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.gps_fixed_rounded),
                  title: const Text('Location Permissions'),
                  subtitle: const Text('Open Android system app settings'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () async {
                    await Geolocator.openAppSettings();
                  },
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.vpn_key_rounded),
                  title: const Text('Custom API Key'),
                  subtitle: const Text('OpenWeatherMap API Key configuration'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showApiKeyDialog(context, provider),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: App Information
          _sectionHeader('About SkyCast'),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Version'),
                  trailing: Text(
                    '${AppConstants.appVersion} (${AppConstants.buildNumber})',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ListTile(
                  leading: const Icon(Icons.cloud_done_rounded),
                  title: const Text('Data Providers'),
                  trailing: Text(
                    'Open-Meteo & OpenWeatherMap',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                const ListTile(
                  leading: Icon(Icons.flutter_dash_rounded),
                  title: Text('Framework'),
                  trailing: Text(
                    'Flutter 3.35 · Dart 3',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: Colors.grey,
        ),
      ),
    );
  }
}
