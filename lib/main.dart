import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/promotions/presentation/bloc/promotion_bloc.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'features/notifications/data/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: SupabaseConfig.autoRefreshToken,
    ),
  );
  
  // Inicializar dependencias
  await di.initializeDependencies();
  
  // Inicializar FCM Service
  try {
    final fcmService = di.sl<FCMService>();
    await fcmService.initialize();
    print('FCM Service initialized successfully');
  } catch (e) {
    print('Error initializing FCM Service: $e');
    // Continue app execution even if FCM fails
  }
  
  // Configurar orientación de pantalla (solo móvil)
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Configurar barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (e) {
    // Ignorar errores de orientación en web
    debugPrint('Platform-specific configuration skipped: $e');
  }
  
  runApp(const OptiGastoApp());
}

class OptiGastoApp extends StatelessWidget {
  const OptiGastoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()
            ..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<PromotionBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<LocationBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<NotificationBloc>()
            ..add(const InitializeNotifications()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router(context),
          );
        },
      ),
    );
  }
}

// Made with Bob
