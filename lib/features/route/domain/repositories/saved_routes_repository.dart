import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_route_entity.dart';

abstract class SavedRoutesRepository {
  Future<Either<Failure, List<SavedRouteEntity>>> getSavedRoutes();
  Future<Either<Failure, SavedRouteEntity>> createSavedRoute(
      SavedRouteEntity route);
  Future<Either<Failure, SavedRouteEntity>> updateSavedRoute(
      SavedRouteEntity route);
  Future<Either<Failure, void>> deleteSavedRoute(String routeId);
}
