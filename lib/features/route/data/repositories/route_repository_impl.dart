import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../../domain/repositories/route_repository.dart';
import '../datasources/directions_remote_data_source.dart';

class RouteRepositoryImpl implements RouteRepository {
  final DirectionsRemoteDataSource remoteDataSource;

  RouteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RoutePolylineData>> getRoutePolyline({
    required LocationEntity origin,
    required List<LocationEntity> orderedStops,
  }) async {
    try {
      final model = await remoteDataSource.getDirections(
        origin: origin,
        orderedStops: orderedStops,
      );
      return Right(
        RoutePolylineData(
          polylinePoints: model.polylinePoints,
          totalDistanceMeters: model.totalDistanceMeters,
          totalDurationSeconds: model.totalDurationSeconds,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error inesperado: $e'));
    }
  }
}
