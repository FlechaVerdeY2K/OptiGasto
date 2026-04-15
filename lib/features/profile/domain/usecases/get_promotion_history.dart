import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promotion_history_entity.dart';
import '../repositories/profile_repository.dart';

/// Parámetros para obtener el historial de promociones
class GetPromotionHistoryParams {
  final String userId;
  final int? limit;
  final int? offset;

  GetPromotionHistoryParams({
    required this.userId,
    this.limit,
    this.offset,
  });
}

/// Caso de uso para obtener el historial de promociones usadas
class GetPromotionHistory {
  final ProfileRepository repository;

  GetPromotionHistory(this.repository);

  Future<Either<Failure, List<PromotionHistoryEntity>>> call(
    GetPromotionHistoryParams params,
  ) async {
    return await repository.getPromotionHistory(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

// Made with Bob
