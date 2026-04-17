import 'package:equatable/equatable.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_badge_entity.dart';

/// States for badges BLoC
abstract class BadgesState extends Equatable {
  const BadgesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BadgesInitial extends BadgesState {
  const BadgesInitial();
}

/// Loading state
class BadgesLoading extends BadgesState {
  const BadgesLoading();
}

/// State when all badges are loaded
class AllBadgesLoaded extends BadgesState {
  final List<BadgeEntity> badges;

  const AllBadgesLoaded(this.badges);

  @override
  List<Object?> get props => [badges];
}

/// State when user badges are loaded
class UserBadgesLoaded extends BadgesState {
  final List<UserBadgeEntity> userBadges;
  final List<BadgeEntity> allBadges;

  const UserBadgesLoaded({
    required this.userBadges,
    required this.allBadges,
  });

  /// Get unlocked badge IDs
  List<String> get unlockedBadgeIds =>
      userBadges.map((ub) => ub.badgeId).toList();

  /// Check if a badge is unlocked
  bool isBadgeUnlocked(String badgeId) =>
      unlockedBadgeIds.contains(badgeId);

  /// Get badge details by ID
  BadgeEntity? getBadgeById(String badgeId) {
    try {
      return allBadges.firstWhere((b) => b.id == badgeId);
    } catch (_) {
      return null;
    }
  }

  /// Get user badge by badge ID
  UserBadgeEntity? getUserBadgeByBadgeId(String badgeId) {
    try {
      return userBadges.firstWhere((ub) => ub.badgeId == badgeId);
    } catch (_) {
      return null;
    }
  }

  /// Get unlocked badges count
  int get unlockedCount => userBadges.length;

  /// Get total badges count
  int get totalCount => allBadges.length;

  /// Get progress percentage
  double get progressPercentage {
    if (totalCount == 0) return 0.0;
    return (unlockedCount / totalCount) * 100;
  }

  @override
  List<Object?> get props => [userBadges, allBadges];

  /// Create a copy with updated values
  UserBadgesLoaded copyWith({
    List<UserBadgeEntity>? userBadges,
    List<BadgeEntity>? allBadges,
  }) {
    return UserBadgesLoaded(
      userBadges: userBadges ?? this.userBadges,
      allBadges: allBadges ?? this.allBadges,
    );
  }
}

/// State when badge details are loaded
class BadgeDetailsLoaded extends BadgesState {
  final BadgeEntity badge;
  final UserBadgeEntity? userBadge;
  final bool isUnlocked;

  const BadgeDetailsLoaded({
    required this.badge,
    this.userBadge,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [badge, userBadge, isUnlocked];
}

/// State when badge ownership is checked
class BadgeOwnershipChecked extends BadgesState {
  final String badgeId;
  final bool isOwned;

  const BadgeOwnershipChecked({
    required this.badgeId,
    required this.isOwned,
  });

  @override
  List<Object?> get props => [badgeId, isOwned];
}

/// Error state
class BadgesError extends BadgesState {
  final String message;

  const BadgesError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
