import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_preference_entity.dart';

/// Base class for notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize notification service
class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

/// Event to load notifications
class LoadNotifications extends NotificationEvent {
  final bool refresh;

  const LoadNotifications({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Event to load more notifications (pagination)
class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}

/// Event to mark a notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Event to delete a notification
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to delete all notifications
class DeleteAllNotifications extends NotificationEvent {
  const DeleteAllNotifications();
}

/// Event to load notification preferences
class LoadNotificationPreferences extends NotificationEvent {
  const LoadNotificationPreferences();
}

/// Event to update notification preferences
class UpdateNotificationPreferencesEvent extends NotificationEvent {
  final NotificationPreferenceEntity preferences;

  const UpdateNotificationPreferencesEvent(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Event to request notification permissions
class RequestNotificationPermissions extends NotificationEvent {
  const RequestNotificationPermissions();
}

/// Event to check if notifications are enabled
class CheckNotificationsEnabled extends NotificationEvent {
  const CheckNotificationsEnabled();
}

/// Event to send a local notification
class SendLocalNotificationEvent extends NotificationEvent {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  const SendLocalNotificationEvent({
    required this.title,
    required this.body,
    this.data,
  });

  @override
  List<Object?> get props => [title, body, data];
}

/// Event to check for nearby promotions
class CheckNearbyPromotionsEvent extends NotificationEvent {
  final double latitude;
  final double longitude;

  const CheckNearbyPromotionsEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Event when a new notification is received via realtime
class NotificationReceived extends NotificationEvent {
  final String notificationId;

  const NotificationReceived(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to subscribe to realtime notifications
class SubscribeToRealtimeNotifications extends NotificationEvent {
  const SubscribeToRealtimeNotifications();
}

/// Event to unsubscribe from realtime notifications
class UnsubscribeFromRealtimeNotifications extends NotificationEvent {
  const UnsubscribeFromRealtimeNotifications();
}

// Made with Bob
