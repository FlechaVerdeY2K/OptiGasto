import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/saved_route_entity.dart';
import '../../domain/repositories/saved_routes_repository.dart';
import '../datasources/saved_routes_remote_data_source.dart';
import '../models/saved_route_model.dart';

class SavedRoutesRepositoryImpl implements SavedRoutesRepository {
  final SavedRoutesRemoteDataSource remoteDataSource;

  SavedRoutesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SavedRouteEntity>>> getSavedRoutes() async {
    try {
      final routes = await remoteDataSource.getSavedRoutes();
      return Right(routes);
    } on ServerException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedRouteEntity>> createSavedRoute(
      SavedRouteEntity route) async {
    try {
      final model = SavedRouteModel.fromEntity(route);
      final created = await remoteDataSource.createSavedRoute(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedRouteEntity>> updateSavedRoute(
      SavedRouteEntity route) async {
    try {
      final model = SavedRouteModel.fromEntity(route);
      final updated = await remoteDataSource.updateSavedRoute(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSavedRoute(String routeId) async {
    try {
      await remoteDataSource.deleteSavedRoute(routeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(StorageFailure(message: e.message));
    } catch (e) {
      return Left(StorageFailure(message: 'Error inesperado: $e'));
    }
  }
}
