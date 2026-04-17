import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

/// Page to display leaderboards
class LeaderboardPage extends StatefulWidget {
  final String? userId;

  const LeaderboardPage({
    super.key,
    this.userId,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentPeriod = 'weekly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentPeriod = _getPeriodFromIndex(_tabController.index);
      });
    }
  }

  String _getPeriodFromIndex(int index) {
    switch (index) {
      case 0:
        return 'weekly';
      case 1:
        return 'monthly';
      case 2:
        return 'yearly';
      default:
        return 'weekly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LeaderboardBloc>()
        ..add(LoadLeaderboard(period: _currentPeriod)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ranking'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Semanal'),
              Tab(text: 'Mensual'),
              Tab(text: 'Anual'),
            ],
          ),
        ),
        body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) {
            if (state is LeaderboardLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is LeaderboardError) {
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
                      'Error al cargar ranking',
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
                        context.read<LeaderboardBloc>().add(
                              LoadLeaderboard(period: _currentPeriod),
                            );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is LeaderboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<LeaderboardBloc>().add(
                        RefreshLeaderboard(_currentPeriod),
                      );
                },
                child: CustomScrollView(
                  slivers: [
                    // Top 3 podium
                    if (state.topThree.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildPodium(context, state.topThree),
                      ),
                    // User's rank (if not in top 3)
                    if (widget.userId != null &&
                        state.userEntry != null &&
                        !state.isUserInTopThree)
                      SliverToBoxAdapter(
                        child: _buildUserRankCard(context, state.userEntry!),
                      ),
                    // Remaining entries
                    if (state.remainingEntries.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final entry = state.remainingEntries[index];
                              final isCurrentUser =
                                  widget.userId != null &&
                                      entry.userId == widget.userId;
                              return _buildLeaderboardItem(
                                context,
                                entry,
                                isCurrentUser,
                              );
                            },
                            childCount: state.remainingEntries.length,
                          ),
                        ),
                      ),
                    // Empty state
                    if (state.entries.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.leaderboard_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay datos de ranking',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
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

  Widget _buildPodium(BuildContext context, List<LeaderboardEntryEntity> topThree) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topThree.length > 1)
            _buildPodiumPlace(context, topThree[1], 2, 100),
          const SizedBox(width: 16),
          // 1st place
          _buildPodiumPlace(context, topThree[0], 1, 120),
          const SizedBox(width: 16),
          // 3rd place
          if (topThree.length > 2)
            _buildPodiumPlace(context, topThree[2], 3, 80),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    BuildContext context,
    LeaderboardEntryEntity entry,
    int place,
    double height,
  ) {
    final colors = {
      1: Colors.amber,
      2: Colors.grey[400]!,
      3: Colors.brown[300]!,
    };

    return Column(
      children: [
        // Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colors[place]!.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors[place]!,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              entry.username.substring(0, 1).toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors[place],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Username
        SizedBox(
          width: 80,
          child: Text(
            entry.username,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 4),
        // Points
        Text(
          '${entry.totalPoints} pts',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 8),
        // Podium
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: colors[place],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$place',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRankCard(BuildContext context, LeaderboardEntryEntity entry) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu posición',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  entry.username,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.totalPoints}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              Text(
                'puntos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    LeaderboardEntryEntity entry,
    bool isCurrentUser,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrentUser
          ? Theme.of(context).primaryColor.withOpacity(0.05)
          : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrentUser
                ? Theme.of(context).primaryColor
                : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${entry.rank}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isCurrentUser ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        title: Text(
          entry.username,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('Nivel ${entry.level}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalPoints}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? Theme.of(context).primaryColor : null,
                  ),
            ),
            Text(
              'puntos',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
