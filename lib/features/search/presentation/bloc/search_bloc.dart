import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_query_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/clear_search_history.dart';
import '../../domain/usecases/get_search_history.dart';
import '../../domain/usecases/get_search_suggestions.dart';
import '../../domain/usecases/search_promotions.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchPromotions searchPromotions;
  final GetSearchSuggestions getSearchSuggestions;
  final GetSearchHistory getSearchHistory;
  final ClearSearchHistory clearSearchHistory;
  final SearchRepository repository;

  String _currentQuery = '';
  SearchFilters _currentFilters = const SearchFilters();
  double? _userLat;
  double? _userLng;

  SearchBloc({
    required this.searchPromotions,
    required this.getSearchSuggestions,
    required this.getSearchHistory,
    required this.clearSearchHistory,
    required this.repository,
  }) : super(const SearchInitial()) {
    on<SearchInitialized>(_onInitialized);
    // concurrent (default) + check _currentQuery tras delay = debounce efectivo
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchFiltersChanged>(_onFiltersChanged);
    on<SearchSubmitted>(_onSubmitted);
    on<SearchHistoryItemTapped>(_onHistoryItemTapped);
    on<SearchHistoryCleared>(_onHistoryCleared);
  }

  void setUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;
  }

  Future<void> _onInitialized(
    SearchInitialized event,
    Emitter<SearchState> emit,
  ) async {
    final result = await getSearchHistory();
    result.fold(
      (_) => emit(const SearchInitial()),
      (history) => emit(SearchInitial(history: history)),
    );
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.text;

    if (event.text.trim().length < 3) {
      final result = await getSearchHistory();
      result.fold(
        (_) => emit(const SearchInitial()),
        (history) => emit(SearchInitial(history: history)),
      );
      return;
    }

    // Debounce: esperar 300ms. Si el query cambió mientras esperábamos,
    // este handler ya no es el más reciente — no emitir.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (emit.isDone || _currentQuery != event.text) return;

    final result = await getSearchSuggestions(event.text.trim());
    result.fold(
      (_) => emit(
        SearchSuggestionsLoaded(suggestions: const [], query: event.text),
      ),
      (suggestions) => emit(
        SearchSuggestionsLoaded(suggestions: suggestions, query: event.text),
      ),
    );
  }

  Future<void> _onFiltersChanged(
    SearchFiltersChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentFilters = event.filters;

    // Si ya hay resultados, re-buscar con los nuevos filtros
    if (_currentQuery.isNotEmpty) {
      add(const SearchSubmitted());
    }
  }

  Future<void> _onSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    if (_currentQuery.trim().isEmpty) return;

    emit(const SearchLoading());

    final result = await searchPromotions(
      query: SearchQueryEntity(
        text: _currentQuery.trim(),
        filters: _currentFilters,
      ),
      userLat: _userLat,
      userLng: _userLng,
    );

    await result.fold(
      (failure) async => emit(SearchError(message: failure.message)),
      (results) async {
        // Save to history after successful search
        await repository.saveToHistory(_currentQuery.trim());

        if (results.isEmpty) {
          emit(SearchEmpty(query: _currentQuery));
        } else {
          emit(SearchResultsLoaded(
            results: results,
            filters: _currentFilters,
            query: _currentQuery,
          ));
        }
      },
    );
  }

  Future<void> _onHistoryItemTapped(
    SearchHistoryItemTapped event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;
    add(const SearchSubmitted());
  }

  Future<void> _onHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    await clearSearchHistory();
    emit(const SearchInitial());
  }
}
