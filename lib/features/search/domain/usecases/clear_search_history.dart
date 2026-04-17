import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/search_repository.dart';

class ClearSearchHistory {
  final SearchRepository repository;

  ClearSearchHistory(this.repository);

  Future<Either<Failure, void>> call() async {
    return repository.clearHistory();
  }
}
