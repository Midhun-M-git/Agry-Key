import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../core/app_state.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String district;
  final String state;
  final String source;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.district,
    required this.state,
    required this.source,
  });
}

class LocationService {
  /// Fetches physical GPS position with fast cache check & 5s timeout.
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await Geolocator.getLastKnownPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return await Geolocator.getLastKnownPosition();
      }

      // Check fast last known position first (instant response)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return lastKnown;
      }

      // Fetch fresh GPS position with 5-second timeout
      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  static Future<Position?> getCurrentPosition() => getCurrentLocation();

  /// Resolves location from network IP if hardware GPS is unavailable or permission denied.
  static Future<Map<String, dynamic>?> getIpLocation() async {
    try {
      final res = await http.get(Uri.parse('http://ip-api.com/json')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'success') {
          final lat = (data['lat'] as num?)?.toDouble() ?? 9.9406;
          final lon = (data['lon'] as num?)?.toDouble() ?? 76.2653;
          final city = data['city']?.toString() ?? 'Kochi';
          final region = data['regionName']?.toString() ?? 'Kerala';
          return {
            'lat': lat,
            'lon': lon,
            'district': city,
            'state': region,
          };
        }
      }
    } catch (_) {}
    return null;
  }

  /// Master resolver: GPS -> Network IP -> Cached/Default.
  /// Automatically updates AppState so weather, crop advisory, and market use the real location.
  static Future<LocationResult> resolveRealLocation() async {
    // 1. Try Hardware GPS
    try {
      final pos = await getCurrentLocation();
      if (pos != null) {
        String dist = '';
        String st = '';
        try {
          final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            dist = p.subAdministrativeArea?.isNotEmpty == true
                ? p.subAdministrativeArea!
                : (p.locality?.isNotEmpty == true ? p.locality! : '');
            st = p.administrativeArea?.isNotEmpty == true ? p.administrativeArea! : '';
          }
        } catch (_) {}

        if (dist.isEmpty) dist = AppState.district.isNotEmpty ? AppState.district : 'Kochi';
        if (st.isEmpty) st = AppState.state.isNotEmpty ? AppState.state : 'Kerala';

        _syncAppState(pos.latitude, pos.longitude, dist, st);
        return LocationResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          district: dist,
          state: st,
          source: 'GPS',
        );
      }
    } catch (e) {
      debugPrint('[LocationService] GPS resolution error: $e');
    }

    // 2. Try Network IP Geolocation
    try {
      final ipLoc = await getIpLocation();
      if (ipLoc != null) {
        final lat = ipLoc['lat'] as double;
        final lon = ipLoc['lon'] as double;
        final dist = ipLoc['district'] as String;
        final st = ipLoc['state'] as String;

        _syncAppState(lat, lon, dist, st);
        return LocationResult(
          latitude: lat,
          longitude: lon,
          district: dist,
          state: st,
          source: 'NETWORK_IP',
        );
      }
    } catch (e) {
      debugPrint('[LocationService] IP resolution error: $e');
    }

    // 3. Fallback to AppState or real regional defaults
    final lat = AppState.latitude != 0.0 ? AppState.latitude : 9.9406;
    final lon = AppState.longitude != 0.0 ? AppState.longitude : 76.2653;
    final dist = AppState.district.isNotEmpty ? AppState.district : 'Kochi';
    final st = AppState.state.isNotEmpty ? AppState.state : 'Kerala';

    _syncAppState(lat, lon, dist, st);
    return LocationResult(
      latitude: lat,
      longitude: lon,
      district: dist,
      state: st,
      source: 'OFFLINE_CACHE',
    );
  }

  static void _syncAppState(double lat, double lon, String dist, String st) {
    AppState.latitude = lat;
    AppState.longitude = lon;
    AppState.userLatitude = lat;
    AppState.userLongitude = lon;
    AppState.district = dist;
    AppState.state = st;
    AppState.userDistrict = dist;
    AppState.userState = st;
    if (AppState.userLocation.isEmpty) {
      AppState.userLocation = '$dist, $st';
    }
  }
}