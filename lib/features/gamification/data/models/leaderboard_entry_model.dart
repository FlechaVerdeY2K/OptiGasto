import '../../domain/entities/leaderboard_entry_entity.dart';

/// Model for leaderboard entry in the data layer
class LeaderboardEntryModel extends LeaderboardEntryEntity {
  const LeaderboardEntryModel({
    required super.userId,
    required super.username,
    required super.points,
    required super.level,
    required super.rank,
    required super.badgeCount,
  });

  /// Creates a LeaderboardEntryModel from Supabase JSON
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      points: (json['points'] as num).toInt(),
      level: (json['level'] as num).toInt(),
      rank: (json['rank'] as num).toInt(),
      badgeCount: (json['badge_count'] as num).toInt(),
    );
  }

  /// Converts the LeaderboardEntryModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'points': points,
      'level': level,
      'rank': rank,
      'badge_count': badgeCount,
    };
  }

  /// Converts the LeaderboardEntryModel to LeaderboardEntryEntity
  LeaderboardEntryEntity toEntity() {
    return LeaderboardEntryEntity(
      userId: userId,
      username: username,
      points: points,
      level: level,
      rank: rank,
      badgeCount: badgeCount,
    );
  }
}

// Made with Bob
