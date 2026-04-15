import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/promotion_history_entity.dart';
import '../../domain/entities/user_stats_entity.dart';

/// Estados del BLoC de perfil
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProfileInitial extends ProfileState {}

/// Estado de carga
class ProfileLoading extends ProfileState {}

/// Estado de perfil cargado exitosamente
class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final UserStatsEntity? stats;
  final List<PromotionHistoryEntity>? history;

  const ProfileLoaded({
    required this.user,
    this.stats,
    this.history,
  });

  @override
  List<Object?> get props => [user, stats, history];

  ProfileLoaded copyWith({
    UserEntity? user,
    UserStatsEntity? stats,
    List<PromotionHistoryEntity>? history,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      history: history ?? this.history,
    );
  }
}

/// Estado de actualización de perfil
class ProfileUpdating extends ProfileState {
  final UserEntity currentUser;

  const ProfileUpdating(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}

/// Estado de perfil actualizado exitosamente
class ProfileUpdated extends ProfileState {
  final UserEntity user;
  final String message;

  const ProfileUpdated({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

/// Estado de subida de foto
class ProfilePhotoUploading extends ProfileState {}

/// Estado de foto subida exitosamente
class ProfilePhotoUploaded extends ProfileState {
  final String photoUrl;

  const ProfilePhotoUploaded(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

/// Estado de estadísticas cargadas
class StatsLoaded extends ProfileState {
  final UserStatsEntity stats;

  const StatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Estado de historial cargado
class HistoryLoaded extends ProfileState {
  final List<PromotionHistoryEntity> history;
  final bool hasMore;

  const HistoryLoaded({
    required this.history,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [history, hasMore];
}

/// Estado de promoción marcada como usada
class PromotionMarkedAsUsed extends ProfileState {
  final PromotionHistoryEntity historyEntry;
  final String message;

  const PromotionMarkedAsUsed({
    required this.historyEntry,
    required this.message,
  });

  @override
  List<Object?> get props => [historyEntry, message];
}

/// Estado de entrada eliminada del historial
class HistoryEntryDeleted extends ProfileState {
  final String message;

  const HistoryEntryDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
