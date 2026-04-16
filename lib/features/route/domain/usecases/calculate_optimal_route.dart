import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../entities/optimized_route_entity.dart';
import '../entities/route_origin_entity.dart';
import '../entities/route_stop_entity.dart';
import '../repositories/route_repository.dart';

/// Calcula la ruta óptima usando el algoritmo TSP greedy nearest-neighbor
class CalculateOptimalRoute {
  final RouteRepository repository;

  CalculateOptimalRoute(this.repository);

  Future<Either<Failure, OptimizedRouteEntity>> call({
    required RouteOriginEntity origin,
    required List<RouteStopEntity> unorderedStops,
  }) async {
    if (unorderedStops.isEmpty) {
      return const Left(
        ValidationFailure(message: 'Debes seleccionar al menos 1 parada.'),
      );
    }
    if (unorderedStops.length > 10) {
      return const Left(
        ValidationFailure(
          message: 'Máximo 10 paradas por ruta. Quitá algunas para continuar.',
        ),
      );
    }

    final orderedStops = _runTSP(origin.location, unorderedStops);

    final polylineResult = await repository.getRoutePolyline(
      origin: origin.location,
      orderedStops: orderedStops.map((s) => s.location).toList(),
    );

    return polylineResult.fold(
      Left.new,
      (data) => Right(
        OptimizedRouteEntity(
          origin: origin,
          stops: orderedStops,
          polylinePoints: data.polylinePoints,
          totalDistanceMeters: data.totalDistanceMeters,
          totalDurationSeconds: data.totalDurationSeconds,
          calculatedAt: DateTime.now(),
        ),
      ),
    );
  }

  List<RouteStopEntity> _runTSP(
    LocationEntity start,
    List<RouteStopEntity> stops,
  ) {
    final unvisited = List<RouteStopEntity>.from(stops);
    final visited = <RouteStopEntity>[];
    LocationEntity current = start;

    while (unvisited.isNotEmpty) {
      final nearest = unvisited.reduce(
        (a, b) =>
            current.distanceTo(a.location) <= current.distanceTo(b.location)
                ? a
                : b,
      );
      unvisited.remove(nearest);
      visited.add(nearest.copyWith(order: visited.length + 1));
      current = nearest.location;
    }

    return visited;
  }
}
