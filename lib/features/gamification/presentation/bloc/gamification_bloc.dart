import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_points_balance.dart';
import '../../domain/usecases/get_points_history.dart';
import '../../domain/usecases/get_user_gamification_stats.dart';
import 'gamification_event.dart';
import 'gamification_state.dart';

/// BLoC for gamification management
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GetUserGamificationStats getUserGamificationStats;
  final GetPointsHistory getPointsHistory;
  final GetPointsBalance getPointsBalance;

  GamificationBloc({
    required this.getUserGamificationStats,
    required this.getPointsHistory,
    required this.getPointsBalance,
  }) : super(GamificationInitial()) {
    on<LoadUserGamificationStats>(_onLoadUserGamificationStats);
    on<LoadPointsHistory>(_onLoadPointsHistory);
    on<LoadPointsBalance>(_onLoadPointsBalance);
    on<RefreshGamificationData>(_onRefreshGamificationData);
  }

  /// Handles loading user gamification stats
  Future<void> _onLoadUserGamificationStats(
    LoadUserGamificationStats event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    final result = await getUserGamificationStats(event.userId);

    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (stats) => emit(GamificationStatsLoaded(stats)),
    );
  }

  /// Handles loading points history
  Future<void> _onLoadPointsHistory(
    LoadPointsHistory event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    final result = await getPointsHistory(
      userId: event.userId,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (history) {
        final hasMore = event.limit != null && history.length >= event.limit!;
        emit(PointsHistoryLoaded(history: history, hasMore: hasMore));
      },
    );
  }

  /// Handles loading points balance
  Future<void> _onLoadPointsBalance(
    LoadPointsBalance event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    final result = await getPointsBalance(event.userId);

    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (balance) => emit(PointsBalanceLoaded(balance)),
    );
  }

  /// Handles refreshing all gamification data
  Future<void> _onRefreshGamificationData(
    RefreshGamificationData event,
    Emitter<GamificationState> emit,
  ) async {
    emit(GamificationLoading());

    // Load stats
    final statsResult = await getUserGamificationStats(event.userId);

    await statsResult.fold(
      (failure) async => emit(GamificationError(failure.message)),
      (stats) async {
        // Load recent history (last 10 transactions)
        final historyResult = await getPointsHistory(
          userId: event.userId,
          limit: 10,
        );

        historyResult.fold(
          (failure) => emit(GamificationError(failure.message)),
          (history) => emit(GamificationDataLoaded(
            stats: stats,
            recentHistory: history,
          )),
        );
      },
    );
  }
}

// Made with Bob
