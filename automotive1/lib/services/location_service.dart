import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

class AppLatLng {
  final double latitude;
  final double longitude;

  const AppLatLng(this.latitude, this.longitude);
}

class LocationResult {
  final AppLatLng coords;
  final String label;

  const LocationResult({required this.coords, required this.label});
}

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  static const AppLatLng defaultKampala = AppLatLng(0.3476, 32.5825);
  AppLatLng? _current;

  AppLatLng get cached => _current ?? defaultKampala;

  Future<LocationResult> locate() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
          _current = AppLatLng(pos.latitude, pos.longitude);
          return LocationResult(
            coords: _current!,
            label: 'GPS position captured',
          );
        }
      }
    } catch (_) {
      // GPS unavailable - fall back to demo coordinates.
    }
    _current = defaultKampala;
    return const LocationResult(
      coords: defaultKampala,
      label: 'Kampala, Uganda (demo location)',
    );
  }

  static double distanceKm(AppLatLng a, AppLatLng b) {
    const double radius = 6371.0;
    final double dLat = _degToRad(b.latitude - a.latitude);
    final double dLon = _degToRad(b.longitude - a.longitude);
    final double h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degToRad(a.latitude)) *
            math.cos(_degToRad(b.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return radius * 2 * math.asin(math.sqrt(h));
  }

  static double _degToRad(double deg) => deg * math.pi / 180.0;
}