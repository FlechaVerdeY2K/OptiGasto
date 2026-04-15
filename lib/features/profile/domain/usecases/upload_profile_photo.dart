import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Parámetros para subir foto de perfil
class UploadProfilePhotoParams {
  final String userId;
  final String filePath;

  UploadProfilePhotoParams({
    required this.userId,
    required this.filePath,
  });
}

/// Caso de uso para subir foto de perfil
class UploadProfilePhoto {
  final ProfileRepository repository;

  UploadProfilePhoto(this.repository);

  Future<Either<Failure, String>> call(UploadProfilePhotoParams params) async {
    return await repository.uploadProfilePhoto(
      userId: params.userId,
      filePath: params.filePath,
    );
  }
}

// Made with Bob
