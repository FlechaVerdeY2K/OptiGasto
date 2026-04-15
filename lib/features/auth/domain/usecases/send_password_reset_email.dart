import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: Enviar email de recuperación de contraseña
class SendPasswordResetEmail {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
  }) async {
    return await repository.sendPasswordResetEmail(
      email: email,
    );
  }
}

// Made with Bob
