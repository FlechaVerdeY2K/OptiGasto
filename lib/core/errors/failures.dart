import 'package:equatable/equatable.dart';

/// Clase base para todos los fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Fallo del servidor
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de caché
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de red
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de autenticación
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de validación
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de ubicación
class LocationFailure extends Failure {
  const LocationFailure({
    required super.message,
    super.code,
  });
}

/// Fallo de almacenamiento (Supabase CRUD)
class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code,
  });
}

/// Fallo desconocido
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
    super.code,
  });
}

// Made with Bob
