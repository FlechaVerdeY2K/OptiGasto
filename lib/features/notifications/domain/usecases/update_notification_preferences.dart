import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_preference_entity.dart';
import '../repositories/notification_repository.dart';

/// Use case for updating user notification preferences
class UpdateNotificationPreferences {
  final NotificationRepository repository;

  UpdateNotificationPreferences(this.repository);

  Future<Either<Failure, void>> call(
    NotificationPreferenceEntity preferences,
  ) async {
    return await repository.updatePreferences(preferences);
  }
}

// Made with Bob
