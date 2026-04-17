import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/commerce_loyalty_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get loyalty status for a specific commerce
class GetCommerceLoyalty {
  final GamificationRepository repository;

  GetCommerceLoyalty(this.repository);

  Future<Either<Failure, CommerceLoyaltyEntity?>> call({
    required String userId,
    required String commerceId,
  }) async {
    return await repository.getCommerceLoyalty(
      userId: userId,
      commerceId: commerceId,
    );
  }
}

// Made with Bob
