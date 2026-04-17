import 'package:equatable/equatable.dart';

/// Events for gamification BLoC
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user gamification stats
class LoadUserGamificationStats extends GamificationEvent {
  final String userId;

  const LoadUserGamificationStats(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load points history
class LoadPointsHistory extends GamificationEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadPointsHistory({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

/// Event to load points balance
class LoadPointsBalance extends GamificationEvent {
  final String userId;

  const LoadPointsBalance(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to refresh gamification data
class RefreshGamificationData extends GamificationEvent {
  final String userId;

  const RefreshGamificationData(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Made with Bob
