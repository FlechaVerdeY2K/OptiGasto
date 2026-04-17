import 'package:equatable/equatable.dart';

/// Events for leaderboard BLoC
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load leaderboard for a specific period
class LoadLeaderboard extends LeaderboardEvent {
  final String period; // 'weekly', 'monthly', 'yearly'
  final int limit;

  const LoadLeaderboard({
    required this.period,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [period, limit];
}

/// Event to load user's rank in leaderboard
class LoadUserRank extends LeaderboardEvent {
  final String userId;
  final String period; // 'weekly', 'monthly', 'yearly'

  const LoadUserRank({
    required this.userId,
    required this.period,
  });

  @override
  List<Object?> get props => [userId, period];
}

/// Event to switch leaderboard period
class SwitchLeaderboardPeriod extends LeaderboardEvent {
  final String period; // 'weekly', 'monthly', 'yearly'

  const SwitchLeaderboardPeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Event to refresh leaderboard
class RefreshLeaderboard extends LeaderboardEvent {
  final String period;

  const RefreshLeaderboard(this.period);

  @override
  List<Object?> get props => [period];
}

// Made with Bob
