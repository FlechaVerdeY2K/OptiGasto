import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_origin_entity.dart';
import 'route_stop_entity.dart';

/// Entidad que representa la ruta completa calculada por el algoritmo TSP
class OptimizedRouteEntity extends Equatable {
  final RouteOriginEntity origin;
  final List<RouteStopEntity> stops;
  final List<LatLng> polylinePoints;
  final int totalDistanceMeters;
  final int totalDurationSeconds;
  final DateTime calculatedAt;

  const OptimizedRouteEntity({
    required this.origin,
    required this.stops,
    required this.polylinePoints,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [
        origin,
        stops,
        polylinePoints,
        totalDistanceMeters,
        totalDurationSeconds,
        calculatedAt,
      ];

  @override
  String toString() =>
      'OptimizedRouteEntity(stops: ${stops.length}, totalDistanceMeters: $totalDistanceMeters, calculatedAt: $calculatedAt)';
}
