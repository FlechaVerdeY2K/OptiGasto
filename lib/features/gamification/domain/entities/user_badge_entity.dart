import 'package:equatable/equatable.dart';

/// Entity representing a badge unlocked by a user
class UserBadgeEntity extends Equatable {
  final String id;
  final String userId;
  final String badgeId;
  final DateTime unlockedAt;
  final int? progress;

  const UserBadgeEntity({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.unlockedAt,
    this.progress,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        badgeId,
        unlockedAt,
        progress,
      ];

  UserBadgeEntity copyWith({
    String? id,
    String? userId,
    String? badgeId,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return UserBadgeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }
}

// Made with Bob
