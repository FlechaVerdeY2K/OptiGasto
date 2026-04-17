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
import '../../features/notifications/presentation/pages/notifications_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/user_stats_page.dart';
import '../../features/profile/presentation/pages/promotion_history_page.dart';
import '../../features/settings/presentation/pages/app_settings_page.dart';
import '../../features/settings/presentation/pages/location_settings_page.dart';
import '../../features/settings/presentation/pages/theme_settings_page.dart';
import '../../features/settings/presentation/pages/filters_settings_page.dart';
import '../../features/settings/presentation/pages/privacy_settings_page.dart';
import '../../features/settings/presentation/pages/data_settings_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/route/presentation/pages/route_planner_page.dart';
import '../../features/route/presentation/pages/route_result_page.dart';
import '../../features/route/presentation/pages/map_picker_page.dart';
import '../../features/route/domain/entities/optimized_route_entity.dart';
import '../../features/route/presentation/bloc/route_planner_bloc.dart';
import '../../features/route/presentation/bloc/route_planner_event.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../di/injection_container.dart';

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
  static const String notificationsList = '/notifications';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String userStats = '/user-stats';
  static const String promotionHistory = '/promotion-history';
  static const String settings = '/settings';
  static const String locationSettings = '/settings/location';
  static const String themeSettings = '/settings/theme';
  static const String filtersSettings = '/settings/filters';
  static const String privacySettings = '/settings/privacy';
  static const String dataSettings = '/settings/data';
  static const String routePlanner = '/route/planner';
  static const String routeResult = '/route/result';
  static const String routeMapPicker = '/route/map-picker';
  static const String search = '/search';

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
          GoRoute(
            path: notificationsList,
            builder: (context, state) => const NotificationsListPage(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: editProfile,
            builder: (context, state) {
              final user = state.extra as UserEntity;
              return EditProfilePage(user: user);
            },
          ),
          GoRoute(
            path: userStats,
            builder: (context, state) => const UserStatsPage(),
          ),
          GoRoute(
            path: promotionHistory,
            builder: (context, state) => const PromotionHistoryPage(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const AppSettingsPage(),
          ),
          GoRoute(
            path: locationSettings,
            builder: (context, state) => const LocationSettingsPage(),
          ),
          GoRoute(
            path: themeSettings,
            builder: (context, state) => const ThemeSettingsPage(),
          ),
          GoRoute(
            path: filtersSettings,
            builder: (context, state) => const FiltersSettingsPage(),
          ),
          GoRoute(
            path: privacySettings,
            builder: (context, state) => const PrivacySettingsPage(),
          ),
          GoRoute(
            path: dataSettings,
            builder: (context, state) => const DataSettingsPage(),
          ),
          GoRoute(
            path: routePlanner,
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final methodStr = extra?['method'] as String?;
              final initialMethod = switch (methodStr) {
                'favorites' => StopSelectionMethod.favorites,
                'nearby' => StopSelectionMethod.nearby,
                _ => StopSelectionMethod.map,
              };
              return BlocProvider(
                create: (_) {
                  final bloc = sl<RoutePlannerBloc>()
                    ..add(const RoutePlannerInitialized());
                  if (initialMethod != StopSelectionMethod.map) {
                    bloc.add(StopSelectionMethodChanged(method: initialMethod));
                  }
                  return bloc;
                },
                child: const RoutePlannerPage(),
              );
            },
          ),
          GoRoute(
            path: routeResult,
            builder: (context, state) {
              final route = state.extra as OptimizedRouteEntity;
              return RouteResultPage(route: route);
            },
          ),
          GoRoute(
            path: routeMapPicker,
            builder: (context, state) => BlocProvider.value(
              value: context.read<LocationBloc>(),
              child: const MapPickerPage(),
            ),
          ),
          GoRoute(
            path: search,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<SearchBloc>(),
              child: const SearchPage(),
            ),
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
