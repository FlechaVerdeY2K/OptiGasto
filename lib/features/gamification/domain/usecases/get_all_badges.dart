import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/badge_entity.dart';
import '../repositories/gamification_repository.dart';

/// Use case to get all available badges in the system
class GetAllBadges {
  final GamificationRepository repository;

  GetAllBadges(this.repository);

  Future<Either<Failure, List<BadgeEntity>>> call() async {
    return await repository.getAllBadges();
  }
}

// Made with Bob
