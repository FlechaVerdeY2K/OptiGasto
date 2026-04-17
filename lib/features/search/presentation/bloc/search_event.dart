import 'package:equatable/equatable.dart';
import '../../domain/entities/search_filters.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchInitialized extends SearchEvent {
  const SearchInitialized();
}

class SearchQueryChanged extends SearchEvent {
  final String text;

  const SearchQueryChanged(this.text);

  @override
  List<Object?> get props => [text];
}

class SearchFiltersChanged extends SearchEvent {
  final SearchFilters filters;

  const SearchFiltersChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}

class SearchSubmitted extends SearchEvent {
  const SearchSubmitted();
}

class SearchHistoryItemTapped extends SearchEvent {
  final String query;

  const SearchHistoryItemTapped(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchHistoryCleared extends SearchEvent {
  const SearchHistoryCleared();
}
