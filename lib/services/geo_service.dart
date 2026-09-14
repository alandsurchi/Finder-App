import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../core/errors/exceptions.dart';
import '../core/network/api_client.dart';
import '../features/location/place.dart';

/// Geocoding (through the Finder API, which proxies OpenStreetMap) and the
/// device's own position.
class GeoService {
  final ApiClient _api;

  GeoService({required ApiClient apiClient}) : _api = apiClient;

  /// Places matching a free-text query. Empty for very short queries.
  Future<List<Place>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    final res = await _api.get('/geo/search?q=${Uri.encodeQueryComponent(q)}');
    if (res is! List) return const [];
    return res
        .whereType<Map>()
        .map((m) => Place.fromApi(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// The address at a point.
  Future<Place> reverse(double latitude, double longitude) async {
    final res = await _api.get('/geo/reverse?lat=$latitude&lon=$longitude');
    if (res is Map) return Place.fromApi(Map<String, dynamic>.from(res));
    return Place(
      latitude: latitude,
      longitude: longitude,
      label: Place.coordinatesLabel(latitude, longitude),
    );
  }

  /// Like [reverse], but never throws: falls back to the raw coordinates.
  Future<Place> reverseOrCoordinates(double latitude, double longitude) async {
    try {
      return await reverse(latitude, longitude);
    } catch (_) {
      return Place(
        latitude: latitude,
        longitude: longitude,
        label: Place.coordinatesLabel(latitude, longitude),
      );
    }
  }

  /// The device position with its address. Throws a [ValidationException]
  /// with a user-facing message when location is off or not permitted.
  Future<Place> currentPlace() async {
    final pos = await currentPosition();
    return reverseOrCoordinates(pos.latitude, pos.longitude);
  }

  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ValidationException(
        'Turn on location services (GPS) to use your current location.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const ValidationException(
        'Location access is blocked. Allow it in your phone settings to use your current location.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw const ValidationException('Location permission was not granted.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      final last = await _lastKnown();
      if (last != null) return last;
      throw const ValidationException(
        'Could not get a GPS fix. Move somewhere with a clearer view of the sky and try again.',
      );
    }
  }

  Future<Position?> _lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null; // Not supported on every platform.
    }
  }
}
