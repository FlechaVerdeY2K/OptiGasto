import 'dart:math' show cos, sin, asin, sqrt, pi;
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

/// Implementación del repositorio de ubicación
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final location = await remoteDataSource.getCurrentLocation();
      return Right(location.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener ubicación: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkLocationPermission() async {
    try {
      final hasPermission = await remoteDataSource.checkLocationPermission();
      return Right(hasPermission);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al verificar permisos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await remoteDataSource.requestLocationPermission();
      return Right(granted);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al solicitar permisos: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLocationServiceEnabled() async {
    try {
      final isEnabled = await remoteDataSource.isLocationServiceEnabled();
      return Right(isEnabled);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al verificar servicio: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> openLocationSettings() async {
    try {
      await remoteDataSource.openLocationSettings();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al abrir configuración: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapMarkerEntity>>> getNearbyPromotionMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      final markers = await remoteDataSource.getNearbyPromotionMarkers(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
        limit: limit,
      );
      return Right(markers.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener marcadores: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MapMarkerEntity>>> getNearbyCommerceMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      final markers = await remoteDataSource.getNearbyCommerceMarkers(
        latitude: latitude,
        longitude: longitude,
        radiusInKm: radiusInKm,
        limit: limit,
      );
      return Right(markers.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener marcadores: $e'));
    }
  }

  @override
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    // Fórmula de Haversine para calcular distancia entre dos puntos
    const double earthRadius = 6371; // Radio de la Tierra en km

    final double lat1Rad = lat1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double deltaLat = (lat2 - lat1) * (pi / 180);
    final double deltaLon = (lon2 - lon1) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLon / 2) * sin(deltaLon / 2);
    
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  @override
  Stream<LocationEntity> watchLocation() {
    try {
      return remoteDataSource.watchLocation().map((model) => model.toEntity());
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    } catch (e) {
      throw ServerFailure(message: 'Error al observar ubicación: $e');
    }
  }

  @override
  Future<Either<Failure, LocationEntity?>> getLastKnownLocation() async {
    try {
      final location = await remoteDataSource.getLastKnownLocation();
      if (location == null) {
        return const Right(null);
      }
      return Right(location.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al obtener última ubicación: $e'));
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> geocodeAddress(String address) async {
    try {
      final location = await remoteDataSource.geocodeAddress(address);
      return Right(location.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al geocodificar dirección: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final address = await remoteDataSource.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
      return Right(address);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al geocodificar coordenadas: $e'));
    }
  }
}

// Made with Bob