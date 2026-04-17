import 'package:equatable/equatable.dart';

/// Events for badges BLoC
abstract class BadgesEvent extends Equatable {
  const BadgesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all available badges
class LoadAllBadges extends BadgesEvent {
  const LoadAllBadges();
}

/// Event to load user's unlocked badges
class LoadUserBadges extends BadgesEvent {
  final String userId;

  const LoadUserBadges(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load badge details
class LoadBadgeDetails extends BadgesEvent {
  final String badgeId;
  final String userId;

  const LoadBadgeDetails({
    required this.badgeId,
    required this.userId,
  });

  @override
  List<Object?> get props => [badgeId, userId];
}

/// Event to check if user has a specific badge
class CheckBadgeOwnership extends BadgesEvent {
  final String userId;
  final String badgeId;

  const CheckBadgeOwnership({
    required this.userId,
    required this.badgeId,
  });

  @override
  List<Object?> get props => [userId, badgeId];
}

/// Event to refresh badges data
class RefreshBadges extends BadgesEvent {
  final String userId;

  const RefreshBadges(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Made with Bob
