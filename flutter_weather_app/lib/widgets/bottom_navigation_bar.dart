import 'package:flutter/material.dart';

/// Material 3 Bottom Navigation Bar with 4 primary destinations.
class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      elevation: 3,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.wb_sunny_outlined),
          selectedIcon: Icon(Icons.wb_sunny_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.access_time_rounded),
          selectedIcon: Icon(Icons.access_time_filled_rounded),
          label: 'Hourly',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: '7-Day',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline_rounded),
          selectedIcon: Icon(Icons.favorite_rounded),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}
