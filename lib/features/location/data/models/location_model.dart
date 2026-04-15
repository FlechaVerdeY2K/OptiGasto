import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_entity.dart';

/// Modelo de ubicación para la capa de datos
class LocationModel extends LocationEntity {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.heading,
    super.speed,
    required super.timestamp,
  });

  /// Crea un LocationModel desde un LocationEntity
  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      heading: entity.heading,
      speed: entity.speed,
      timestamp: entity.timestamp,
    );
  }

  /// Crea un LocationModel desde un Map de Supabase
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      heading:
          json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  /// Convierte el modelo a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crea un LocationModel desde datos de geolocator
  factory LocationModel.fromGeolocator(dynamic position) {
    return LocationModel(
      latitude: (position.latitude as num).toDouble(),
      longitude: (position.longitude as num).toDouble(),
      accuracy: position.accuracy != null
          ? (position.accuracy as num).toDouble()
          : null,
      altitude: position.altitude != null
          ? (position.altitude as num).toDouble()
          : null,
      heading: position.heading != null
          ? (position.heading as num).toDouble()
          : null,
      speed: position.speed != null
          ? (position.speed as num).toDouble()
          : null,
      timestamp: (position.timestamp as DateTime?) ?? DateTime.now(),
    );
  }

  /// Alias para fromGeolocator - Crea un LocationModel desde Position de geolocator
  factory LocationModel.fromPosition(Position position) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }

  /// Convierte el modelo a una entidad
  LocationEntity toEntity() {
    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      heading: heading,
      speed: speed,
      timestamp: timestamp,
    );
  }

  @override
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? heading,
    double? speed,
    DateTime? timestamp,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// Made with Bob
