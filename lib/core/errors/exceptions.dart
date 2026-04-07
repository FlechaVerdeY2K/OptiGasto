/// Excepción base para la aplicación
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Excepción del servidor
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.code,
  });
}

/// Excepción de caché
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.code,
  });
}

/// Excepción de red
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
  });
}

/// Excepción de autenticación personalizada
class AppAuthException extends AppException {
  AppAuthException({
    required super.message,
    super.code,
  });
}

/// Excepción de validación
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.code,
  });
}

/// Excepción de permisos
class PermissionException extends AppException {
  PermissionException({
    required super.message,
    super.code,
  });
}

/// Excepción de ubicación
class LocationException extends AppException {
  LocationException({
    required super.message,
    super.code,
  });
}

// Made with Bob
