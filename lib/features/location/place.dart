/// A point on the map with a human-readable label.
class Place {
  final double latitude;
  final double longitude;

  /// Short label shown in the UI, e.g. "Main Street 12, Downtown, Erbil".
  final String label;

  /// The full address line from the geocoder, when available.
  final String fullLabel;

  const Place({
    required this.latitude,
    required this.longitude,
    required this.label,
    String? fullLabel,
  }) : fullLabel = fullLabel ?? label;

  factory Place.fromApi(Map<String, dynamic> map) {
    final lat = (map['latitude'] as num).toDouble();
    final lng = (map['longitude'] as num).toDouble();
    final label = map['label']?.toString() ?? '';
    return Place(
      latitude: lat,
      longitude: lng,
      label: label.isEmpty ? coordinatesLabel(lat, lng) : label,
      fullLabel: map['fullLabel']?.toString(),
    );
  }

  static String coordinatesLabel(double lat, double lng) =>
      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';

  String get coordinates => coordinatesLabel(latitude, longitude);

  Place copyWith({String? label}) => Place(
        latitude: latitude,
        longitude: longitude,
        label: label ?? this.label,
        fullLabel: fullLabel,
      );
}
