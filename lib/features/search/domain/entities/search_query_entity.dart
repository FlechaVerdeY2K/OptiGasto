import 'package:equatable/equatable.dart';
import 'search_filters.dart';

class SearchQueryEntity extends Equatable {
  final String text;
  final SearchFilters filters;

  const SearchQueryEntity({
    required this.text,
    this.filters = const SearchFilters(),
  });

  @override
  List<Object?> get props => [text, filters];
}
