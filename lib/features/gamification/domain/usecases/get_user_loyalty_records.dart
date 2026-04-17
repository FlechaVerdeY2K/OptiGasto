import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/commerce_loyalty_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get all commerce loyalty records for a user
class GetUserLoyaltyRecords {
  final GamificationRepository repository;

  GetUserLoyaltyRecords(this.repository);

  Future<Either<Failure, List<CommerceLoyaltyEntity>>> call(
    String userId,
  ) async {
    return await repository.getUserLoyaltyRecords(userId);
  }
}

// Made with Bob
