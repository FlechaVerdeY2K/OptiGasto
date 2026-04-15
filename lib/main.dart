import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formateo de fechas para español
  await initializeDateFormatting('es_ES', null);

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
          create: (context) =>
              di.sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => di.sl<PromotionBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<LocationBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<NotificationBloc>()..add(const InitializeNotifications()),
        ),
        BlocProvider(
          create: (context) => di.sl<SettingsBloc>()..add(const LoadSettings()),
        ),
        BlocProvider(
          create: (context) => di.sl<ProfileBloc>(),
        ),
      ],
      child: const _AppView(),
    );
  }
}

/// Widget separado que crea el router UNA SOLA VEZ en initState.
/// Esto evita que cambios de tema (u otros rebuilds del BlocBuilder)
/// recreen GoRouter y reseteen la pila de navegación.
class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // El router se crea aquí, donde context ya tiene acceso a todos
    // los BLoC provistos por MultiBlocProvider en OptiGastoApp.
    _router = AppRouter.router(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) {
        // Solo reconstruir si el tema realmente cambió
        if (previous is SettingsLoaded && current is SettingsLoaded) {
          return previous.settings.themeMode != current.settings.themeMode;
        }
        return true;
      },
      builder: (context, settingsState) {
        // Determinar el modo de tema
        ThemeMode themeMode = ThemeMode.system;

        if (settingsState is SettingsLoaded) {
          switch (settingsState.settings.themeMode) {
            case 'light':
              themeMode = ThemeMode.light;
              break;
            case 'dark':
              themeMode = ThemeMode.dark;
              break;
            case 'system':
            default:
              themeMode = ThemeMode.system;
              break;
          }
        }

        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

// Made with Bob
