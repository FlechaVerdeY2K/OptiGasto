import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_history_item.dart';
import '../entities/search_query_entity.dart';
import '../entities/search_result_entity.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<SearchResultEntity>>> search(
    SearchQueryEntity query, {
    double? userLat,
    double? userLng,
  });

  Future<Either<Failure, List<String>>> getSuggestions(String partialText);

  Future<Either<Failure, List<SearchHistoryItem>>> getHistory();

  Future<Either<Failure, void>> saveToHistory(String query);

  Future<Either<Failure, void>> clearHistory();
}
