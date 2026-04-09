import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/check_nearby_promotions.dart';
import '../../domain/usecases/get_notification_preferences.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_as_read.dart';
import '../../domain/usecases/send_local_notification.dart';
import '../../domain/usecases/update_notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final MarkAsRead markAsRead;
  final GetNotificationPreferences getNotificationPreferences;
  final UpdateNotificationPreferences updateNotificationPreferences;
  final SendLocalNotification sendLocalNotification;
  final CheckNearbyPromotions checkNearbyPromotions;
  final NotificationRepository repository;

  StreamSubscription<NotificationEntity>? _realtimeSubscription;
  List<NotificationEntity> _notifications = [];
  int _currentPage = 0;
  static const int _pageSize = 20;

  NotificationBloc({
    required this.getNotifications,
    required this.markAsRead,
    required this.getNotificationPreferences,
    required this.updateNotificationPreferences,
    required this.sendLocalNotification,
    required this.checkNearbyPromotions,
    required this.repository,
  }) : super(const NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<DeleteAllNotifications>(_onDeleteAllNotifications);
    on<LoadNotificationPreferences>(_onLoadNotificationPreferences);
    on<UpdateNotificationPreferencesEvent>(_onUpdateNotificationPreferences);
    on<RequestNotificationPermissions>(_onRequestNotificationPermissions);
    on<CheckNotificationsEnabled>(_onCheckNotificationsEnabled);
    on<SendLocalNotificationEvent>(_onSendLocalNotification);
    on<CheckNearbyPromotionsEvent>(_onCheckNearbyPromotions);
    on<NotificationReceived>(_onNotificationReceived);
    on<SubscribeToRealtimeNotifications>(_onSubscribeToRealtimeNotifications);
    on<UnsubscribeFromRealtimeNotifications>(_onUnsubscribeFromRealtimeNotifications);
  }

  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final initResult = await repository.initialize();
    final permissionsResult = await repository.requestPermissions();

    initResult.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        permissionsResult.fold(
          (failure) => emit(NotificationError(failure.message)),
          (granted) {
            emit(NotificationServiceInitialized(permissionsGranted: granted));
            // Auto-subscribe to realtime after initialization
            add(const SubscribeToRealtimeNotifications());
            // Load initial notifications
            add(const LoadNotifications());
          },
        );
      },
    );
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.refresh) {
      _currentPage = 0;
      _notifications = [];
    }

    emit(const NotificationLoading());

    final result = await getNotifications(
      limit: _pageSize,
      offset: _currentPage * _pageSize,
    );

    final unreadCountResult = await repository.getUnreadCount();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        _notifications = event.refresh ? notifications : _notifications + notifications;
        
        unreadCountResult.fold(
          (failure) => emit(NotificationError(failure.message)),
          (unreadCount) {
            emit(NotificationsLoaded(
              notifications: _notifications,
              unreadCount: unreadCount,
              hasMore: notifications.length == _pageSize,
            ));
          },
        );
      },
    );
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      
      if (!currentState.hasMore || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      _currentPage++;

      final result = await getNotifications(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      result.fold(
        (failure) {
          _currentPage--;
          emit(NotificationError(failure.message));
        },
        (notifications) {
          _notifications.addAll(notifications);
          
          emit(currentState.copyWith(
            notifications: _notifications,
            hasMore: notifications.length == _pageSize,
            isLoadingMore: false,
          ));
        },
      );
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAsRead(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        // Update local list
        _notifications = _notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(
              isRead: true,
              readAt: DateTime.now(),
            );
          }
          return notification;
        }).toList();

        // Get updated unread count
        repository.getUnreadCount().then((countResult) {
          countResult.fold(
            (failure) => emit(NotificationError(failure.message)),
            (unreadCount) {
              if (state is NotificationsLoaded) {
                emit((state as NotificationsLoaded).copyWith(
                  notifications: _notifications,
                  unreadCount: unreadCount,
                ));
              }
            },
          );
        });

        emit(NotificationMarkedAsRead(event.notificationId));
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.markAllAsRead();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        // Update local list
        _notifications = _notifications.map((notification) {
          return notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }).toList();

        if (state is NotificationsLoaded) {
          emit((state as NotificationsLoaded).copyWith(
            notifications: _notifications,
            unreadCount: 0,
          ));
        }

        emit(const AllNotificationsMarkedAsRead());
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.deleteNotification(event.notificationId);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        // Remove from local list
        _notifications.removeWhere((n) => n.id == event.notificationId);

        // Get updated unread count
        repository.getUnreadCount().then((countResult) {
          countResult.fold(
            (failure) => emit(NotificationError(failure.message)),
            (unreadCount) {
              if (state is NotificationsLoaded) {
                emit((state as NotificationsLoaded).copyWith(
                  notifications: _notifications,
                  unreadCount: unreadCount,
                ));
              }
            },
          );
        });

        emit(NotificationDeleted(event.notificationId));
      },
    );
  }

  Future<void> _onDeleteAllNotifications(
    DeleteAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.deleteAllNotifications();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) {
        _notifications = [];
        _currentPage = 0;

        emit(const NotificationsLoaded(
          notifications: [],
          unreadCount: 0,
          hasMore: false,
        ));

        emit(const AllNotificationsDeleted());
      },
    );
  }

  Future<void> _onLoadNotificationPreferences(
    LoadNotificationPreferences event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await getNotificationPreferences();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (preferences) => emit(NotificationPreferencesLoaded(preferences)),
    );
  }

  Future<void> _onUpdateNotificationPreferences(
    UpdateNotificationPreferencesEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await updateNotificationPreferences(event.preferences);

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(NotificationPreferencesUpdated(event.preferences)),
    );
  }

  Future<void> _onRequestNotificationPermissions(
    RequestNotificationPermissions event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.requestPermissions();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (granted) => emit(NotificationServiceInitialized(permissionsGranted: granted)),
    );
  }

  Future<void> _onCheckNotificationsEnabled(
    CheckNotificationsEnabled event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await repository.areNotificationsEnabled();

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (enabled) => emit(NotificationPermissionsChecked(enabled: enabled)),
    );
  }

  Future<void> _onSendLocalNotification(
    SendLocalNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await sendLocalNotification(
      title: event.title,
      body: event.body,
      data: event.data,
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const LocalNotificationSent()),
    );
  }

  Future<void> _onCheckNearbyPromotions(
    CheckNearbyPromotionsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await checkNearbyPromotions(
      latitude: event.latitude,
      longitude: event.longitude,
    );

    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (_) => emit(const NearbyPromotionsChecked()),
    );
  }

  Future<void> _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    // Reload notifications when a new one is received
    add(const LoadNotifications(refresh: true));
  }

  Future<void> _onSubscribeToRealtimeNotifications(
    SubscribeToRealtimeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _realtimeSubscription?.cancel();

    _realtimeSubscription = repository.subscribeToNotifications().listen(
      (notification) {
        add(NotificationReceived(notification.id));
        // Don't emit here - use add() to trigger new event instead
      },
      onError: (error) {
        // Don't emit here - log error instead
        print('Realtime notification error: $error');
      },
    );

    emit(const SubscribedToRealtime());
  }

  Future<void> _onUnsubscribeFromRealtimeNotifications(
    UnsubscribeFromRealtimeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _realtimeSubscription?.cancel();
    _realtimeSubscription = null;

    emit(const UnsubscribedFromRealtime());
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    return super.close();
  }
}

// Made with Bob
