import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_query_entity.dart';
import '../entities/search_result_entity.dart';
import '../repositories/search_repository.dart';

class SearchPromotions {
  final SearchRepository repository;

  SearchPromotions(this.repository);

  Future<Either<Failure, List<SearchResultEntity>>> call({
    required SearchQueryEntity query,
    double? userLat,
    double? userLng,
  }) async {
    return repository.search(query, userLat: userLat, userLng: userLng);
  }
}
