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
          context.read<SearchBloc>().add(SearchFiltersChanged(filters));
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
              final now = DateTime.now();
              final newFilters = _activeFilters.copyWith(
                dateFrom: now.subtract(const Duration(hours: 24)),
                dateTo: now,
              );
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
              final newFilters = _activeFilters.copyWith(minDiscount: 50);
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
              final newFilters = _activeFilters.copyWith(
                radiusKm: 5.0,
                sortBy: SortBy.distance,
              );
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
                context.read<SearchBloc>().add(const SearchFiltersChanged(cleared));
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
      return const Center(child: CircularProgressIndicator());
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "$query"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Probá con otros términos o ajustá los filtros.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
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
