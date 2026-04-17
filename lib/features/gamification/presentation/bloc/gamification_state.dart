import 'package:equatable/equatable.dart';
import '../../domain/entities/points_transaction_entity.dart';
import '../../domain/entities/user_gamification_stats_entity.dart';

/// States for gamification BLoC
abstract class GamificationState extends Equatable {
  const GamificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class GamificationInitial extends GamificationState {}

/// Loading state
class GamificationLoading extends GamificationState {}

/// Stats loaded successfully
class GamificationStatsLoaded extends GamificationState {
  final UserGamificationStatsEntity stats;

  const GamificationStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Points history loaded successfully
class PointsHistoryLoaded extends GamificationState {
  final List<PointsTransactionEntity> history;
  final bool hasMore;

  const PointsHistoryLoaded({
    required this.history,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [history, hasMore];
}

/// Points balance loaded successfully
class PointsBalanceLoaded extends GamificationState {
  final int balance;

  const PointsBalanceLoaded(this.balance);

  @override
  List<Object?> get props => [balance];
}

/// Combined state with all gamification data
class GamificationDataLoaded extends GamificationState {
  final UserGamificationStatsEntity stats;
  final List<PointsTransactionEntity>? recentHistory;

  const GamificationDataLoaded({
    required this.stats,
    this.recentHistory,
  });

  @override
  List<Object?> get props => [stats, recentHistory];

  GamificationDataLoaded copyWith({
    UserGamificationStatsEntity? stats,
    List<PointsTransactionEntity>? recentHistory,
  }) {
    return GamificationDataLoaded(
      stats: stats ?? this.stats,
      recentHistory: recentHistory ?? this.recentHistory,
    );
  }
}

/// Error state
class GamificationError extends GamificationState {
  final String message;

  const GamificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
