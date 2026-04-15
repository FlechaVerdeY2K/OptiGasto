import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_preference_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_preference_model.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final notifications = await remoteDataSource.getNotifications(
        limit: limit,
        offset: offset,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
      String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      await remoteDataSource.deleteAllNotifications();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationPreferenceEntity>> getPreferences() async {
    try {
      final preferences = await remoteDataSource.getPreferences();
      return Right(preferences);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferenceEntity preferences,
  ) async {
    try {
      final model = NotificationPreferenceModel.fromEntity(preferences);
      await remoteDataSource.updatePreferences(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await remoteDataSource.sendLocalNotification(
        title: title,
        body: body,
        data: data,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  }) async {
    try {
      await remoteDataSource.scheduleLocalNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        data: data,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelScheduledNotification(
    int notificationId,
  ) async {
    try {
      await remoteDataSource.cancelScheduledNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAllScheduledNotifications() async {
    try {
      await remoteDataSource.cancelAllScheduledNotifications();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      await remoteDataSource.initialize();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermissions() async {
    try {
      final granted = await remoteDataSource.requestPermissions();
      return Right(granted);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> areNotificationsEnabled() async {
    try {
      final enabled = await remoteDataSource.areNotificationsEnabled();
      return Right(enabled);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<NotificationEntity> subscribeToNotifications() {
    return remoteDataSource.subscribeToNotifications();
  }

  @override
  Future<Either<Failure, void>> checkNearbyPromotions({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await remoteDataSource.checkNearbyPromotions(
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppAuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

// Made with Bob
