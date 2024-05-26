import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:weather/features/weather/presentation/controllers/page_controller.dart';
import 'package:weather/features/weather/presentation/screens/current_weather.dart';
import 'package:weather/features/weather/presentation/screens/search.dart';
import 'package:weather/features/weather/presentation/screens/settings.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final selectedIndexNotifier = ref.read(selectedIndexProvider.notifier);

    void onItemTapped(int index) {
      selectedIndexNotifier.setIndex(index);
      _pageController.jumpToPage(index);
    }

    String getTitle(selectedIndex) {
      switch (selectedIndex) {
        case 0:
          return 'Weather Today';
        case 1:
          return 'Search Location';
        case 2:
          return '5 Days Forcast';
      }
      return 'Weather App';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle(selectedIndex)),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          selectedIndexNotifier.setIndex(index);
        },
        children: const [
          CurrentWeather(),
          SearchScreen(),
          SettingScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(MingCute.home_4_line),
            selectedIcon: Icon(MingCute.home_4_fill),
            label: 'Weather',
          ),
          NavigationDestination(
            icon: Icon(MingCute.search_3_line),
            selectedIcon: Icon(MingCute.search_3_fill),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(MingCute.settings_1_line),
            selectedIcon: Icon(MingCute.settings_1_fill),
            label: 'settings',
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemTapped,
      ),
    );
  }
}