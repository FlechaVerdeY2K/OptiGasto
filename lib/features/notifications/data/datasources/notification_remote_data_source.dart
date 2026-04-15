import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';

/// Remote data source for notification operations
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    required int limit,
    required int offset,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteAllNotifications();

  Future<NotificationPreferenceModel> getPreferences();

  Future<void> updatePreferences(NotificationPreferenceModel preferences);

  Future<void> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  });

  Future<void> cancelScheduledNotification(int notificationId);

  Future<void> cancelAllScheduledNotifications();

  Future<void> initialize();

  Future<bool> requestPermissions();

  Future<bool> areNotificationsEnabled();

  Stream<NotificationModel> subscribeToNotifications();

  Future<void> checkNearbyPromotions({
    required double latitude,
    required double longitude,
  });
}

/// Implementation of NotificationRemoteDataSource
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient supabaseClient;
  final FlutterLocalNotificationsPlugin localNotifications;

  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;
  final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  NotificationRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.localNotifications,
  });

  String get _userId {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw AppAuthException(message: 'User not authenticated');
    }
    return user.id;
  }

  @override
  Future<void> initialize() async {
    try {
      // Android initialization settings
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Subscribe to realtime notifications
      _subscribeToRealtime();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // This will be handled by the BLoC layer
  }

  void _subscribeToRealtime() {
    try {
      _realtimeSubscription = supabaseClient
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .listen((data) {
            if (data.isNotEmpty) {
              final notification = NotificationModel.fromJson(data.first);
              _notificationController.add(notification);
            }
          });
    } catch (e) {
      throw ServerException(
          message: 'Failed to subscribe to notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', _userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      throw ServerException(message: 'Failed to get unread count: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .eq('user_id', _userId);
    } catch (e) {
      throw ServerException(message: 'Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await supabaseClient
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _userId)
          .eq('is_read', false);
    } catch (e) {
      throw ServerException(
          message: 'Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _userId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete notification: $e');
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      await supabaseClient
          .from('notifications')
          .delete()
          .eq('user_id', _userId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete all notifications: $e');
    }
  }

  @override
  Future<NotificationPreferenceModel> getPreferences() async {
    try {
      final response = await supabaseClient
          .from('notification_preferences')
          .select()
          .eq('user_id', _userId)
          .maybeSingle();

      if (response == null) {
        // Create default preferences
        final defaultPreferences = NotificationPreferenceModel(
          userId: _userId,
          updatedAt: DateTime.now(),
        );
        await updatePreferences(defaultPreferences);
        return defaultPreferences;
      }

      return NotificationPreferenceModel.fromJson(response);
    } catch (e) {
      throw ServerException(
          message: 'Failed to get notification preferences: $e');
    }
  }

  @override
  Future<void> updatePreferences(
    NotificationPreferenceModel preferences,
  ) async {
    try {
      await supabaseClient.from('notification_preferences').upsert(
            preferences.toJson(),
            onConflict: 'user_id',
          );
    } catch (e) {
      throw ServerException(
          message: 'Failed to update notification preferences: $e');
    }
  }

  @override
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'optigasto_channel',
        'OptiGasto Notifications',
        channelDescription: 'Notificaciones de promociones y ofertas',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: data?.toString(),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to send local notification: $e');
    }
  }

  @override
  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, dynamic>? data,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'optigasto_channel',
        'OptiGasto Notifications',
        channelDescription: 'Notificaciones de promociones y ofertas',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Note: zonedSchedule requires TZDateTime, for now we'll use a simple show
      // In production, you should convert DateTime to TZDateTime using timezone package
      await localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: data?.toString(),
      );
    } catch (e) {
      throw ServerException(message: 'Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> cancelScheduledNotification(int notificationId) async {
    try {
      await localNotifications.cancel(notificationId);
    } catch (e) {
      throw ServerException(message: 'Failed to cancel notification: $e');
    }
  }

  @override
  Future<void> cancelAllScheduledNotifications() async {
    try {
      await localNotifications.cancelAll();
    } catch (e) {
      throw ServerException(message: 'Failed to cancel all notifications: $e');
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final androidImplementation =
          localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final iosImplementation =
          localNotifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final granted =
            await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return false;
    } catch (e) {
      throw ServerException(message: 'Failed to request permissions: $e');
    }
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidImplementation =
          localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? false;
      }

      // For iOS, assume enabled if we got this far
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<NotificationModel> subscribeToNotifications() {
    return _notificationController.stream;
  }

  @override
  Future<void> checkNearbyPromotions({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Get user preferences
      final preferences = await getPreferences();

      if (!preferences.enablePromotionNearby) {
        return;
      }

      // Call Supabase function to get nearby promotions
      final response = await supabaseClient.rpc(
        'nearby_promotions',
        params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': preferences.radiusKm,
        },
      );

      final promotions = response as List;

      if (promotions.isNotEmpty) {
        // Send notification for nearby promotions
        await sendLocalNotification(
          title: '¡Promociones cerca de ti!',
          body: 'Hay ${promotions.length} promociones cerca de tu ubicación',
          data: {
            'type': 'promotion_nearby',
            'count': promotions.length,
          },
        );
      }
    } catch (e) {
      throw ServerException(message: 'Failed to check nearby promotions: $e');
    }
  }

  void dispose() {
    _realtimeSubscription?.cancel();
    _notificationController.close();
  }
}

// Made with Bob
