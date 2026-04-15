import 'package:equatable/equatable.dart';
import 'location_entity.dart';

/// Tipo de marcador en el mapa
enum MarkerType {
  promotion,
  commerce,
  userLocation,
}

/// Entidad de marcador de mapa en la capa de dominio
class MapMarkerEntity extends Equatable {
  final String id;
  final String title;
  final String? subtitle;
  final LocationEntity location;
  final MarkerType type;
  final String? iconUrl;
  final Map<String, dynamic>? metadata;

  const MapMarkerEntity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.location,
    required this.type,
    this.iconUrl,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        location,
        type,
        iconUrl,
        metadata,
      ];

  /// Calcula la distancia a otro marcador
  double distanceTo(MapMarkerEntity other) {
    return location.distanceTo(other.location);
  }

  /// Verifica si el marcador está dentro de un radio desde una ubicación
  bool isWithinRadius(LocationEntity center, double radiusKm) {
    return location.isWithinRadius(center, radiusKm);
  }

  /// Copia la entidad con campos actualizados
  MapMarkerEntity copyWith({
    String? id,
    String? title,
    String? subtitle,
    LocationEntity? location,
    MarkerType? type,
    String? iconUrl,
    Map<String, dynamic>? metadata,
  }) {
    return MapMarkerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      location: location ?? this.location,
      type: type ?? this.type,
      iconUrl: iconUrl ?? this.iconUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MapMarkerEntity(id: $id, title: $title, type: $type, location: $location)';
  }
}

// Made with Bob
