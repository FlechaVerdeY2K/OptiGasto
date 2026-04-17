import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/optimized_route_entity.dart';
import '../entities/route_origin_entity.dart';
import '../entities/route_stop_entity.dart';
import '../repositories/route_repository.dart';

class CalculateOrderedRoute {
  final RouteRepository repository;

  CalculateOrderedRoute(this.repository);

  Future<Either<Failure, OptimizedRouteEntity>> call({
    required RouteOriginEntity origin,
    required List<RouteStopEntity> orderedStops,
  }) async {
    final orderedLocations = orderedStops.map((s) => s.location).toList();
    final result = await repository.getRoutePolyline(
      origin: origin.location,
      orderedStops: orderedLocations,
    );
    return result.map(
      (data) => OptimizedRouteEntity(
        origin: origin,
        stops: orderedStops,
        polylinePoints: data.polylinePoints,
        totalDistanceMeters: data.totalDistanceMeters,
        totalDurationSeconds: data.totalDurationSeconds,
        calculatedAt: DateTime.now(),
      ),
    );
  }
}
