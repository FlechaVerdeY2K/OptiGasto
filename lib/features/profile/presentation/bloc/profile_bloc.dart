import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_promotion_history.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/get_user_stats.dart';
import '../../domain/usecases/update_user_profile.dart' as update_usecases;
import '../../domain/usecases/upload_profile_photo.dart' as upload_usecases;
import '../../domain/usecases/mark_promotion_as_used.dart' as mark_usecases;
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC para gestión del perfil de usuario
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final update_usecases.UpdateUserProfile updateUserProfile;
  final upload_usecases.UploadProfilePhoto uploadProfilePhoto;
  final GetUserStats getUserStats;
  final GetPromotionHistory getPromotionHistory;
  final mark_usecases.MarkPromotionAsUsed markPromotionAsUsed;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.uploadProfilePhoto,
    required this.getUserStats,
    required this.getPromotionHistory,
    required this.markPromotionAsUsed,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<UploadProfilePhoto>(_onUploadProfilePhoto);
    on<LoadUserStats>(_onLoadUserStats);
    on<LoadPromotionHistory>(_onLoadPromotionHistory);
    on<MarkPromotionAsUsed>(_onMarkPromotionAsUsed);
    on<RefreshProfile>(_onRefreshProfile);
  }

  /// Maneja el evento de cargar perfil de usuario
  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final result = await getUserProfile(event.userId);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  /// Maneja el evento de actualizar perfil
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Mantener el usuario actual mientras se actualiza
    if (state is ProfileLoaded) {
      emit(ProfileUpdating((state as ProfileLoaded).user));
    } else {
      emit(ProfileLoading());
    }

    final params = update_usecases.UpdateUserProfileParams(
      userId: event.userId,
      name: event.name,
      phone: event.phone,
      photoUrl: event.photoUrl,
    );

    final result = await updateUserProfile(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileUpdated(
        user: user,
        message: 'Perfil actualizado exitosamente',
      )),
    );
  }

  /// Maneja el evento de subir foto de perfil
  Future<void> _onUploadProfilePhoto(
    UploadProfilePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfilePhotoUploading());

    final params = upload_usecases.UploadProfilePhotoParams(
      userId: event.userId,
      filePath: event.filePath,
    );

    final result = await uploadProfilePhoto(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (photoUrl) {
        emit(ProfilePhotoUploaded(photoUrl));
        // Actualizar el perfil con la nueva URL de foto
        add(UpdateUserProfile(
          userId: event.userId,
          photoUrl: photoUrl,
        ));
      },
    );
  }

  /// Maneja el evento de cargar estadísticas
  Future<void> _onLoadUserStats(
    LoadUserStats event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await getUserStats(event.userId);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (stats) {
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(stats: stats));
        } else {
          emit(StatsLoaded(stats));
        }
      },
    );
  }

  /// Maneja el evento de cargar historial de promociones
  Future<void> _onLoadPromotionHistory(
    LoadPromotionHistory event,
    Emitter<ProfileState> emit,
  ) async {
    final params = GetPromotionHistoryParams(
      userId: event.userId,
      limit: event.limit,
      offset: event.offset,
    );

    final result = await getPromotionHistory(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (history) {
        final hasMore = event.limit != null && history.length >= event.limit!;

        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(history: history));
        } else {
          emit(HistoryLoaded(history: history, hasMore: hasMore));
        }
      },
    );
  }

  /// Maneja el evento de marcar promoción como usada
  Future<void> _onMarkPromotionAsUsed(
    MarkPromotionAsUsed event,
    Emitter<ProfileState> emit,
  ) async {
    final params = mark_usecases.MarkPromotionAsUsedParams(
      userId: event.userId,
      promotionId: event.promotionId,
      savingsAmount: event.savingsAmount,
      notes: event.notes,
    );

    final result = await markPromotionAsUsed(params);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (historyEntry) {
        emit(PromotionMarkedAsUsed(
          historyEntry: historyEntry,
          message:
              'Promoción marcada como usada. ¡Ahorraste ₡${event.savingsAmount.toStringAsFixed(0)}!',
        ));

        // Recargar estadísticas y historial
        add(LoadUserStats(event.userId));
        add(LoadPromotionHistory(userId: event.userId, limit: 20));
      },
    );
  }

  /// Maneja el evento de refrescar perfil completo
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    // Cargar perfil
    final profileResult = await getUserProfile(event.userId);

    await profileResult.fold(
      (failure) async => emit(ProfileError(failure.message)),
      (user) async {
        // Cargar estadísticas
        final statsResult = await getUserStats(event.userId);

        // Cargar historial
        final historyParams = GetPromotionHistoryParams(
          userId: event.userId,
          limit: 20,
        );
        final historyResult = await getPromotionHistory(historyParams);

        emit(ProfileLoaded(
          user: user,
          stats: statsResult.fold((_) => null, (stats) => stats),
          history: historyResult.fold((_) => null, (history) => history),
        ));
      },
    );
  }
}

// Made with Bob
