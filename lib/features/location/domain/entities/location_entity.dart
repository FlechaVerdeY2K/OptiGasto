import 'dart:math';
import 'package:equatable/equatable.dart';

/// Entidad de ubicación en la capa de dominio
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        altitude,
        heading,
        speed,
        timestamp,
      ];

  /// Calcula la distancia en kilómetros a otra ubicación usando la fórmula de Haversine
  double distanceTo(LocationEntity other) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    final double lat1Rad = latitude * (3.141592653589793 / 180);
    final double lat2Rad = other.latitude * (3.141592653589793 / 180);
    final double deltaLat =
        (other.latitude - latitude) * (3.141592653589793 / 180);
    final double deltaLon =
        (other.longitude - longitude) * (3.141592653589793 / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Verifica si la ubicación está dentro de un radio específico (en km)
  bool isWithinRadius(LocationEntity center, double radiusKm) {
    return distanceTo(center) <= radiusKm;
  }

  /// Copia la entidad con campos actualizados
  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    DateTime? timestamp,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'LocationEntity(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

// Made with Bob
