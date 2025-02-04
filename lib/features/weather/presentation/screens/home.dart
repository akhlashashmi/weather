import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:weather/features/weather/presentation/controllers/internet_checker_controller.dart';
import 'package:weather/features/weather/presentation/controllers/page_controller.dart'; // Import the provider
import 'package:weather/features/weather/presentation/screens/current_weather.dart';
import 'package:weather/features/weather/presentation/screens/search.dart';
import 'package:weather/features/weather/presentation/screens/settings.dart';
import 'package:weather/features/weather/presentation/widgets/error.dart';

import '../../data/repositories/location_service.dart';

final selectedIndexProvider =
    StateNotifierProvider<SelectedIndexNotifier, int>((ref) {
  return SelectedIndexNotifier();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool internetStatus = true;
  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  Future<void> getCurrentLocation() async {
    final Position ps = await LocationService.getCurrentLocation();
    log('oooooooooooooooooooooooooooooooooooooo');
    log('${ps.accuracy}, ${ps.latitude}, ${ps.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(pageControllerProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final selectedIndexNotifier = ref.read(selectedIndexProvider.notifier);
    final internetConnected = ref.watch(isConnectedProvider);

    void onItemTapped(int index) {
      selectedIndexNotifier.setIndex(index);
      pageController.jumpToPage(index);
    }

    return internetConnected.when(
      data: (data) {
        if (!data) {
          return const Scaffold(
            body: ErrorScreen(),
          );
        }
        return Scaffold(
          body: PageView(
            controller: pageController,
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
                label: 'Settings',
              ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemTapped,
          ),
        );
      },
      error: (error, stackTrace) => const CircularProgressIndicator(),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
