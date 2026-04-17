import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_gamification_stats_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get comprehensive gamification statistics for a user
class GetUserGamificationStats {
  final GamificationRepository repository;

  GetUserGamificationStats(this.repository);

  Future<Either<Failure, UserGamificationStatsEntity>> call(
    String userId,
  ) async {
    return await repository.getUserStats(userId);
  }
}

// Made with Bob
