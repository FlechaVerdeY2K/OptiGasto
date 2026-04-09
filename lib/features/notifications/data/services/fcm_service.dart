import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';

/// Top-level function to handle background messages
/// This must be a top-level function (not a class method)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Handling background message: ${message.messageId}');
  
  // You can process the message here if needed
  // For example, update local database, show notification, etc.
}

/// Service for managing Firebase Cloud Messaging (FCM)
class FCMService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final SupabaseClient _supabaseClient;

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  FCMService({
    required FirebaseMessaging firebaseMessaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    required SupabaseClient supabaseClient,
  })  : _firebaseMessaging = firebaseMessaging,
        _localNotifications = localNotifications,
        _supabaseClient = supabaseClient;

  /// Stream of foreground messages
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      // Request notification permissions (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permissions');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional notification permissions');
      } else {
        print('User declined or has not accepted notification permissions');
        return;
      }

      // Get FCM token
      final token = await getToken();
      if (token != null) {
        await _saveTokenToDatabase(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received foreground message: ${message.messageId}');
        _messageController.add(message);
        _handleForegroundMessage(message);
      });

      // Handle background messages (when app is in background but not terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message opened app from background: ${message.messageId}');
        _handleMessageOpenedApp(message);
      });

      // Check if app was opened from a terminated state
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from terminated state: ${initialMessage.messageId}');
        _handleMessageOpenedApp(initialMessage);
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      print('FCM Service initialized successfully');
    } catch (e) {
      throw ServerException(message: 'Failed to initialize FCM: $e');
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await _removeTokenFromDatabase();
      print('FCM token deleted');
    } catch (e) {
      throw ServerException(message: 'Failed to delete FCM token: $e');
    }
  }

  /// Save token to Supabase database
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        print('No authenticated user, skipping token save');
        return;
      }

      await _supabaseClient.from('fcm_tokens').upsert({
        'user_id': user.id,
        'token': token,
        'platform': _getPlatform(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,token');

      print('FCM token saved to database');
    } catch (e) {
      print('Error saving FCM token to database: $e');
      // Don't throw exception, just log the error
    }
  }

  /// Remove token from database
  Future<void> _removeTokenFromDatabase() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return;

      final token = await getToken();
      if (token == null) return;

      await _supabaseClient
          .from('fcm_tokens')
          .delete()
          .eq('user_id', user.id)
          .eq('token', token);

      print('FCM token removed from database');
    } catch (e) {
      print('Error removing FCM token from database: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Nueva notificación',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle navigation based on message data
    final data = message.data;
    print('Message data: $data');

    // You can add navigation logic here based on notification type
    // For example:
    // if (data['type'] == 'promotion_nearby') {
    //   // Navigate to map page
    // }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'optigasto_fcm_channel',
      'OptiGasto Push Notifications',
      channelDescription: 'Notificaciones push de promociones y ofertas',
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get platform name
  String _getPlatform() {
    // This is a simple implementation
    // In production, you might want to use Platform.isAndroid/isIOS
    return 'android'; // or 'ios'
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      throw ServerException(message: 'Failed to subscribe to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      throw ServerException(message: 'Failed to unsubscribe from topic: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _messageController.close();
  }
}

// Made with Bob