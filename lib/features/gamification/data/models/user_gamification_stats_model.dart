import '../../domain/entities/user_gamification_stats_entity.dart';

/// Model for user gamification stats in the data layer
class UserGamificationStatsModel extends UserGamificationStatsEntity {
  const UserGamificationStatsModel({
    required super.userId,
    required super.username,
    required super.points,
    required super.level,
    required super.pointsToNextLevel,
    required super.badgeCount,
    required super.totalTransactions,
  });

  /// Creates a UserGamificationStatsModel from Supabase JSON
  factory UserGamificationStatsModel.fromJson(Map<String, dynamic> json) {
    return UserGamificationStatsModel(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      points: (json['points'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      pointsToNextLevel: (json['points_to_next_level'] as num).toInt(),
      badgeCount: (json['badge_count'] as num).toInt(),
      totalTransactions: (json['total_transactions'] as num).toInt(),
    );
  }

  /// Converts the UserGamificationStatsModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'points': points,
      'level': level,
      'points_to_next_level': pointsToNextLevel,
      'badge_count': badgeCount,
      'total_transactions': totalTransactions,
    };
  }

  /// Converts the UserGamificationStatsModel to UserGamificationStatsEntity
  UserGamificationStatsEntity toEntity() {
    return UserGamificationStatsEntity(
      userId: userId,
      username: username,
      points: points,
      level: level,
      pointsToNextLevel: pointsToNextLevel,
      badgeCount: badgeCount,
      totalTransactions: totalTransactions,
    );
  }
}

// Made with Bob
