import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/badge_entity.dart';
import '../entities/commerce_loyalty_entity.dart';
import '../entities/leaderboard_entry_entity.dart';
import '../entities/points_transaction_entity.dart';
import '../entities/user_badge_entity.dart';
import '../entities/user_gamification_stats_entity.dart';

/// Abstract repository for gamification operations
abstract class GamificationRepository {
  // ============================================================================
  // POINTS OPERATIONS
  // ============================================================================

  /// Get user's gamification statistics
  Future<Either<Failure, UserGamificationStatsEntity>> getUserStats(
    String userId,
  );

  /// Get user's points transaction history
  Future<Either<Failure, List<PointsTransactionEntity>>> getPointsHistory({
    required String userId,
    int? limit,
    int? offset,
  });

  /// Get points balance for a user
  Future<Either<Failure, int>> getPointsBalance(String userId);

  // ============================================================================
  // BADGES OPERATIONS
  // ============================================================================

  /// Get all available badges
  Future<Either<Failure, List<BadgeEntity>>> getAllBadges();

  /// Get badges unlocked by a user
  Future<Either<Failure, List<UserBadgeEntity>>> getUserBadges(
    String userId,
  );

  /// Get a specific badge with unlock status for a user
  Future<Either<Failure, BadgeEntity>> getBadgeDetails({
    required String badgeId,
    required String userId,
  });

  /// Check if user has unlocked a specific badge
  Future<Either<Failure, bool>> hasBadge({
    required String userId,
    required String badgeId,
  });

  // ============================================================================
  // LEADERBOARD OPERATIONS
  // ============================================================================

  /// Get weekly leaderboard (top 100 users)
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getWeeklyLeaderboard({
    int? limit,
  });

  /// Get monthly leaderboard (top 100 users)
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getMonthlyLeaderboard({
    int? limit,
  });

  /// Get yearly leaderboard (top 100 users)
  Future<Either<Failure, List<LeaderboardEntryEntity>>> getYearlyLeaderboard({
    int? limit,
  });

  /// Get user's rank in a specific leaderboard period
  Future<Either<Failure, int>> getUserRank({
    required String userId,
    required String period, // 'weekly', 'monthly', 'yearly'
  });

  // ============================================================================
  // COMMERCE LOYALTY OPERATIONS
  // ============================================================================

  /// Get all commerce loyalty records for a user
  Future<Either<Failure, List<CommerceLoyaltyEntity>>> getUserLoyaltyRecords(
    String userId,
  );

  /// Get loyalty status for a specific commerce
  Future<Either<Failure, CommerceLoyaltyEntity?>> getCommerceLoyalty({
    required String userId,
    required String commerceId,
  });

  /// Get top loyalty commerces for a user (sorted by tier/purchases)
  Future<Either<Failure, List<CommerceLoyaltyEntity>>> getTopLoyaltyCommerces({
    required String userId,
    int? limit,
  });
}

// Made with Bob
