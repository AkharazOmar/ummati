import 'dart:math';

/// Calculates Qibla direction using the geodesic formula.
///
/// The Qibla direction is the bearing from a given location to the Kaaba
/// in Mecca (latitude 21.4225°N, longitude 39.8262°E).
class QiblaCalculator {
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  /// Returns the Qibla bearing in degrees from North (0-360).
  ///
  /// Uses the forward azimuth formula from the great-circle navigation:
  /// θ = atan2(sin(ΔL)·cos(φ₂), cos(φ₁)·sin(φ₂) − sin(φ₁)·cos(φ₂)·cos(ΔL))
  static double calculate(double latitude, double longitude) {
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(_kaabaLatitude);
    final deltaLng = _toRadians(_kaabaLongitude - longitude);

    final y = sin(deltaLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);

    final bearing = atan2(y, x);
    return (_toDegrees(bearing) + 360) % 360;
  }

  /// Distance to Kaaba in kilometers using the Haversine formula.
  static double distanceToKaaba(double latitude, double longitude) {
    const earthRadius = 6371.0;

    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(_kaabaLatitude);
    final deltaLat = _toRadians(_kaabaLatitude - latitude);
    final deltaLng = _toRadians(_kaabaLongitude - longitude);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
  static double _toDegrees(double radians) => radians * 180 / pi;
}
