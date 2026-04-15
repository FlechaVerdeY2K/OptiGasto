import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/notification_preference_entity.dart';

/// Base class for notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// State when notifications are loaded
class NotificationsLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props =>
      [notifications, unreadCount, hasMore, isLoadingMore];

  NotificationsLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// State when notification preferences are loaded
class NotificationPreferencesLoaded extends NotificationState {
  final NotificationPreferenceEntity preferences;

  const NotificationPreferencesLoaded(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// State when notification preferences are updated
class NotificationPreferencesUpdated extends NotificationState {
  final NotificationPreferenceEntity preferences;

  const NotificationPreferencesUpdated(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// State when a notification is marked as read
class NotificationMarkedAsRead extends NotificationState {
  final String notificationId;

  const NotificationMarkedAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// State when all notifications are marked as read
class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();
}

/// State when a notification is deleted
class NotificationDeleted extends NotificationState {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// State when all notifications are deleted
class AllNotificationsDeleted extends NotificationState {
  const AllNotificationsDeleted();
}

/// State when notification service is initialized
class NotificationServiceInitialized extends NotificationState {
  final bool permissionsGranted;

  const NotificationServiceInitialized({required this.permissionsGranted});

  @override
  List<Object?> get props => [permissionsGranted];
}

/// State when notification permissions are checked
class NotificationPermissionsChecked extends NotificationState {
  final bool enabled;

  const NotificationPermissionsChecked({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

/// State when a local notification is sent
class LocalNotificationSent extends NotificationState {
  const LocalNotificationSent();
}

/// State when nearby promotions are checked
class NearbyPromotionsChecked extends NotificationState {
  const NearbyPromotionsChecked();
}

/// State when a new notification is received via realtime
class NewNotificationReceived extends NotificationState {
  final NotificationEntity notification;

  const NewNotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// State when subscribed to realtime notifications
class SubscribedToRealtime extends NotificationState {
  const SubscribedToRealtime();
}

/// State when unsubscribed from realtime notifications
class UnsubscribedFromRealtime extends NotificationState {
  const UnsubscribedFromRealtime();
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Made with Bob
