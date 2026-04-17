import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/badge_model.dart';
import '../models/commerce_loyalty_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/points_transaction_model.dart';
import '../models/user_badge_model.dart';
import '../models/user_gamification_stats_model.dart';

/// Interface for gamification remote data source
abstract class GamificationRemoteDataSource {
  // Points operations
  Future<UserGamificationStatsModel> getUserStats(String userId);
  Future<List<PointsTransactionModel>> getPointsHistory({
    required String userId,
    int? limit,
    int? offset,
  });
  Future<int> getPointsBalance(String userId);

  // Badges operations
  Future<List<BadgeModel>> getAllBadges();
  Future<List<UserBadgeModel>> getUserBadges(String userId);
  Future<BadgeModel> getBadgeDetails({
    required String badgeId,
    required String userId,
  });
  Future<bool> hasBadge({
    required String userId,
    required String badgeId,
  });

  // Leaderboard operations
  Future<List<LeaderboardEntryModel>> getWeeklyLeaderboard({int? limit});
  Future<List<LeaderboardEntryModel>> getMonthlyLeaderboard({int? limit});
  Future<List<LeaderboardEntryModel>> getYearlyLeaderboard({int? limit});
  Future<int> getUserRank({
    required String userId,
    required String period,
  });

  // Commerce loyalty operations
  Future<List<CommerceLoyaltyModel>> getUserLoyaltyRecords(String userId);
  Future<CommerceLoyaltyModel?> getCommerceLoyalty({
    required String userId,
    required String commerceId,
  });
  Future<List<CommerceLoyaltyModel>> getTopLoyaltyCommerces({
    required String userId,
    int? limit,
  });
}

/// Implementation of gamification remote data source using Supabase
class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  final SupabaseClient supabase;

  GamificationRemoteDataSourceImpl({required this.supabase});

  // ============================================================================
  // POINTS OPERATIONS
  // ============================================================================

  @override
  Future<UserGamificationStatsModel> getUserStats(String userId) async {
    try {
      final response = await supabase
          .from('user_gamification_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return UserGamificationStatsModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(
          message: 'Error getting user gamification stats: $e');
    }
  }

  @override
  Future<List<PointsTransactionModel>> getPointsHistory({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = supabase
          .from('points_ledger')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) =>
              PointsTransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting points history: $e');
    }
  }

  @override
  Future<int> getPointsBalance(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select('points')
          .eq('id', userId)
          .single();

      return (response['points'] as num).toInt();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting points balance: $e');
    }
  }

  // ============================================================================
  // BADGES OPERATIONS
  // ============================================================================

  @override
  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final response = await supabase
          .from('badges')
          .select()
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => BadgeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting all badges: $e');
    }
  }

  @override
  Future<List<UserBadgeModel>> getUserBadges(String userId) async {
    try {
      final response = await supabase
          .from('user_badges')
          .select()
          .eq('user_id', userId)
          .order('unlocked_at', ascending: false);

      return (response as List)
          .map((json) => UserBadgeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting user badges: $e');
    }
  }

  @override
  Future<BadgeModel> getBadgeDetails({
    required String badgeId,
    required String userId,
  }) async {
    try {
      final response =
          await supabase.from('badges').select().eq('id', badgeId).single();

      return BadgeModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting badge details: $e');
    }
  }

  @override
  Future<bool> hasBadge({
    required String userId,
    required String badgeId,
  }) async {
    try {
      final response = await supabase
          .from('user_badges')
          .select('id')
          .eq('user_id', userId)
          .eq('badge_id', badgeId)
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error checking badge ownership: $e');
    }
  }

  // ============================================================================
  // LEADERBOARD OPERATIONS
  // ============================================================================

  @override
  Future<List<LeaderboardEntryModel>> getWeeklyLeaderboard({
    int? limit,
  }) async {
    try {
      var query = supabase
          .from('leaderboard_weekly')
          .select()
          .order('rank', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) =>
              LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting weekly leaderboard: $e');
    }
  }

  @override
  Future<List<LeaderboardEntryModel>> getMonthlyLeaderboard({
    int? limit,
  }) async {
    try {
      var query = supabase
          .from('leaderboard_monthly')
          .select()
          .order('rank', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) =>
              LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting monthly leaderboard: $e');
    }
  }

  @override
  Future<List<LeaderboardEntryModel>> getYearlyLeaderboard({
    int? limit,
  }) async {
    try {
      var query = supabase
          .from('leaderboard_yearly')
          .select()
          .order('rank', ascending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) =>
              LeaderboardEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting yearly leaderboard: $e');
    }
  }

  @override
  Future<int> getUserRank({
    required String userId,
    required String period,
  }) async {
    try {
      final tableName = 'leaderboard_$period';
      final response = await supabase
          .from(tableName)
          .select('rank')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return 0; // User not in leaderboard
      }

      return (response['rank'] as num).toInt();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting user rank: $e');
    }
  }

  // ============================================================================
  // COMMERCE LOYALTY OPERATIONS
  // ============================================================================

  @override
  Future<List<CommerceLoyaltyModel>> getUserLoyaltyRecords(
    String userId,
  ) async {
    try {
      final response = await supabase
          .from('commerce_loyalty')
          .select()
          .eq('user_id', userId)
          .order('purchase_count', ascending: false);

      return (response as List)
          .map((json) =>
              CommerceLoyaltyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting loyalty records: $e');
    }
  }

  @override
  Future<CommerceLoyaltyModel?> getCommerceLoyalty({
    required String userId,
    required String commerceId,
  }) async {
    try {
      final response = await supabase
          .from('commerce_loyalty')
          .select()
          .eq('user_id', userId)
          .eq('commerce_id', commerceId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CommerceLoyaltyModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting commerce loyalty: $e');
    }
  }

  @override
  Future<List<CommerceLoyaltyModel>> getTopLoyaltyCommerces({
    required String userId,
    int? limit,
  }) async {
    try {
      var query = supabase
          .from('commerce_loyalty')
          .select()
          .eq('user_id', userId)
          .order('purchase_count', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) =>
              CommerceLoyaltyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Error getting top loyalty commerces: $e');
    }
  }
}

// Made with Bob
