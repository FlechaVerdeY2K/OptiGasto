import '../../domain/entities/map_marker_entity.dart';
import '../../domain/entities/location_entity.dart';
import 'location_model.dart';

/// Modelo de marcador de mapa para la capa de datos
class MapMarkerModel extends MapMarkerEntity {
  const MapMarkerModel({
    required super.id,
    required super.title,
    super.subtitle,
    required super.location,
    required super.type,
    super.iconUrl,
    super.metadata,
  });

  /// Crea un MapMarkerModel desde un MapMarkerEntity
  factory MapMarkerModel.fromEntity(MapMarkerEntity entity) {
    return MapMarkerModel(
      id: entity.id,
      title: entity.title,
      subtitle: entity.subtitle,
      location: entity.location,
      type: entity.type,
      iconUrl: entity.iconUrl,
      metadata: entity.metadata,
    );
  }

  /// Crea un MapMarkerModel desde un Map de Supabase
  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    // Parsear el tipo de marcador
    MarkerType type;
    switch (json['type']) {
      case 'promotion':
        type = MarkerType.promotion;
        break;
      case 'commerce':
        type = MarkerType.commerce;
        break;
      case 'user_location':
        type = MarkerType.userLocation;
        break;
      default:
        type = MarkerType.promotion;
    }

    // Crear la ubicación desde los datos
    final LocationEntity location = LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );

    return MapMarkerModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      location: location,
      type: type,
      iconUrl: json['icon_url'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
    );
  }

  /// Convierte el modelo a un Map para Supabase
  Map<String, dynamic> toJson() {
    String typeString;
    switch (type) {
      case MarkerType.promotion:
        typeString = 'promotion';
        break;
      case MarkerType.commerce:
        typeString = 'commerce';
        break;
      case MarkerType.userLocation:
        typeString = 'user_location';
        break;
    }

    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': typeString,
      'icon_url': iconUrl,
      'metadata': metadata,
      'timestamp': location.timestamp.toIso8601String(),
    };
  }

  /// Crea un MapMarkerModel desde una promoción
  factory MapMarkerModel.fromPromotion(Map<String, dynamic> promotion) {
    final LocationEntity location = LocationModel(
      latitude: (promotion['latitude'] as num).toDouble(),
      longitude: (promotion['longitude'] as num).toDouble(),
      timestamp: DateTime.now(),
    );

    return MapMarkerModel(
      id: (promotion['id'] as String?) ?? '',
      title: (promotion['title'] as String?) ?? '',
      subtitle: promotion['commerce_name'] as String?,
      location: location,
      type: MarkerType.promotion,
      iconUrl: promotion['images'] != null &&
              (promotion['images'] as List).isNotEmpty
          ? (promotion['images'] as List).first as String?
          : null,
      metadata: {
        'promotion_id': promotion['id'],
        'commerce_id': promotion['commerce_id'],
        'category': promotion['category'],
        'discount': promotion['discount'],
        'valid_until': promotion['valid_until'],
      },
    );
  }

  /// Crea un MapMarkerModel desde un comercio
  factory MapMarkerModel.fromCommerce(Map<String, dynamic> commerce) {
    final LocationEntity location = LocationModel(
      latitude: (commerce['latitude'] as num).toDouble(),
      longitude: (commerce['longitude'] as num).toDouble(),
      timestamp: DateTime.now(),
    );

    return MapMarkerModel(
      id: (commerce['id'] as String?) ?? '',
      title: (commerce['name'] as String?) ?? '',
      subtitle: commerce['type'] as String?,
      location: location,
      type: MarkerType.commerce,
      iconUrl: commerce['logo'] as String?,
      metadata: {
        'commerce_id': commerce['id'],
        'type': commerce['type'],
        'rating': commerce['rating'],
        'total_promotions': commerce['total_promotions'],
        'is_premium': commerce['is_premium'],
      },
    );
  }

  /// Convierte el modelo a una entidad
  MapMarkerEntity toEntity() {
    return MapMarkerEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      location: location,
      type: type,
      iconUrl: iconUrl,
      metadata: metadata,
    );
  }

  @override
  MapMarkerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    LocationEntity? location,
    MarkerType? type,
    String? iconUrl,
    Map<String, dynamic>? metadata,
  }) {
    return MapMarkerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      location: location ?? this.location,
      type: type ?? this.type,
      iconUrl: iconUrl ?? this.iconUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

// Made with Bob
