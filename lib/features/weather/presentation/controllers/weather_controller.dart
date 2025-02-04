import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/features/weather/data/models/location.dart';
import 'package:weather/features/weather/data/models/weather_data.dart';
import 'package:weather/features/weather/data/models/weather_forcast.dart';
import 'package:weather/features/weather/data/repositories/location_service.dart';
import 'package:weather/features/weather/data/repositories/weather_service.dart';
import 'package:weather/features/weather/presentation/controllers/current_location_controller.dart';
import 'package:weather/features/weather/utils/hive_constants.dart';

class WeatherRepository {
  final WeatherService weatherService;

  WeatherRepository({required this.weatherService});

  Future<WeatherData> getWeather(String location) {
    return weatherService.fetchWeather(location);
  }

  Future<WeatherData> getWeatherByCoordinates(double lat, double lon) {
    return weatherService.fetchWeatherByCoordinates(lat, lon);
  }

  Future<List<SearchedLocation>> searchLocations(String query) {
    return weatherService.searchLocations(query);
  }

  Future<WeatherForcast> getFiveDayForecast(
      {double? lat, double? lon, String? city}) {
    if (lat != null && lon != null) {
      return weatherService.fetchFiveDayForecast(lat: lat, lon: lon);
    } else {
      return weatherService.fetchFiveDayForecast(city: city);
    }
  }
}

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final weatherService = ref.watch(weatherProvider);
  return WeatherRepository(weatherService: weatherService);
});

final currentWeatherProvider =
    FutureProvider.family<WeatherData, String>((ref, location) {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getWeather(location);
});

final coordinatesWeatherProvider =
    FutureProvider.family<WeatherData, List<double>>((ref, coordinates) {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getWeatherByCoordinates(coordinates[0], coordinates[1]);
});

final searchLocationsProvider =
    FutureProvider.family<List<SearchedLocation>, String>((ref, query) {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.searchLocations(query);
});

final fiveDayForecastProvider =
    FutureProvider.family<WeatherForcast, dynamic>((ref, data) {
  final repository = ref.watch(weatherRepositoryProvider);
  
  // If the data is a city name, use it to fetch the forecast, other vise 
  if (data is String) {
    return repository.getFiveDayForecast( city: data); 
  } else if (data is List<double>) {
    return repository.getFiveDayForecast(lat: data[0], lon: data[1]);
  } else {
    throw Exception('Invalid data type for fiveDayForecastProvider');
  }
});

// Provider for the current location coordinates
final currentLocationCoordsProvider = FutureProvider<Position>((ref) async {
  try {
    final position = await LocationService.determinePosition();
    return position;
  } catch (e) {
    throw Exception('Failed to get location: $e');
  }
});

// Provider for weather based on coordinates
final weatherByLocationProvider = FutureProvider<WeatherForcast>((ref) async {
  try {
    final position = await ref.watch(currentLocationCoordsProvider.future);
    final repository = ref.watch(weatherRepositoryProvider);
    return await repository.getFiveDayForecast(
      lat: position.latitude,
      lon: position.longitude,
    );
  } catch (e) {
    // If location fails, fall back to default location
    final currentLocation = ref.watch(currentLocationProvider(HiveBoxes.preferences));
    final repository = ref.watch(weatherRepositoryProvider);
    return await repository.getFiveDayForecast(city: currentLocation);
  }
});
