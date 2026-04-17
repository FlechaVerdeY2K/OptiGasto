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
    // Views use weekly_points/monthly_points/yearly_points — fall back through all
    final rawPoints = json['points'] ??
        json['weekly_points'] ??
        json['monthly_points'] ??
        json['yearly_points'] ??
        0;
    return LeaderboardEntryModel(
      userId: json['user_id'] as String,
      username: (json['username'] ?? json['name'] ?? '') as String,
      points: (rawPoints as num).toInt(),
      // level and badge_count not in leaderboard views — use defaults
      level: (json['level'] as num?)?.toInt() ?? 1,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      badgeCount: (json['badge_count'] as num?)?.toInt() ?? 0,
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
