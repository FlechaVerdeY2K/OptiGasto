import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/badges_bloc.dart';
import '../bloc/badges_event.dart';
import '../bloc/badges_state.dart';
import '../widgets/badge_grid_widget.dart';
import '../widgets/badge_detail_dialog.dart';

/// Page to display all badges
class BadgesPage extends StatefulWidget {
  final String userId;

  const BadgesPage({
    super.key,
    required this.userId,
  });

  @override
  State<BadgesPage> createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  String? _selectedRarity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BadgesBloc>()
        ..add(LoadUserBadges(widget.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Insignias'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (rarity) {
                setState(() {
                  _selectedRarity = rarity == 'all' ? null : rarity;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Todas'),
                ),
                const PopupMenuItem(
                  value: 'legendary',
                  child: Text('Legendarias'),
                ),
                const PopupMenuItem(
                  value: 'epic',
                  child: Text('Épicas'),
                ),
                const PopupMenuItem(
                  value: 'rare',
                  child: Text('Raras'),
                ),
                const PopupMenuItem(
                  value: 'common',
                  child: Text('Comunes'),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<BadgesBloc, BadgesState>(
          builder: (context, state) {
            if (state is BadgesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is BadgesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar insignias',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BadgesBloc>().add(
                              LoadUserBadges(widget.userId),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is UserBadgesLoaded) {
              return Column(
                children: [
                  // Stats header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Desbloqueadas',
                          '${state.unlockedCount}',
                          Icons.emoji_events,
                        ),
                        _buildStatItem(
                          context,
                          'Total',
                          '${state.totalCount}',
                          Icons.stars,
                        ),
                        _buildStatItem(
                          context,
                          'Progreso',
                          '${state.progressPercentage.toStringAsFixed(0)}%',
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                  // Filter indicator
                  if (_selectedRarity != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.blue[50],
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Filtrando: ${_getRarityLabel(_selectedRarity!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedRarity = null;
                              });
                            },
                            child: const Text('Limpiar'),
                          ),
                        ],
                      ),
                    ),
                  // Badge grid
                  Expanded(
                    child: BadgeGridWidget(
                      allBadges: state.allBadges,
                      userBadges: state.userBadges,
                      filterRarity: _selectedRarity,
                      onBadgeTap: (badge, isUnlocked) {
                        final userBadge = isUnlocked
                            ? state.getUserBadgeByBadgeId(badge.id)
                            : null;
                        BadgeDetailDialog.show(
                          context,
                          badge: badge,
                          userBadge: userBadge,
                          isUnlocked: isUnlocked,
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('Estado desconocido'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  String _getRarityLabel(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return 'Legendarias';
      case 'epic':
        return 'Épicas';
      case 'rare':
        return 'Raras';
      case 'common':
        return 'Comunes';
      default:
        return rarity;
    }
  }
}

// Made with Bob
