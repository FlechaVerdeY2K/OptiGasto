import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for checking nearby promotions and sending notifications
class CheckNearbyPromotions {
  final NotificationRepository repository;

  CheckNearbyPromotions(this.repository);

  Future<Either<Failure, void>> call({
    required double latitude,
    required double longitude,
  }) async {
    return await repository.checkNearbyPromotions(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

// Made with Bob
