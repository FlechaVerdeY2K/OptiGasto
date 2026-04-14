import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for marking a notification as read
class MarkAsRead {
  final NotificationRepository repository;

  MarkAsRead(this.repository);

  Future<Either<Failure, void>> call(String notificationId) async {
    return await repository.markAsRead(notificationId);
  }
}

// Made with Bob
