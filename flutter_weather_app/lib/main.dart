import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/weather_provider.dart';
import 'services/weather_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/hourly_forecast_screen.dart';
import 'screens/weekly_forecast_screen.dart';
import 'screens/saved_cities_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Android system UI overlay styles
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize persistent storage
  final storageService = StorageService();
  await storageService.init();

  final weatherService = WeatherService();
  final locationService = LocationService();

  final weatherProvider = WeatherProvider(
    weatherService: weatherService,
    locationService: locationService,
    storageService: storageService,
  );

  // Kick off initial weather fetch
  await weatherProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: weatherProvider,
      child: const SkyCastWeatherApp(),
    ),
  );
}

/// Root Application Widget with dynamic theme support.
class SkyCastWeatherApp extends StatelessWidget {
  const SkyCastWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    return MaterialApp(
      title: 'SkyCast Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: weatherProvider.themeMode,
      home: const MainNavigationShell(),
    );
  }
}

/// Main Shell holding the Bottom Navigation Bar and active screen index.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToHome() {
    setState(() => _currentIndex = 0);
  }

  void _navigateToSettings() {
    setState(() => _currentIndex = 4);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onOpenSettings: _navigateToSettings),
      const HourlyForecastScreen(),
      const WeeklyForecastScreen(),
      SavedCitiesScreen(onCitySelected: _navigateToHome),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
