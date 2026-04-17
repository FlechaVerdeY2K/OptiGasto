import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/send_password_reset_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/promotions/data/datasources/promotion_remote_data_source.dart';
import '../../features/promotions/data/repositories/promotion_repository_impl.dart';
import '../../features/promotions/domain/repositories/promotion_repository.dart';
import '../../features/promotions/domain/usecases/create_promotion.dart';
import '../../features/promotions/domain/usecases/upload_promotion_images.dart';
import '../../features/promotions/domain/usecases/report_promotion.dart';
import '../../features/promotions/presentation/bloc/promotion_bloc.dart';
import '../../features/promotions/presentation/bloc/publish_promotion_bloc.dart';
import '../../features/location/data/datasources/location_remote_data_source.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/check_location_permission.dart';
import '../../features/location/domain/usecases/get_current_location.dart';
import '../../features/location/domain/usecases/get_nearby_commerce_markers.dart';
import '../../features/location/domain/usecases/get_nearby_promotion_markers.dart';
import '../../features/location/domain/usecases/request_location_permission.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/check_nearby_promotions.dart';
import '../../features/notifications/domain/usecases/get_notification_preferences.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_as_read.dart';
import '../../features/notifications/domain/usecases/send_local_notification.dart';
import '../../features/notifications/domain/usecases/update_notification_preferences.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/data/services/fcm_service.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_promotion_history.dart';
import '../../features/profile/domain/usecases/get_user_profile.dart';
import '../../features/profile/domain/usecases/get_user_stats.dart';
import '../../features/profile/domain/usecases/mark_promotion_as_used.dart';
import '../../features/profile/domain/usecases/update_user_profile.dart';
import '../../features/profile/domain/usecases/upload_profile_photo.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/settings/data/settings_service.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import 'package:dio/dio.dart';
import '../../core/config/directions_config.dart';
import '../../features/route/data/datasources/directions_remote_data_source.dart';
import '../../features/route/data/repositories/route_repository_impl.dart';
import '../../features/route/domain/repositories/route_repository.dart';
import '../../features/route/domain/usecases/calculate_optimal_route.dart';
import '../../features/route/domain/usecases/build_navigation_url.dart';
import '../../features/route/presentation/bloc/route_planner_bloc.dart';
import '../../features/search/data/datasources/search_local_data_source.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/clear_search_history.dart';
import '../../features/search/domain/usecases/get_search_history.dart';
import '../../features/search/domain/usecases/get_search_suggestions.dart';
import '../../features/search/domain/usecases/search_promotions.dart';

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> initializeDependencies() async {
  // ========== External ==========
  // Supabase - se inicializa en main.dart
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ========== Data Sources ==========
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      supabase: sl(),
      googleSignIn: sl(),
    ),
  );

  // Promotions
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );

  // Location
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      supabaseClient: sl(),
      localNotifications: sl(),
    ),
  );

  // FCM Service
  sl.registerLazySingleton<FCMService>(
    () => FCMService(
      firebaseMessaging: sl(),
      localNotifications: sl(),
      supabaseClient: sl(),
    ),
  );

  // Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );

  // Search
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(supabase: sl()),
  );
  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(sharedPreferences: sl()),
  );
  // Settings
  sl.registerLazySingleton<SettingsService>(
    () => SettingsService(sl()),
  );

  // ========== Repositories ==========
  // Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Promotions
  sl.registerLazySingleton<PromotionRepository>(
    () => PromotionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Location
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Notifications
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Search
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // ========== Use Cases ==========
  // Auth
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmail(sl()));

  // Location
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));
  sl.registerLazySingleton(() => GetNearbyPromotionMarkers(sl()));
  sl.registerLazySingleton(() => GetNearbyCommerceMarkers(sl()));
  sl.registerLazySingleton(() => CheckLocationPermission(sl()));
  sl.registerLazySingleton(() => RequestLocationPermission(sl()));

  // Promotions
  sl.registerLazySingleton(() => CreatePromotion(sl()));
  sl.registerLazySingleton(() => UploadPromotionImages(sl()));
  sl.registerLazySingleton(() => ReportPromotion(sl()));

  // Notifications
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));
  sl.registerLazySingleton(() => GetNotificationPreferences(sl()));
  sl.registerLazySingleton(() => UpdateNotificationPreferences(sl()));
  sl.registerLazySingleton(() => SendLocalNotification(sl()));
  sl.registerLazySingleton(() => CheckNearbyPromotions(sl()));

  // Profile
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => UploadProfilePhoto(sl()));
  sl.registerLazySingleton(() => GetUserStats(sl()));
  sl.registerLazySingleton(() => GetPromotionHistory(sl()));
  sl.registerLazySingleton(() => MarkPromotionAsUsed(sl()));

  // Search
  sl.registerLazySingleton(() => SearchPromotions(sl()));
  sl.registerLazySingleton(() => GetSearchSuggestions(sl()));
  sl.registerLazySingleton(() => GetSearchHistory(sl()));
  sl.registerLazySingleton(() => ClearSearchHistory(sl()));

  // ========== BLoC ==========
  // Auth
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      sendPasswordResetEmail: sl(),
      authRepository: sl(),
    ),
  );

  // Promotions
  sl.registerFactory(
    () => PromotionBloc(
      repository: sl(),
    ),
  );

  // Publish Promotion
  sl.registerFactory(
    () => PublishPromotionBloc(
      createPromotion: sl(),
      uploadPromotionImages: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Location
  sl.registerFactory(
    () => LocationBloc(
      getCurrentLocation: sl(),
      getNearbyPromotionMarkers: sl(),
      getNearbyCommerceMarkers: sl(),
      checkLocationPermission: sl(),
      requestLocationPermission: sl(),
      repository: sl(),
      settingsService: sl(),
    ),
  );

  // Notifications
  sl.registerFactory(
    () => NotificationBloc(
      getNotifications: sl(),
      markAsRead: sl(),
      getNotificationPreferences: sl(),
      updateNotificationPreferences: sl(),
      sendLocalNotification: sl(),
      checkNearbyPromotions: sl(),
      repository: sl(),
    ),
  );

  // Profile
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      uploadProfilePhoto: sl(),
      getUserStats: sl(),
      getPromotionHistory: sl(),
      markPromotionAsUsed: sl(),
    ),
  );
  // Settings
  sl.registerFactory(
    () => SettingsBloc(sl()),
  );

  // ========== Route Feature ==========
  // External
  sl.registerLazySingleton(() => Dio());

  // Data Sources
  sl.registerLazySingleton<DirectionsRemoteDataSource>(
    () => DirectionsRemoteDataSourceImpl(
      dio: sl(),
      apiKey: DirectionsConfig.apiKey,
    ),
  );

  // Repositories
  sl.registerLazySingleton<RouteRepository>(
    () => RouteRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CalculateOptimalRoute(sl()));
  sl.registerLazySingleton(() => BuildNavigationUrl());

  // BLoC
  sl.registerFactory(
    () => RoutePlannerBloc(
      calculateOptimalRoute: sl(),
      buildNavigationUrl: sl(),
      getCurrentLocation: sl(),
    ),
  );
}

// Made with Bob
