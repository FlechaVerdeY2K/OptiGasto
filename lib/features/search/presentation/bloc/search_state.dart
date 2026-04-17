import 'package:equatable/equatable.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_history_item.dart';
import '../../domain/entities/search_result_entity.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<SearchHistoryItem> history;

  const SearchInitial({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;
  final String query;

  const SearchSuggestionsLoaded({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object?> get props => [suggestions, query];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchResultsLoaded extends SearchState {
  final List<SearchResultEntity> results;
  final SearchFilters filters;
  final String query;

  const SearchResultsLoaded({
    required this.results,
    required this.filters,
    required this.query,
  });

  @override
  List<Object?> get props => [results, filters, query];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}
