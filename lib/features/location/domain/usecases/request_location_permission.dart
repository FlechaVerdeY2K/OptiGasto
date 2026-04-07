import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

/// Caso de uso: Solicitar permisos de ubicación
class RequestLocationPermission {
  final LocationRepository repository;

  RequestLocationPermission(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.requestLocationPermission();
  }
}

// Made with Bob