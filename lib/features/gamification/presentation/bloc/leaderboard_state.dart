import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

/// States for leaderboard BLoC
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

/// Loading state
class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

/// State when leaderboard is loaded
class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntryEntity> entries;
  final String period;
  final int totalEntries;
  final LeaderboardEntryEntity? userEntry;

  const LeaderboardLoaded({
    required this.entries,
    required this.period,
    required this.totalEntries,
    this.userEntry,
  });

  /// Get top 3 entries
  List<LeaderboardEntryEntity> get topThree {
    if (entries.length >= 3) {
      return entries.sublist(0, 3);
    }
    return entries;
  }

  /// Get remaining entries (after top 3)
  List<LeaderboardEntryEntity> get remainingEntries {
    if (entries.length > 3) {
      return entries.sublist(3);
    }
    return [];
  }

  /// Check if user is in top 3
  bool get isUserInTopThree {
    if (userEntry == null) return false;
    return userEntry!.rank <= 3;
  }

  /// Get user's rank
  int? get userRank => userEntry?.rank;

  /// Get period display name
  String get periodDisplayName {
    switch (period) {
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensual';
      case 'yearly':
        return 'Anual';
      default:
        return period;
    }
  }

  @override
  List<Object?> get props => [entries, period, totalEntries, userEntry];

  /// Create a copy with updated values
  LeaderboardLoaded copyWith({
    List<LeaderboardEntryEntity>? entries,
    String? period,
    int? totalEntries,
    LeaderboardEntryEntity? userEntry,
  }) {
    return LeaderboardLoaded(
      entries: entries ?? this.entries,
      period: period ?? this.period,
      totalEntries: totalEntries ?? this.totalEntries,
      userEntry: userEntry ?? this.userEntry,
    );
  }
}

/// State when user rank is loaded
class UserRankLoaded extends LeaderboardState {
  final LeaderboardEntryEntity userEntry;
  final String period;

  const UserRankLoaded({
    required this.userEntry,
    required this.period,
  });

  @override
  List<Object?> get props => [userEntry, period];
}

/// Error state
class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
