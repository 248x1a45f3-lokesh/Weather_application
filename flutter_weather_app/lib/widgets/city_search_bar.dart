import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/city_model.dart';

/// Clean Material 3 Search Bar with live search suggestions and GPS trigger.
class CitySearchBar extends StatefulWidget {
  final VoidCallback onRefresh;
  const CitySearchBar({super.key, required this.onRefresh});

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<CityModel> _suggestions = [];
  bool _isSearching = false;

  void _onQueryChanged(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final provider = context.read<WeatherProvider>();
    final results = await provider.searchCities(query);
    if (mounted) {
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    }
  }

  void _selectCity(CityModel city) {
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _suggestions = []);
    context.read<WeatherProvider>().selectCity(city);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WeatherProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(Icons.search_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search city or airport...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _suggestions = []);
                  },
                ),
              // GPS Button
              IconButton(
                tooltip: 'Current GPS Location',
                icon: const Icon(Icons.my_location_rounded, size: 20),
                color: theme.colorScheme.primary,
                onPressed: () => provider.fetchWeatherForCurrentLocation(),
              ),
              // Refresh Button
              IconButton(
                tooltip: 'Refresh Weather',
                icon: const Icon(Icons.refresh_rounded, size: 20),
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                onPressed: widget.onRefresh,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),

        // Auto-suggestions dropdown
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final city = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined, size: 18),
                  title: Text(
                    city.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    [if (city.state != null) city.state, city.country].where((s) => s != null && s.isNotEmpty).join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: const Icon(Icons.north_west_rounded, size: 16),
                  onTap: () => _selectCity(city),
                );
              },
            ),
          ),
      ],
    );
  }
}
