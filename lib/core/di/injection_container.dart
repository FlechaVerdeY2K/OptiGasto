import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
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


final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> initializeDependencies() async {
  // ========== External ==========
  // Supabase - se inicializa en main.dart
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => GoogleSignIn());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

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
      getCurrentLocation: sl(),
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
}

// Made with Bob
