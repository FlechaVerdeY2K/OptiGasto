import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/commerce_loyalty_entity.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';
import '../../domain/entities/points_transaction_entity.dart';
import '../../domain/entities/user_badge_entity.dart';
import '../../domain/entities/user_gamification_stats_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_remote_data_source.dart';

/// Implementation of gamification repository
class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource remoteDataSource;

  GamificationRepositoryImpl({required this.remoteDataSource});

  // ============================================================================
  // POINTS OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, UserGamificationStatsEntity>> getUserStats(
    String userId,
  ) async {
    try {
      final statsModel = await remoteDataSource.getUserStats(userId);
      return Right(statsModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PointsTransactionEntity>>> getPointsHistory({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      final transactionModels = await remoteDataSource.getPointsHistory(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      final transactionEntities =
          transactionModels.map((model) => model.toEntity()).toList();
      return Right(transactionEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getPointsBalance(String userId) async {
    try {
      final balance = await remoteDataSource.getPointsBalance(userId);
      return Right(balance);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  // ============================================================================
  // BADGES OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<BadgeEntity>>> getAllBadges() async {
    try {
      final badgeModels = await remoteDataSource.getAllBadges();
      final badgeEntities = badgeModels.map((model) => model.toEntity()).toList();
      return Right(badgeEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserBadgeEntity>>> getUserBadges(
    String userId,
  ) async {
    try {
      final userBadgeModels = await remoteDataSource.getUserBadges(userId);
      final userBadgeEntities =
          userBadgeModels.map((model) => model.toEntity()).toList();
      return Right(userBadgeEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, BadgeEntity>> getBadgeDetails({
    required String badgeId,
    required String userId,
  }) async {
    try {
      final badgeModel = await remoteDataSource.getBadgeDetails(
        badgeId: badgeId,
        userId: userId,
      );
      return Right(badgeModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasBadge({
    required String userId,
    required String badgeId,
  }) async {
    try {
      final hasBadge = await remoteDataSource.hasBadge(
        userId: userId,
        badgeId: badgeId,
      );
      return Right(hasBadge);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  // ============================================================================
  // LEADERBOARD OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getWeeklyLeaderboard({
    int? limit,
  }) async {
    try {
      final leaderboardModels =
          await remoteDataSource.getWeeklyLeaderboard(limit: limit);
      final leaderboardEntities =
          leaderboardModels.map((model) => model.toEntity()).toList();
      return Right(leaderboardEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getMonthlyLeaderboard({
    int? limit,
  }) async {
    try {
      final leaderboardModels =
          await remoteDataSource.getMonthlyLeaderboard(limit: limit);
      final leaderboardEntities =
          leaderboardModels.map((model) => model.toEntity()).toList();
      return Right(leaderboardEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getYearlyLeaderboard({
    int? limit,
  }) async {
    try {
      final leaderboardModels =
          await remoteDataSource.getYearlyLeaderboard(limit: limit);
      final leaderboardEntities =
          leaderboardModels.map((model) => model.toEntity()).toList();
      return Right(leaderboardEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUserRank({
    required String userId,
    required String period,
  }) async {
    try {
      final rank = await remoteDataSource.getUserRank(
        userId: userId,
        period: period,
      );
      return Right(rank);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  // ============================================================================
  // COMMERCE LOYALTY OPERATIONS
  // ============================================================================

  @override
  Future<Either<Failure, List<CommerceLoyaltyEntity>>> getUserLoyaltyRecords(
    String userId,
  ) async {
    try {
      final loyaltyModels =
          await remoteDataSource.getUserLoyaltyRecords(userId);
      final loyaltyEntities =
          loyaltyModels.map((model) => model.toEntity()).toList();
      return Right(loyaltyEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, CommerceLoyaltyEntity?>> getCommerceLoyalty({
    required String userId,
    required String commerceId,
  }) async {
    try {
      final loyaltyModel = await remoteDataSource.getCommerceLoyalty(
        userId: userId,
        commerceId: commerceId,
      );
      return Right(loyaltyModel?.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CommerceLoyaltyEntity>>> getTopLoyaltyCommerces({
    required String userId,
    int? limit,
  }) async {
    try {
      final loyaltyModels = await remoteDataSource.getTopLoyaltyCommerces(
        userId: userId,
        limit: limit,
      );
      final loyaltyEntities =
          loyaltyModels.map((model) => model.toEntity()).toList();
      return Right(loyaltyEntities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}

// Made with Bob
