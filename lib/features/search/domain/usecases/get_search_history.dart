import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/search_history_item.dart';
import '../repositories/search_repository.dart';

class GetSearchHistory {
  final SearchRepository repository;

  GetSearchHistory(this.repository);

  Future<Either<Failure, List<SearchHistoryItem>>> call() async {
    return repository.getHistory();
  }
}
