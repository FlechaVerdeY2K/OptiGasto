import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../entities/user_stats_entity.dart';
import '../entities/promotion_history_entity.dart';

/// Repositorio abstracto para operaciones de perfil de usuario
abstract class ProfileRepository {
  /// Obtiene el perfil del usuario actual
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);

  /// Actualiza el perfil del usuario
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  });

  /// Sube la foto de perfil del usuario
  Future<Either<Failure, String>> uploadProfilePhoto({
    required String userId,
    required String filePath,
  });

  /// Obtiene las estadísticas del usuario
  Future<Either<Failure, UserStatsEntity>> getUserStats(String userId);

  /// Obtiene el historial de promociones usadas
  Future<Either<Failure, List<PromotionHistoryEntity>>> getPromotionHistory({
    required String userId,
    int? limit,
    int? offset,
  });

  /// Marca una promoción como usada
  Future<Either<Failure, PromotionHistoryEntity>> markPromotionAsUsed({
    required String userId,
    required String promotionId,
    required double savingsAmount,
    String? notes,
  });

  /// Elimina una entrada del historial
  Future<Either<Failure, void>> deleteHistoryEntry(String historyId);
}

// Made with Bob