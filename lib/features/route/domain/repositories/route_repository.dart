import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/errors/failures.dart';
import '../../../location/domain/entities/location_entity.dart';

/// Value object devuelto por el repositorio tras obtener la polyline.
class RoutePolylineData {
  final List<LatLng> polylinePoints;
  final int totalDistanceMeters;
  final int totalDurationSeconds;

  const RoutePolylineData({
    required this.polylinePoints,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });
}

/// Repositorio abstracto para operaciones de ruta (capa de dominio)
abstract class RouteRepository {
  /// Obtiene la polyline encoded y metadatos desde Directions API.
  Future<Either<Failure, RoutePolylineData>> getRoutePolyline({
    required LocationEntity origin,
    required List<LocationEntity> orderedStops,
  });
}
