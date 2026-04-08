import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/promotions/presentation/pages/promotion_detail_page.dart';
import '../../features/promotions/presentation/pages/publish_promotion_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String promotionDetail = '/promotion-detail';
  static const String publishPromotion = '/publish-promotion';
  static const String notificationSettings = '/notification-settings';

  static GoRouter router(BuildContext context) => GoRouter(
    initialLocation: onboarding,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isAuthLoading = authState is AuthLoading;
      
      final isOnAuthPage = state.matchedLocation == login ||
          state.matchedLocation == register ||
          state.matchedLocation == forgotPassword ||
          state.matchedLocation == onboarding;
      
      // Si está cargando, no redirigir
      if (isAuthLoading) {
        return null;
      }
      
      // Si está autenticado y en página de auth, redirigir a home
      if (isAuthenticated && isOnAuthPage) {
        return home;
      }
      
      // Si no está autenticado y no está en página de auth, redirigir a login
      if (!isAuthenticated && !isOnAuthPage) {
        return login;
      }
      
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthBloc>().stream,
    ),
    routes: [
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: promotionDetail,
        builder: (context, state) {
          final promotionId = state.extra as String;
          return PromotionDetailPage(promotionId: promotionId);
        },
      ),
      GoRoute(
        path: publishPromotion,
        builder: (context, state) => const PublishPromotionPage(),
      ),
      GoRoute(
        path: notificationSettings,
        builder: (context, state) => const NotificationSettingsPage(),
      ),
    ],
  );
}

/// Stream que notifica a GoRouter cuando debe refrescar las rutas
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Made with Bob
