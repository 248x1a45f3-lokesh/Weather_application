import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skycast_weather/models/city_model.dart';
import 'package:skycast_weather/models/weather_model.dart';
import 'package:skycast_weather/providers/weather_provider.dart';
import 'package:skycast_weather/screens/home_screen.dart';
import 'package:skycast_weather/widgets/current_weather_card.dart';

void main() {
  group('SkyCast Weather App Tests', () {
    testWidgets('CurrentWeatherCard displays correct city, temperature, and condition', (WidgetTester tester) async {
      final mockWeather = WeatherModel(
        cityName: 'San Francisco',
        country: 'US',
        temperature: 21.4,
        feelsLike: 20.8,
        tempMin: 18.0,
        tempMax: 24.0,
        condition: 'Clear',
        description: 'Sunny skies',
        iconCode: '01d',
        humidity: 62,
        windSpeed: 14.5,
        windDirection: 270,
        pressure: 1014,
        visibility: 10.0,
        sunrise: DateTime.now().subtract(const Duration(hours: 4)),
        sunset: DateTime.now().add(const Duration(hours: 8)),
        uvIndex: 5.8,
        isDay: true,
        timestamp: DateTime.now(),
      );

      final provider = WeatherProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<WeatherProvider>.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: CurrentWeatherCard(weather: mockWeather),
            ),
          ),
        ),
      );

      // Verify City name is displayed
      expect(find.text('San Francisco'), findsOneWidget);

      // Verify Weather description is displayed
      expect(find.text('Sunny skies'), findsOneWidget);

      // Verify temperature is displayed in Celsius by default (21°C)
      expect(find.text('21°C'), findsOneWidget);

      // Verify feels like is displayed
      expect(find.text('Feels like 21°C'), findsOneWidget);
    });

    test('WeatherProvider converts Celsius to Fahrenheit correctly', () {
      final provider = WeatherProvider();
      
      // Default is Celsius
      expect(provider.formatTemperature(25.0), '25°C');

      // Switch to Imperial
      provider.setTemperatureUnit('imperial');
      // 25°C = (25 * 9/5) + 32 = 77°F
      expect(provider.formatTemperature(25.0), '77°F');
    });

    test('CityModel serialization and equality logic', () {
      const city1 = CityModel(name: 'Paris', latitude: 48.8566, longitude: 2.3522, country: 'France');
      const city2 = CityModel(name: 'paris', latitude: 48.8566, longitude: 2.3522, country: 'FRANCE');
      
      expect(city1 == city2, isTrue);

      final json = city1.toJson();
      final cityFromJson = CityModel.fromJson(json);
      expect(cityFromJson.name, 'Paris');
      expect(cityFromJson.latitude, 48.8566);
    });
  });
}
