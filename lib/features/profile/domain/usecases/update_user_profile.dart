import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

/// Parámetros para actualizar el perfil del usuario
class UpdateUserProfileParams {
  final String userId;
  final String? name;
  final String? phone;
  final String? photoUrl;

  UpdateUserProfileParams({
    required this.userId,
    this.name,
    this.phone,
    this.photoUrl,
  });
}

/// Caso de uso para actualizar el perfil del usuario
class UpdateUserProfile {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  Future<Either<Failure, UserEntity>> call(
      UpdateUserProfileParams params) async {
    return await repository.updateUserProfile(
      userId: params.userId,
      name: params.name,
      phone: params.phone,
      photoUrl: params.photoUrl,
    );
  }
}

// Made with Bob
