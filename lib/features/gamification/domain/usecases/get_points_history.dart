import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/points_transaction_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get user's points transaction history
class GetPointsHistory {
  final GamificationRepository repository;

  GetPointsHistory(this.repository);

  Future<Either<Failure, List<PointsTransactionEntity>>> call({
    required String userId,
    int? limit,
    int? offset,
  }) async {
    return await repository.getPointsHistory(
      userId: userId,
      limit: limit,
      offset: offset,
    );
  }
}

// Made with Bob
