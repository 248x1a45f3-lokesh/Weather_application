import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/city_model.dart';
import '../utils/weather_icons.dart';

/// Screen 4: Saved Favorite Cities management with live condition cards.
class SavedCitiesScreen extends StatefulWidget {
  final VoidCallback onCitySelected;

  const SavedCitiesScreen({super.key, required this.onCitySelected});

  @override
  State<SavedCitiesScreen> createState() => _SavedCitiesScreenState();
}

class _SavedCitiesScreenState extends State<SavedCitiesScreen> {
  void _openAddCityDialog(BuildContext context) {
    final searchController = TextEditingController();
    List<CityModel> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Add Favorite City',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: (val) async {
                      if (val.trim().length < 2) {
                        setModalState(() {
                          searchResults = [];
                          isSearching = false;
                        });
                        return;
                      }
                      setModalState(() => isSearching = true);
                      final results = await context.read<WeatherProvider>().searchCities(val);
                      setModalState(() {
                        searchResults = results;
                        isSearching = false;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search city name...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isSearching)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: searchResults.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, index) {
                          final city = searchResults[index];
                          final isAlreadySaved = context.read<WeatherProvider>().isCitySaved(city);

                          return ListTile(
                            leading: const Icon(Icons.location_city_rounded),
                            title: Text(city.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text([if (city.state != null) city.state, city.country].where((s) => s != null && s.isNotEmpty).join(', ')),
                            trailing: isAlreadySaved
                                ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                : const Icon(Icons.add_circle_outline_rounded),
                            onTap: () async {
                              if (!isAlreadySaved) {
                                await context.read<WeatherProvider>().addCityToSaved(city);
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();
    final savedCities = provider.savedCities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cities', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Add City',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openAddCityDialog(context),
          ),
        ],
      ),
      body: savedCities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 54, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved cities yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add cities you visit often for quick weather updates.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _openAddCityDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Favorite City'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: savedCities.length,
              itemBuilder: (context, index) {
                final city = savedCities[index];
                final weather = provider.savedCitiesWeather[city.name.toLowerCase()];
                final isSelected = provider.selectedCity.name.toLowerCase() == city.name.toLowerCase();

                return Dismissible(
                  key: Key(city.name + city.country),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                  ),
                  onDismissed: (_) {
                    provider.removeCityFromSaved(city);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${city.name} removed from favorites'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        provider.selectCity(city);
                        widget.onCitySelected();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        child: Row(
                          children: [
                            // Left Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        city.name,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'ACTIVE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    city.country,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  if (weather != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      '${weather.condition} · H: ${provider.formatTemperature(weather.tempMax)} L: ${provider.formatTemperature(weather.tempMin)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Right Weather Icon & Temp
                            if (weather != null) ...[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    WeatherIconsHelper.getIconData(weather.condition, isDay: weather.isDay),
                                    size: 32,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.formatTemperature(weather.temperature),
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ] else ...[
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ],

                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 20),
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              onPressed: () => provider.removeCityFromSaved(city),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
