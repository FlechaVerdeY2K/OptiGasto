import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get user's current points balance
class GetPointsBalance {
  final GamificationRepository repository;

  GetPointsBalance(this.repository);

  Future<Either<Failure, int>> call(String userId) async {
    return await repository.getPointsBalance(userId);
  }
}

// Made with Bob
