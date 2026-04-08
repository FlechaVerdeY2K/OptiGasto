import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/location_repository.dart';

/// Caso de uso: Verificar permisos de ubicación
class CheckLocationPermission {
  final LocationRepository repository;

  CheckLocationPermission(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.checkLocationPermission();
  }
}

// Made with Bob