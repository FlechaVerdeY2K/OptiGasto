import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/search_repository.dart';

class GetSearchSuggestions {
  final SearchRepository repository;

  GetSearchSuggestions(this.repository);

  Future<Either<Failure, List<String>>> call(String partialText) async {
    return repository.getSuggestions(partialText);
  }
}
