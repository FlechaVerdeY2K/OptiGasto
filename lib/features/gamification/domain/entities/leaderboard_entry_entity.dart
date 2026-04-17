import 'package:equatable/equatable.dart';

/// Entity representing a user's entry in the leaderboard
class LeaderboardEntryEntity extends Equatable {
  final String userId;
  final String username;
  final int points;
  final int level;
  final int rank;
  final int badgeCount;

  const LeaderboardEntryEntity({
    required this.userId,
    required this.username,
    required this.points,
    required this.level,
    required this.rank,
    required this.badgeCount,
  });

  @override
  List<Object?> get props => [
        userId,
        username,
        points,
        level,
        rank,
        badgeCount,
      ];

  /// Alias for points (widget compatibility)
  int get totalPoints => points;

  LeaderboardEntryEntity copyWith({
    String? userId,
    String? username,
    int? points,
    int? level,
    int? rank,
    int? badgeCount,
  }) {
    return LeaderboardEntryEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      points: points ?? this.points,
      level: level ?? this.level,
      rank: rank ?? this.rank,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}

// Made with Bob
