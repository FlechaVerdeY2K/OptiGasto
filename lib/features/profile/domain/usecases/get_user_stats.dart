import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_stats_entity.dart';
import '../repositories/profile_repository.dart';

/// Caso de uso para obtener las estadísticas del usuario
class GetUserStats {
  final ProfileRepository repository;

  GetUserStats(this.repository);

  Future<Either<Failure, UserStatsEntity>> call(String userId) async {
    return await repository.getUserStats(userId);
  }
}

// Made with Bob