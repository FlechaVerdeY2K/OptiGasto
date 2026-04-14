import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promotion_history_entity.dart';
import '../repositories/profile_repository.dart';

/// Parámetros para marcar una promoción como usada
class MarkPromotionAsUsedParams {
  final String userId;
  final String promotionId;
  final double savingsAmount;
  final String? notes;

  MarkPromotionAsUsedParams({
    required this.userId,
    required this.promotionId,
    required this.savingsAmount,
    this.notes,
  });
}

/// Caso de uso para marcar una promoción como usada
class MarkPromotionAsUsed {
  final ProfileRepository repository;

  MarkPromotionAsUsed(this.repository);

  Future<Either<Failure, PromotionHistoryEntity>> call(
    MarkPromotionAsUsedParams params,
  ) async {
    return await repository.markPromotionAsUsed(
      userId: params.userId,
      promotionId: params.promotionId,
      savingsAmount: params.savingsAmount,
      notes: params.notes,
    );
  }
}

// Made with Bob