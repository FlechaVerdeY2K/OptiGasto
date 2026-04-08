import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_preference_entity.dart';
import '../repositories/notification_repository.dart';

/// Use case for getting user notification preferences
class GetNotificationPreferences {
  final NotificationRepository repository;

  GetNotificationPreferences(this.repository);

  Future<Either<Failure, NotificationPreferenceEntity>> call() async {
    return await repository.getPreferences();
  }
}

// Made with Bob
