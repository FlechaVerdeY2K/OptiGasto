import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación
Future<void> initializeDependencies() async {
  // ========== External ==========
  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // ========== Data Sources ==========
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // Promotions
  sl.registerLazySingleton<PromotionRemoteDataSource>(
    () => PromotionRemoteDataSourceImpl(
      firestore: sl(),
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

  // ========== Use Cases ==========
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmail(sl()));

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
}

// Made with Bob
