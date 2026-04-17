import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_leaderboard.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

/// BLoC for managing leaderboard state
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final GetLeaderboard getLeaderboard;

  LeaderboardBloc({
    required this.getLeaderboard,
  }) : super(const LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<LoadUserRank>(_onLoadUserRank);
    on<SwitchLeaderboardPeriod>(_onSwitchLeaderboardPeriod);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  /// Handle loading leaderboard
  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());

    final result = await getLeaderboard(
      period: event.period,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (entries) {
        emit(LeaderboardLoaded(
          entries: entries,
          period: event.period,
          totalEntries: entries.length,
        ));
      },
    );
  }

  /// Handle loading user rank
  Future<void> _onLoadUserRank(
    LoadUserRank event,
    Emitter<LeaderboardState> emit,
  ) async {
    // Load full leaderboard to find user
    final result = await getLeaderboard(
      period: event.period,
      limit: 1000, // Load more to find user
    );

    result.fold(
      (failure) => emit(LeaderboardError(failure.message)),
      (entries) {
        // Find user entry
        final userEntry = entries
            .where((entry) => entry.userId == event.userId)
            .firstOrNull;

        if (userEntry != null) {
          emit(UserRankLoaded(
            userEntry: userEntry,
            period: event.period,
          ));
        } else {
          emit(const LeaderboardError('Usuario no encontrado en el ranking'));
        }
      },
    );
  }

  /// Handle switching leaderboard period
  Future<void> _onSwitchLeaderboardPeriod(
    SwitchLeaderboardPeriod event,
    Emitter<LeaderboardState> emit,
  ) async {
    // Load leaderboard for new period
    add(LoadLeaderboard(period: event.period));
  }

  /// Handle refreshing leaderboard
  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    // Reload current period
    add(LoadLeaderboard(period: event.period));
  }
}

// Made with Bob
