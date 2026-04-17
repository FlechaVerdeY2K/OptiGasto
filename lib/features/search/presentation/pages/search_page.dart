import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../promotions/presentation/bloc/promotion_bloc.dart';
import '../../../promotions/presentation/bloc/promotion_state.dart';
import '../../domain/entities/search_filters.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../widgets/search_filters_bottom_sheet.dart';
import '../widgets/search_history_list.dart';
import '../widgets/search_result_card.dart';
import '../widgets/search_suggestions_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  SearchFilters _activeFilters = const SearchFilters();

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SearchInitialized());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit() {
    final text = _searchController.text.trim();
    if (text.isEmpty) return;
    context.read<SearchBloc>()
      ..add(SearchFiltersChanged(_activeFilters))
      ..add(const SearchSubmitted());
  }

  void _openFilters() {
    final promotionState = context.read<PromotionBloc>().state;
    final categories = promotionState is PromotionLoaded
        ? promotionState.categories
        : <dynamic>[];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SearchFiltersBottomSheet(
        initialFilters: _activeFilters,
        categories: categories.cast(),
        onApply: (filters) {
          setState(() => _activeFilters = filters);
          context.read<SearchBloc>()
            ..add(SearchFiltersChanged(filters))
            ..add(const SearchSubmitted());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar promociones...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (_, value, __) {
                return value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<SearchBloc>()
                              .add(const SearchQueryChanged(''));
                        },
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
          onChanged: (text) =>
              context.read<SearchBloc>().add(SearchQueryChanged(text)),
          onSubmitted: (_) => _onSearchSubmit(),
        ),
      ),
      body: Column(
        children: [
          // Quick filter chips
          _buildQuickFilters(),
          // Advanced filters button
          _buildFiltersRow(),
          const Divider(height: 1),
          // Dynamic body
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollUpdateNotification) {
                      FocusScope.of(context).unfocus();
                    }
                    return false;
                  },
                  child: _buildBody(state),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _QuickChip(
            label: 'Últimas 24h',
            icon: Icons.schedule,
            isActive: _activeFilters.dateFrom != null &&
                DateTime.now().difference(_activeFilters.dateFrom!).inHours <=
                    24,
            onTap: () {
              final isCurrentlyActive = _activeFilters.dateFrom != null &&
                  DateTime.now().difference(_activeFilters.dateFrom!).inHours <=
                      24;

              final SearchFilters newFilters;
              if (isCurrentlyActive) {
                // Deactivate: clear date filters
                newFilters = _activeFilters.copyWith(
                  clearDateFrom: true,
                  clearDateTo: true,
                );
              } else {
                // Activate: set last 24h
                final now = DateTime.now();
                newFilters = _activeFilters.copyWith(
                  dateFrom: now.subtract(const Duration(hours: 24)),
                  dateTo: now,
                );
              }
              setState(() => _activeFilters = newFilters);
              context.read<SearchBloc>().add(SearchFiltersChanged(newFilters));
            },
          ),
          const SizedBox(width: 8),
          _QuickChip(
            label: '+50% desc.',
            icon: Icons.local_offer,
            isActive: _activeFilters.minDiscount >= 50,
            onTap: () {
              final isCurrentlyActive = _activeFilters.minDiscount >= 50;

              final SearchFilters newFilters;
              if (isCurrentlyActive) {
                // Deactivate: reset to 0
                newFilters = _activeFilters.copyWith(minDiscount: 0);
              } else {
                // Activate: set to 50%
                newFilters = _activeFilters.copyWith(minDiscount: 50);
              }
              setState(() => _activeFilters = newFilters);
              context.read<SearchBloc>().add(SearchFiltersChanged(newFilters));
            },
          ),
          const SizedBox(width: 8),
          _QuickChip(
            label: 'Cerca de mí',
            icon: Icons.near_me,
            isActive: _activeFilters.radiusKm != null &&
                _activeFilters.sortBy == SortBy.distance,
            onTap: () {
              final isCurrentlyActive = _activeFilters.radiusKm != null &&
                  _activeFilters.sortBy == SortBy.distance;

              final SearchFilters newFilters;
              if (isCurrentlyActive) {
                // Deactivate: clear radius and reset sort
                newFilters = _activeFilters.copyWith(
                  clearRadiusKm: true,
                  sortBy: SortBy.relevance,
                );
              } else {
                // Activate: set 5km radius and distance sort
                newFilters = _activeFilters.copyWith(
                  radiusKm: 5.0,
                  sortBy: SortBy.distance,
                );
              }
              setState(() => _activeFilters = newFilters);
              context.read<SearchBloc>().add(SearchFiltersChanged(newFilters));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    final hasFilters = _activeFilters.hasActiveFilters;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Filtros avanzados'),
            style: OutlinedButton.styleFrom(
              foregroundColor: hasFilters ? AppColors.primary : null,
              side: BorderSide(
                color: hasFilters ? AppColors.primary : Colors.grey,
              ),
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                const cleared = SearchFilters();
                setState(() => _activeFilters = cleared);
                context
                    .read<SearchBloc>()
                    .add(const SearchFiltersChanged(cleared));
              },
              child: const Text('Limpiar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state is SearchInitial) {
      return SearchHistoryList(
        history: state.history,
        onTap: (query) {
          _searchController.text = query;
          context.read<SearchBloc>().add(SearchHistoryItemTapped(query));
        },
        onClearAll: () =>
            context.read<SearchBloc>().add(const SearchHistoryCleared()),
      );
    }

    if (state is SearchSuggestionsLoaded) {
      return SearchSuggestionsList(
        suggestions: state.suggestions,
        query: state.query,
        onTap: (suggestion) {
          _searchController.text = suggestion;
          context.read<SearchBloc>()
            ..add(SearchQueryChanged(suggestion))
            ..add(const SearchSubmitted());
        },
      );
    }

    if (state is SearchLoading) {
      return _buildLoadingSkeletons();
    }

    if (state is SearchResultsLoaded) {
      return _buildResults(state);
    }

    if (state is SearchEmpty) {
      return _buildEmptyState(state.query);
    }

    if (state is SearchError) {
      return _buildErrorState(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildResults(SearchResultsLoaded state) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    final savedIds = authState is AuthAuthenticated
        ? authState.user.savedPromotions
        : <String>[];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final result = state.results[index];
        return SearchResultCard(
          result: result,
          isFavorite: savedIds.contains(result.promotion.id),
          onTap: () => context.push(
            AppRouter.promotionDetail,
            extra: result.promotion.id,
          ),
          onFavorite: userId.isNotEmpty ? () {} : null,
        );
      },
    );
  }

  Widget _buildEmptyState(String query) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFilterOnly = query.trim().isEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 100,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              isFilterOnly
                  ? 'Sin promociones con estos filtros'
                  : 'Sin resultados para "$query"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isFilterOnly
                  ? 'Intentá con otros filtros o ampliá el rango.'
                  : 'Probá con otros términos o ajustá los filtros.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                context.read<SearchBloc>().add(const SearchQueryChanged(''));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeletons() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _SkeletonCard(
        key: ValueKey('skeleton_$index'),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image skeleton
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle skeleton
                      Container(
                        height: 14,
                        width: 150,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Discount skeleton
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description skeleton
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: 200,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 16, color: isActive ? Colors.white : null),
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isActive ? Colors.white : null),
      side: BorderSide(
        color: isActive ? AppColors.primary : Theme.of(context).dividerColor,
      ),
    );
  }
}
