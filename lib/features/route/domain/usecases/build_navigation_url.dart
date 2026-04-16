import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/optimized_route_entity.dart';

enum NavigationApp { googleMaps, waze }

/// Construye la URL de navegación para Google Maps o Waze
class BuildNavigationUrl {
  Either<Failure, String> call({
    required NavigationApp app,
    required OptimizedRouteEntity route,
  }) {
    if (route.stops.isEmpty) {
      return const Left(
        ValidationFailure(message: 'La ruta no tiene paradas.'),
      );
    }
    try {
      final url = switch (app) {
        NavigationApp.googleMaps => _buildGoogleMapsUrl(route),
        NavigationApp.waze => _buildWazeUrl(route),
      };
      return Right(url);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al construir URL: $e'));
    }
  }

  String _buildGoogleMapsUrl(OptimizedRouteEntity route) {
    final origin = route.origin.location;
    final destination = route.stops.last.location;

    final buffer = StringBuffer(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}',
    );

    if (route.stops.length > 1) {
      final waypoints = route.stops
          .sublist(0, route.stops.length - 1)
          .map((s) => '${s.location.latitude},${s.location.longitude}')
          .join('|');
      buffer.write('&waypoints=$waypoints');
    }

    buffer.write('&travelmode=driving');
    return buffer.toString();
  }

  String _buildWazeUrl(OptimizedRouteEntity route) {
    final first = route.stops.first.location;
    return 'https://waze.com/ul?ll=${first.latitude},${first.longitude}&navigate=yes';
  }
}
