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
import '../../features/promotions/presentation/bloc/promotion_bloc.dart';
import '../../features/location/data/datasources/location_remote_data_source.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/check_location_permission.dart';
import '../../features/location/domain/usecases/get_current_location.dart';
import '../../features/location/domain/usecases/get_nearby_commerce_markers.dart';
import '../../features/location/domain/usecases/get_nearby_promotion_markers.dart';
import '../../features/location/domain/usecases/request_location_permission.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> initializeDependencies() async {
  // ========== External ==========
  // Supabase - se inicializa en main.dart
  sl.registerLazySingleton(() => Supabase.instance.client);
  sl.registerLazySingleton(() => GoogleSignIn());

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
}

// Made with Bob
