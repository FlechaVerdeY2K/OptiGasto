import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Repositorio abstracto de autenticación (capa de dominio)
abstract class AuthRepository {
  /// Obtiene el usuario actual autenticado
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Inicia sesión con email y contraseña
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con email y contraseña
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Inicia sesión con Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Inicia sesión con Apple
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Cierra la sesión del usuario actual
  Future<Either<Failure, void>> signOut();

  /// Envía un email de recuperación de contraseña
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Actualiza el perfil del usuario
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? name,
    String? photoUrl,
    String? phone,
  });

  /// Elimina la cuenta del usuario
  Future<Either<Failure, void>> deleteAccount();

  /// Stream que emite cambios en el estado de autenticación
  Stream<UserEntity?> get authStateChanges;
}

// Made with Bob
