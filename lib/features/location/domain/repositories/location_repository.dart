import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';
import '../entities/map_marker_entity.dart';

/// Repositorio abstracto de ubicación (capa de dominio)
abstract class LocationRepository {
  /// Obtiene la ubicación actual del usuario
  Future<Either<Failure, LocationEntity>> getCurrentLocation();

  /// Verifica si los permisos de ubicación están otorgados
  Future<Either<Failure, bool>> checkLocationPermission();

  /// Solicita permisos de ubicación al usuario
  Future<Either<Failure, bool>> requestLocationPermission();

  /// Verifica si el servicio de ubicación está habilitado
  Future<Either<Failure, bool>> isLocationServiceEnabled();

  /// Abre la configuración de ubicación del dispositivo
  Future<Either<Failure, void>> openLocationSettings();

  /// Obtiene marcadores de promociones cercanas
  Future<Either<Failure, List<MapMarkerEntity>>> getNearbyPromotionMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Obtiene marcadores de comercios cercanos
  Future<Either<Failure, List<MapMarkerEntity>>> getNearbyCommerceMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Calcula la distancia entre dos ubicaciones en kilómetros
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  });

  /// Stream que emite actualizaciones de ubicación en tiempo real
  Stream<LocationEntity> watchLocation();

  /// Obtiene la última ubicación conocida (puede ser null si no hay)
  Future<Either<Failure, LocationEntity?>> getLastKnownLocation();

  /// Geocodifica una dirección a coordenadas
  Future<Either<Failure, LocationEntity>> geocodeAddress(String address);

  /// Geocodifica inversamente coordenadas a dirección
  Future<Either<Failure, String>> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

// Made with Bob