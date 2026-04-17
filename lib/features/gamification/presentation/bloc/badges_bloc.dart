import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_badges.dart';
import '../../domain/usecases/get_user_badges.dart';
import 'badges_event.dart';
import 'badges_state.dart';

/// BLoC for managing badges state
class BadgesBloc extends Bloc<BadgesEvent, BadgesState> {
  final GetAllBadges getAllBadges;
  final GetUserBadges getUserBadges;

  BadgesBloc({
    required this.getAllBadges,
    required this.getUserBadges,
  }) : super(const BadgesInitial()) {
    on<LoadAllBadges>(_onLoadAllBadges);
    on<LoadUserBadges>(_onLoadUserBadges);
    on<LoadBadgeDetails>(_onLoadBadgeDetails);
    on<CheckBadgeOwnership>(_onCheckBadgeOwnership);
    on<RefreshBadges>(_onRefreshBadges);
  }

  /// Handle loading all badges
  Future<void> _onLoadAllBadges(
    LoadAllBadges event,
    Emitter<BadgesState> emit,
  ) async {
    emit(const BadgesLoading());

    final result = await getAllBadges();

    result.fold(
      (failure) => emit(BadgesError(failure.message)),
      (badges) => emit(AllBadgesLoaded(badges)),
    );
  }

  /// Handle loading user badges
  Future<void> _onLoadUserBadges(
    LoadUserBadges event,
    Emitter<BadgesState> emit,
  ) async {
    emit(const BadgesLoading());

    // Load both user badges and all badges
    final userBadgesResult = await getUserBadges(event.userId);
    final allBadgesResult = await getAllBadges();

    // Check if both succeeded
    if (userBadgesResult.isLeft() || allBadgesResult.isLeft()) {
      final errorMessage = userBadgesResult.fold(
        (failure) => failure.message,
        (_) => allBadgesResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error',
        ),
      );
      emit(BadgesError(errorMessage));
      return;
    }

    // Extract values
    final userBadges = userBadgesResult.getOrElse(() => []);
    final allBadges = allBadgesResult.getOrElse(() => []);

    emit(UserBadgesLoaded(
      userBadges: userBadges,
      allBadges: allBadges,
    ));
  }

  /// Handle loading badge details
  Future<void> _onLoadBadgeDetails(
    LoadBadgeDetails event,
    Emitter<BadgesState> emit,
  ) async {
    emit(const BadgesLoading());

    // Load all badges to find the specific one
    final allBadgesResult = await getAllBadges();
    final userBadgesResult = await getUserBadges(event.userId);

    if (allBadgesResult.isLeft()) {
      emit(BadgesError(
        allBadgesResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error',
        ),
      ));
      return;
    }

    final allBadges = allBadgesResult.getOrElse(() => []);
    final badge = allBadges.where((b) => b.id == event.badgeId).firstOrNull;

    if (badge == null) {
      emit(const BadgesError('Badge not found'));
      return;
    }

    // Check if user has this badge
    final userBadges = userBadgesResult.getOrElse(() => []);
    final userBadge =
        userBadges.where((ub) => ub.badgeId == event.badgeId).firstOrNull;

    emit(BadgeDetailsLoaded(
      badge: badge,
      userBadge: userBadge,
      isUnlocked: userBadge != null,
    ));
  }

  /// Handle checking badge ownership
  Future<void> _onCheckBadgeOwnership(
    CheckBadgeOwnership event,
    Emitter<BadgesState> emit,
  ) async {
    final result = await getUserBadges(event.userId);

    result.fold(
      (failure) => emit(BadgesError(failure.message)),
      (userBadges) {
        final isOwned = userBadges.any((ub) => ub.badgeId == event.badgeId);
        emit(BadgeOwnershipChecked(
          badgeId: event.badgeId,
          isOwned: isOwned,
        ));
      },
    );
  }

  /// Handle refreshing badges
  Future<void> _onRefreshBadges(
    RefreshBadges event,
    Emitter<BadgesState> emit,
  ) async {
    // Reload user badges
    add(LoadUserBadges(event.userId));
  }
}

// Made with Bob
