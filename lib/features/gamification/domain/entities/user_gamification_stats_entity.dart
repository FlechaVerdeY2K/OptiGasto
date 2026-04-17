import 'package:equatable/equatable.dart';

/// Entity representing comprehensive gamification statistics for a user
class UserGamificationStatsEntity extends Equatable {
  final String userId;
  final String username;
  final int points;
  final int level;
  final int pointsToNextLevel;
  final int badgeCount;
  final int totalTransactions;

  const UserGamificationStatsEntity({
    required this.userId,
    required this.username,
    required this.points,
    required this.level,
    required this.pointsToNextLevel,
    required this.badgeCount,
    required this.totalTransactions,
  });

  @override
  List<Object?> get props => [
        userId,
        username,
        points,
        level,
        pointsToNextLevel,
        badgeCount,
        totalTransactions,
      ];

  UserGamificationStatsEntity copyWith({
    String? userId,
    String? username,
    int? points,
    int? level,
    int? pointsToNextLevel,
    int? badgeCount,
    int? totalTransactions,
  }) {
    return UserGamificationStatsEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      points: points ?? this.points,
      level: level ?? this.level,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
      badgeCount: badgeCount ?? this.badgeCount,
      totalTransactions: totalTransactions ?? this.totalTransactions,
    );
  }

  /// Get level name in Spanish
  String get levelName {
    switch (level) {
      case 1:
        return 'Novato';
      case 2:
        return 'Explorador';
      case 3:
        return 'Experto';
      case 4:
        return 'Maestro';
      case 5:
        return 'Leyenda';
      default:
        return 'Nivel $level';
    }
  }

  /// Calculate progress percentage to next level
  double get progressPercentage {
    if (pointsToNextLevel == 0) return 1.0;
    
    // Calculate points in current level
    final levelThresholds = [0, 100, 500, 1500, 3000];
    final currentLevelPoints = level <= levelThresholds.length 
        ? levelThresholds[level - 1] 
        : 0;
    final nextLevelPoints = level < levelThresholds.length 
        ? levelThresholds[level] 
        : currentLevelPoints + 5000;
    
    final pointsInLevel = points - currentLevelPoints;
    final pointsNeededForLevel = nextLevelPoints - currentLevelPoints;
    
    return pointsNeededForLevel > 0 
        ? pointsInLevel / pointsNeededForLevel 
        : 1.0;
  }
}

// Made with Bob
