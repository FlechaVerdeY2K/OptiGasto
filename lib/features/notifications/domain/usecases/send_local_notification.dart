import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/notification_repository.dart';

/// Use case for sending a local notification
class SendLocalNotification {
  final NotificationRepository repository;

  SendLocalNotification(this.repository);

  Future<Either<Failure, void>> call({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    return await repository.sendLocalNotification(
      title: title,
      body: body,
      data: data,
    );
  }
}

// Made with Bob
