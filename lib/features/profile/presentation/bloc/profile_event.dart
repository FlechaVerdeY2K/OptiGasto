import 'package:equatable/equatable.dart';

/// Eventos del BLoC de perfil
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el perfil del usuario
class LoadUserProfile extends ProfileEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Evento para actualizar el perfil del usuario
class UpdateUserProfile extends ProfileEvent {
  final String userId;
  final String? name;
  final String? phone;
  final String? photoUrl;

  const UpdateUserProfile({
    required this.userId,
    this.name,
    this.phone,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, name, phone, photoUrl];
}

/// Evento para subir foto de perfil
class UploadProfilePhoto extends ProfileEvent {
  final String userId;
  final String filePath;

  const UploadProfilePhoto({
    required this.userId,
    required this.filePath,
  });

  @override
  List<Object?> get props => [userId, filePath];
}

/// Evento para cargar estadísticas del usuario
class LoadUserStats extends ProfileEvent {
  final String userId;

  const LoadUserStats(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Evento para cargar historial de promociones
class LoadPromotionHistory extends ProfileEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const LoadPromotionHistory({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [userId, limit, offset];
}

/// Evento para marcar una promoción como usada
class MarkPromotionAsUsed extends ProfileEvent {
  final String userId;
  final String promotionId;
  final double savingsAmount;
  final String? notes;

  const MarkPromotionAsUsed({
    required this.userId,
    required this.promotionId,
    required this.savingsAmount,
    this.notes,
  });

  @override
  List<Object?> get props => [userId, promotionId, savingsAmount, notes];
}

/// Evento para eliminar una entrada del historial
class DeleteHistoryEntry extends ProfileEvent {
  final String historyId;

  const DeleteHistoryEntry(this.historyId);

  @override
  List<Object?> get props => [historyId];
}

/// Evento para refrescar todos los datos del perfil
class RefreshProfile extends ProfileEvent {
  final String userId;

  const RefreshProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

// Made with Bob