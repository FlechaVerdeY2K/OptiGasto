import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/leaderboard_entry_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get leaderboard for a specific period
class GetLeaderboard {
  final GamificationRepository repository;

  GetLeaderboard(this.repository);

  /// Get leaderboard based on period
  /// [period] can be 'weekly', 'monthly', or 'yearly'
  Future<Either<Failure, List<LeaderboardEntryEntity>>> call({
    required String period,
    int? limit,
  }) async {
    switch (period.toLowerCase()) {
      case 'weekly':
        return await repository.getWeeklyLeaderboard(limit: limit);
      case 'monthly':
        return await repository.getMonthlyLeaderboard(limit: limit);
      case 'yearly':
        return await repository.getYearlyLeaderboard(limit: limit);
      default:
        return Left(
          ValidationFailure(
            message: 'Invalid period. Must be weekly, monthly, or yearly',
          ),
        );
    }
  }
}

// Made with Bob
