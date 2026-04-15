import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/map_marker_entity.dart';
import '../repositories/location_repository.dart';

/// Caso de uso: Obtener marcadores de promociones cercanas
class GetNearbyPromotionMarkers {
  final LocationRepository repository;

  GetNearbyPromotionMarkers(this.repository);

  Future<Either<Failure, List<MapMarkerEntity>>> call({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    return await repository.getNearbyPromotionMarkers(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
      limit: limit,
    );
  }
}

// Made with Bob
