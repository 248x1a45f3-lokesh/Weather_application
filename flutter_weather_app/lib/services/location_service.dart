import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/city_model.dart';
import '../utils/constants.dart';

/// LocationService manages device GPS permissions and coordinates resolution.
class LocationService {
  /// Request GPS location and reverse geocode to CityModel
  Future<CityModel> getCurrentLocationCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can get position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );

    String cityName = AppConstants.defaultCityName;
    String country = AppConstants.defaultCountry;
    String? state;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        cityName = place.locality?.isNotEmpty == true
            ? place.locality!
            : (place.subAdministrativeArea?.isNotEmpty == true
                ? place.subAdministrativeArea!
                : place.administrativeArea ?? 'Current Location');
        country = place.country ?? place.isoCountryCode ?? '';
        state = place.administrativeArea;
      }
    } catch (_) {
      // Keep default name if reverse geocoding fails
      cityName = 'Current Location';
    }

    return CityModel(
      name: cityName,
      latitude: position.latitude,
      longitude: position.longitude,
      country: country,
      state: state,
    );
  }
}
