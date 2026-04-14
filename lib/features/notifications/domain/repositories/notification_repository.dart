import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';
import '../entities/notification_preference_entity.dart';

/// Abstract repository for notification operations
abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 20,
    int offset = 0,
  });

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<Either<Failure, void>> deleteAllNotifications();

  /// Get user notification preferences
  Future<Either<Failure, NotificationPreferenceEntity>> getPreferences();

  /// Update user notification preferences
  Future<Either<Failure, void>> updatePreferences(
    NotificationPreferenceEntity preferences,
  );

  /// Send a local notification
  Future<Either<Failure, void>> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// Schedule a local notification
  Future<Either<Failure, void>> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  });

  /// Cancel a scheduled notification
  Future<Either<Failure, void>> cancelScheduledNotification(int notificationId);

  /// Cancel all scheduled notifications
  Future<Either<Failure, void>> cancelAllScheduledNotifications();

  /// Initialize notification service
  Future<Either<Failure, void>> initialize();

  /// Request notification permissions
  Future<Either<Failure, bool>> requestPermissions();

  /// Check if notifications are enabled
  Future<Either<Failure, bool>> areNotificationsEnabled();

  /// Subscribe to realtime notifications
  Stream<NotificationEntity> subscribeToNotifications();

  /// Check for nearby promotions and send notifications
  Future<Either<Failure, void>> checkNearbyPromotions({
    required double latitude,
    required double longitude,
  });
}

// Made with Bob
