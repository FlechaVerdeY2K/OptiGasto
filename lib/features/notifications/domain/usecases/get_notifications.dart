import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting user notifications
class GetNotifications {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    int limit = 20,
    int offset = 0,
  }) async {
    return await repository.getNotifications(
      limit: limit,
      offset: offset,
    );
  }
}

// Made with Bob
