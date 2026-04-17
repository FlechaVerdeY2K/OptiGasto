import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_badge_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get badges unlocked by a specific user
class GetUserBadges {
  final GamificationRepository repository;

  GetUserBadges(this.repository);

  Future<Either<Failure, List<UserBadgeEntity>>> call(String userId) async {
    return await repository.getUserBadges(userId);
  }
}

// Made with Bob
