import '../../../location/domain/entities/location_entity.dart';
import '../../domain/entities/route_origin_entity.dart';
import '../../domain/entities/route_stop_entity.dart';
import '../../domain/entities/saved_route_entity.dart';

class SavedRouteModel extends SavedRouteEntity {
  const SavedRouteModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.origin,
    required super.stops,
    required super.distanceMeters,
    required super.durationSeconds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SavedRouteModel.fromSupabase(Map<String, dynamic> map) {
    final originMap = map['origin'] as Map<String, dynamic>;
    final stopsJson = map['stops'] as List<dynamic>;

    final origin = RouteOriginEntity(
      location: LocationEntity(
        latitude: (originMap['lat'] as num).toDouble(),
        longitude: (originMap['lng'] as num).toDouble(),
        timestamp: DateTime.now(),
      ),
      displayName: originMap['displayName'] as String,
      type: RouteOriginType.values.firstWhere(
        (e) => e.name == originMap['type'],
        orElse: () => RouteOriginType.currentLocation,
      ),
    );

    final stops = stopsJson.map((s) {
      final stopMap = s as Map<String, dynamic>;
      return RouteStopEntity(
        id: stopMap['id'] as String,
        promotionId: stopMap['promotionId'] as String?,
        name: stopMap['name'] as String,
        location: LocationEntity(
          latitude: (stopMap['lat'] as num).toDouble(),
          longitude: (stopMap['lng'] as num).toDouble(),
          timestamp: DateTime.now(),
        ),
        order: stopMap['order'] as int,
      );
    }).toList();

    return SavedRouteModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      origin: origin,
      stops: stops,
      distanceMeters: map['distance_meters'] as int,
      durationSeconds: map['duration_seconds'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Serializes for Supabase INSERT. Does NOT include id or user_id
  /// (id is DB-generated; user_id is set by the datasource from auth).
  Map<String, dynamic> toSupabaseInsert() {
    return {
      'name': name,
      'origin': {
        'lat': origin.location.latitude,
        'lng': origin.location.longitude,
        'displayName': origin.displayName,
        'type': origin.type.name,
      },
      'stops': stops
          .map((s) => {
                'id': s.id,
                'promotionId': s.promotionId,
                'name': s.name,
                'lat': s.location.latitude,
                'lng': s.location.longitude,
                'order': s.order,
              })
          .toList(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
    };
  }

  /// Serializes for Supabase UPDATE (stops + name + distances + updated_at).
  Map<String, dynamic> toSupabaseUpdate() {
    return {
      'name': name,
      'stops': stops
          .map((s) => {
                'id': s.id,
                'promotionId': s.promotionId,
                'name': s.name,
                'lat': s.location.latitude,
                'lng': s.location.longitude,
                'order': s.order,
              })
          .toList(),
      'distance_meters': distanceMeters,
      'duration_seconds': durationSeconds,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory SavedRouteModel.fromEntity(SavedRouteEntity entity) {
    return SavedRouteModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      origin: entity.origin,
      stops: entity.stops,
      distanceMeters: entity.distanceMeters,
      durationSeconds: entity.durationSeconds,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
