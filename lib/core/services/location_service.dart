import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  Future<Position?> getCurrentPosition();
  Future<bool> checkAndRequestPermission();
  Future<bool> isLocationServiceEnabled();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('[LocationService] isLocationServiceEnabled → $enabled');
    return enabled;
  }

  @override
  Future<bool> checkAndRequestPermission() async {
    debugPrint('[LocationService] checkAndRequestPermission — checking service enabled...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[LocationService] Location services are OFF');
      return false;
    }
    debugPrint('[LocationService] Location services are ON');

    debugPrint('[LocationService] Checking current permission...');
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('[LocationService] Current permission: $permission');

    if (permission == LocationPermission.denied) {
      debugPrint('[LocationService] Permission denied — requesting...');
      permission = await Geolocator.requestPermission();
      debugPrint('[LocationService] After request, permission: $permission');
      if (permission == LocationPermission.denied) {
        debugPrint('[LocationService] Permission still denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('[LocationService] Permission denied FOREVER — cannot request');
      return false;
    }

    debugPrint('[LocationService] Permission GRANTED');
    return true;
  }

  @override
  Future<Position?> getCurrentPosition() async {
    debugPrint('[LocationService] getCurrentPosition — requesting fresh GPS fix first...');
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        ),
      );
      debugPrint('[LocationService] Fresh position obtained — lat=${fresh.latitude}, lng=${fresh.longitude}, accuracy=${fresh.accuracy}m');
      return fresh;
    } catch (e) {
      debugPrint('[LocationService] Fresh fix FAILED — $e');
    }

    debugPrint('[LocationService] Falling back to last known position...');
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        debugPrint('[LocationService] Using last known position — lat=${lastKnown.latitude}, lng=${lastKnown.longitude}, accuracy=${lastKnown.accuracy}m');
        return lastKnown;
      }
      debugPrint('[LocationService] No last known position available');
      return null;
    } catch (e) {
      debugPrint('[LocationService] Last known position FAILED — $e');
      return null;
    }
  }
}
