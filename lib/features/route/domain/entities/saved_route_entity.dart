import 'package:equatable/equatable.dart';
import 'route_origin_entity.dart';
import 'route_stop_entity.dart';

class SavedRouteEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final RouteOriginEntity origin;
  final List<RouteStopEntity> stops;
  final int distanceMeters;
  final int durationSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedRouteEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.origin,
    required this.stops,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  SavedRouteEntity copyWith({
    String? id,
    String? userId,
    String? name,
    RouteOriginEntity? origin,
    List<RouteStopEntity>? stops,
    int? distanceMeters,
    int? durationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedRouteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      stops: stops ?? this.stops,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        origin,
        stops,
        distanceMeters,
        durationSeconds,
        createdAt,
        updatedAt,
      ];
}
