import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sign_up_result_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Registrar nuevo usuario con email y contraseña
class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  Future<Either<Failure, SignUpResultEntity>> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await repository.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
  }
}

// Made with Bob
