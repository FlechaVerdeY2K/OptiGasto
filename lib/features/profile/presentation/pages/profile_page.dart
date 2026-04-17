import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../gamification/presentation/bloc/gamification_bloc.dart';
import '../../../gamification/presentation/bloc/gamification_event.dart';
import '../../../gamification/presentation/bloc/gamification_state.dart';
import '../../../gamification/presentation/bloc/badges_bloc.dart';
import '../../../gamification/presentation/bloc/badges_event.dart';
import '../../../gamification/presentation/bloc/badges_state.dart';
import '../../../gamification/presentation/widgets/points_display_widget.dart';
import '../../../gamification/presentation/widgets/badges_showcase_widget.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/stats_card_widget.dart';
import '../widgets/recent_history_widget.dart';

/// Página principal del perfil de usuario
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProfileBloc>()..add(RefreshProfile(userId)),
        ),
        BlocProvider(
          create: (_) =>
              sl<GamificationBloc>()..add(LoadUserGamificationStats(userId)),
        ),
        BlocProvider(
          create: (_) => sl<BadgesBloc>()
            ..add(LoadUserBadges(userId))
            ..add(const LoadAllBadges()),
        ),
      ],
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Recargar perfil
            context.read<ProfileBloc>().add(RefreshProfile(state.user.id));
          } else if (state is PromotionMarkedAsUsed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ProfileLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(RefreshProfile(state.user.id));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header con foto y datos básicos
                    ProfileHeaderWidget(
                      user: state.user,
                      onEditPressed: () {
                        context.push('/edit-profile', extra: state.user);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Gamification: points + level display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<GamificationBloc, GamificationState>(
                        builder: (context, gamState) {
                          if (gamState is GamificationLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (gamState is GamificationStatsLoaded) {
                            return PointsDisplayWidget(
                              stats: gamState.stats,
                              onTap: () => context.push('/leaderboard'),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Gamification: badges showcase
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<BadgesBloc, BadgesState>(
                        builder: (context, badgesState) {
                          if (badgesState is BadgesLoading) {
                            return const SizedBox.shrink();
                          }
                          if (badgesState is UserBadgesLoaded) {
                            return BadgesShowcaseWidget(
                              userBadges: badgesState.userBadges,
                              allBadges: badgesState.allBadges,
                              onViewAll: () => context.push('/badges'),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Estadísticas
                    if (state.stats != null)
                      StatsCardWidget(stats: state.stats!),

                    const SizedBox(height: 16),

                    // Historial reciente
                    if (state.history != null && state.history!.isNotEmpty)
                      RecentHistoryWidget(
                        history: state.history!,
                        onViewAll: () {
                          context.push('/promotion-history',
                              extra: state.user.id);
                        },
                      ),

                    const SizedBox(height: 16),

                    // Botones de acción
                    _buildActionButtons(context, state.user.id),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar el perfil',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    final userId =
                        authState is AuthAuthenticated ? authState.user.id : '';
                    context.read<ProfileBloc>().add(RefreshProfile(userId));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionButton(
            context: context,
            icon: Icons.emoji_events_outlined,
            label: 'Ver Leaderboard',
            onTap: () => context.push('/leaderboard'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.military_tech_outlined,
            label: 'Mis Insignias',
            onTap: () => context.push('/badges'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.history,
            label: 'Ver Historial Completo',
            onTap: () {
              context.push('/promotion-history', extra: userId);
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.bar_chart,
            label: 'Ver Estadísticas Detalladas',
            onTap: () {
              context.push('/user-stats', extra: userId);
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context: context,
            icon: Icons.logout,
            label: 'Cerrar Sesión',
            color: Colors.red,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
